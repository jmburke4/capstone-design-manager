#!/bin/bash
#############################################################################
# Create Google Compute Engine VM
#
# Creates an e2-micro VM instance with:
# - Static external IP
# - Firewall rules for HTTP/HTTPS/SSH
# - Ubuntu 22.04 LTS
#
# Usage: ./scripts/01-create-vm.sh
#############################################################################
set -e

# Disable gcloud interactive prompts globally for this script run.
# This prevents the script from ever getting stuck waiting for a Y/n prompt,
# confirmation dialog, or any other interactive input.
export CLOUDSDK_CORE_DISABLE_PROMPTS=1

PROJECT_ID="capstone-design-app-prod"
REGION="us-central1"
ZONE="us-central1-b"
VM_NAME="capstone-prod-vm"
MACHINE_TYPE="e2-micro" # Free tier eligible
DISK_SIZE="30GB"
IMAGE_FAMILY="ubuntu-2204-lts"
IMAGE_PROJECT="ubuntu-os-cloud"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Creating Google Compute Engine VM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate prerequisites
echo "Validating prerequisites..."
# Check gcloud is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q .; then
        echo " ✗ ERROR: Not authenticated with gcloud"
        echo " Run: gcloud auth login"
        exit 1
fi
echo " ✓ Authenticated with gcloud"

# Check project exists
if ! gcloud projects describe $PROJECT_ID &>/dev/null; then
        echo " ✗ ERROR: Project '$PROJECT_ID' does not exist"
        echo " Create it at: https://console.cloud.google.com/projectcreate"
        echo " Use project ID: $PROJECT_ID"
        exit 1
fi
echo " ✓ Project exists"

# Check billing is enabled
BILLING_ENABLED=$(gcloud beta billing projects describe $PROJECT_ID --format='value(billingEnabled)' 2>/dev/null || echo "False")
if [ "$BILLING_ENABLED" != "True" ]; then
        echo " ⚠ WARNING: Billing may not be enabled"
        echo " Enable at: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
fi

# Enable Compute Engine API if not already enabled
if ! gcloud services list --enabled --project=$PROJECT_ID 2>/dev/null | grep -q compute.googleapis.com; then
        echo " Enabling Compute Engine API..."
        gcloud services enable compute.googleapis.com --project=$PROJECT_ID --quiet
fi
echo " ✓ Compute Engine API enabled"

# Check Cloud-V2 branch exists in remote repo
echo " Checking GitHub repository..."
if git ls-remote --heads https://github.com/jmburke4/capstone-design-manager.git Cloud-V2 | grep -q Cloud-V2; then
        echo " ✓ Cloud-V2 branch exists on GitHub"
else
        echo " ⚠ WARNING: Cloud-V2 branch not found on GitHub"
        echo " Make sure to push: git push origin Cloud-V2"
fi
echo ""

# Set project
gcloud config set project $PROJECT_ID --quiet

# Reserve static external IP
echo "Reserving static external IP..."
if gcloud compute addresses describe ${VM_NAME}-ip --region=$REGION --project=$PROJECT_ID &>/dev/null; then
        echo " ✓ Static IP already exists"
        EXTERNAL_IP=$(gcloud compute addresses describe ${VM_NAME}-ip --region=$REGION --project=$PROJECT_ID --format='value(address)')
else
        gcloud compute addresses create ${VM_NAME}-ip \
                --region=$REGION \
                --project=$PROJECT_ID \
                --network-tier=STANDARD \
                --quiet

        EXTERNAL_IP=$(gcloud compute addresses describe ${VM_NAME}-ip --region=$REGION --project=$PROJECT_ID --format='value(address)')
        echo " ✓ Static IP reserved: $EXTERNAL_IP"
fi

# Create firewall rules (now with explicit existence check to avoid any error-path surprises)
echo ""
echo "Creating firewall rules..."
# Allow HTTP (port 80)
if gcloud compute firewall-rules describe ${VM_NAME}-allow-http --project=$PROJECT_ID &>/dev/null; then
        echo " ✓ HTTP firewall rule already exists"
else
        gcloud compute firewall-rules create ${VM_NAME}-allow-http \
                --project=$PROJECT_ID \
                --allow=tcp:80 \
                --source-ranges=0.0.0.0/0 \
                --target-tags=${VM_NAME} \
                --description="Allow HTTP traffic" \
                --quiet
        echo " ✓ HTTP firewall rule created"
fi

# Allow HTTPS (port 443)
if gcloud compute firewall-rules describe ${VM_NAME}-allow-https --project=$PROJECT_ID &>/dev/null; then
        echo " ✓ HTTPS firewall rule already exists"
else
        gcloud compute firewall-rules create ${VM_NAME}-allow-https \
                --project=$PROJECT_ID \
                --allow=tcp:443 \
                --source-ranges=0.0.0.0/0 \
                --target-tags=${VM_NAME} \
                --description="Allow HTTPS traffic" \
                --quiet
        echo " ✓ HTTPS firewall rule created"
fi
echo " ✓ Firewall rules configured"

# Create VM instance
echo ""
echo "Creating VM instance $VM_NAME..."
echo " Machine type: $MACHINE_TYPE (free tier eligible)"
echo " Disk: $DISK_SIZE HDD"
echo " Zone: $ZONE"
echo ""

if gcloud compute instances describe $VM_NAME --zone=$ZONE --project=$PROJECT_ID &>/dev/null; then
        echo " ✓ VM instance already exists"
else
        gcloud compute instances create $VM_NAME \
                --project=$PROJECT_ID \
                --zone=$ZONE \
                --machine-type=$MACHINE_TYPE \
                --network-interface=address=${EXTERNAL_IP},network-tier=STANDARD \
                --metadata=enable-oslogin=true \
                --maintenance-policy=MIGRATE \
                --provisioning-model=STANDARD \
                --tags=${VM_NAME},http-server,https-server \
                --create-disk=auto-delete=yes,boot=yes,device-name=$VM_NAME,image=projects/$IMAGE_PROJECT/global/images/family/$IMAGE_FAMILY,mode=rw,size=$DISK_SIZE,type=pd-standard \
                --no-shielded-secure-boot \
                --shielded-vtpm \
                --shielded-integrity-monitoring \
                --labels=app=capstone,environment=production \
                --quiet

        echo " ✓ VM instance created"
fi

# Wait for VM to be running
echo ""
echo "Waiting for VM to be ready..."
sleep 10

# Get VM status
VM_STATUS=$(gcloud compute instances describe $VM_NAME --zone=$ZONE --project=$PROJECT_ID --format='value(status)')
if [ "$VM_STATUS" = "RUNNING" ]; then
        echo " ✓ VM is running"
else
        echo " ⚠ VM status: $VM_STATUS"
        echo " Waiting for VM to start..."
        sleep 20
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " ✓ VM Creation Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "VM Details:"
echo " Name: $VM_NAME"
echo " Zone: $ZONE"
echo " Machine type: $MACHINE_TYPE"
echo " External IP: $EXTERNAL_IP"
echo " Internal IP: $(gcloud compute instances describe $VM_NAME --zone=$ZONE --project=$PROJECT_ID --format='value(networkInterfaces[0].networkIP)')"
echo ""
echo "SSH Access:"
echo " gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID"
echo ""
echo "View in console:"
echo " https://console.cloud.google.com/compute/instancesDetail/zones/$ZONE/instances/$VM_NAME?project=$PROJECT_ID"
echo ""
echo "Next step:"
echo " ./scripts/02-setup-vm.sh"
echo ""
