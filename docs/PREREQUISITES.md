# ✅ Prerequisites for Deployment

**COMPLETE THESE BEFORE RUNNING ANY SCRIPTS**

---

## 1. GCP Project Setup (5 minutes)

### Create Project

1. **Go to**: https://console.cloud.google.com/projectcreate

2. **Fill in**:
   - Project name: `Capstone Design App Prod`
   - Project ID: `capstone-design-app-prod` (MUST match exactly)
   - Organization: No organization

3. **Click**: "CREATE"

4. **Wait**: ~30 seconds for project creation

### Enable Billing

1. **Go to**: https://console.cloud.google.com/billing/linkedaccount?project=capstone-design-app-prod

2. **Click**: "Link a billing account"

3. **Select**: Your billing account (with $300 free credits)

4. **Click**: "SET ACCOUNT"

5. **Verify**: Billing shows as "Active" with green checkmark

---

## 2. Push Cloud-V2 Branch to GitHub (2 minutes)

**CRITICAL**: Scripts will clone from GitHub's Cloud-V2 branch.

### Verify Branch Exists Locally

```bash
cd /Users/cwk/VSC_Projects/capstone-design-manager
git branch --show-current
# Should show: Cloud-V2
```

### Push to GitHub

```bash
# If you haven't pushed Cloud-V2 yet
git push origin Cloud-V2

# Or if it exists but needs updating
git push origin Cloud-V2 --force
```

### Verify on GitHub

Open: https://github.com/jmburke4/capstone-design-manager/tree/Cloud-V2

Should show your Cloud-V2 branch with all the deployment files.

---

## 3. SSH Key Setup (One-Time, 3 minutes)

### Option A: Remove Passphrase (Recommended)

If you have an SSH passphrase you don't remember or want to avoid typing it multiple times:

```bash
# Remove existing SSH keys
rm ~/.ssh/google_compute_engine ~/.ssh/google_compute_engine.pub

# Clear SSH config
gcloud compute config-ssh --remove

# Next time you SSH, gcloud will regenerate keys
# When prompted for passphrase, just press ENTER (no passphrase)
```

**Next time you run `gcloud compute ssh`**:
```
Generating SSH key...
Enter passphrase (empty for no passphrase): [PRESS ENTER]
Enter same passphrase again: [PRESS ENTER]
```

### Option B: Use SSH Agent (Keep Passphrase)

If you want to keep your passphrase but avoid typing it repeatedly:

```bash
# Start SSH agent
eval $(ssh-agent)

# Add your key
ssh-add ~/.ssh/google_compute_engine

# Enter passphrase: [TYPE YOUR PASSPHRASE]
# Identity added: /Users/cwk/.ssh/google_compute_engine
```

**Then**: Run all deployment scripts in the same terminal session.

### Option C: Find Your Passphrase

If you know you set a passphrase but don't remember it:
- Check your password manager
- Try common passwords you use
- If all else fails, use **Option A** (remove and regenerate)

---

## 4. Verify Tools Installed (1 minute)

```bash
# Google Cloud SDK
gcloud --version
# Should show version 400.0.0 or later

# Docker (for local testing)
docker --version
# Any recent version

# Git
git --version
```

**If gcloud not installed**:
- Install from: https://cloud.google.com/sdk/docs/install

---

## 5. Authenticate with GCP (2 minutes)

```bash
# Login to gcloud
gcloud auth login
# Opens browser, login with your Google account

# Set default project
gcloud config set project capstone-design-app-prod

# Verify
gcloud config get-value project
# Should output: capstone-design-app-prod
```

---

## 6. Verify GitHub Repository is Public (1 minute)

**Check**: https://github.com/jmburke4/capstone-design-manager

- Should be accessible without login
- Cloud-V2 branch should be visible
- If private, scripts will fail during git clone

**If private**, either:
- Make repository public temporarily
- Or: Setup SSH deploy key (more complex, let me know if needed)

---

## ✅ PREREQUISITES CHECKLIST

Before running `./scripts/01-create-vm.sh`, verify:

**GCP Setup**:
- [ ] GCP project created with ID: `capstone-design-app-prod`
- [ ] Billing enabled and active
- [ ] gcloud CLI installed
- [ ] Authenticated with: `gcloud auth login`
- [ ] Project set: `gcloud config set project capstone-design-app-prod`

**GitHub Setup**:
- [ ] Cloud-V2 branch exists locally
- [ ] Cloud-V2 branch pushed to GitHub: `git push origin Cloud-V2`
- [ ] Repository is public OR has deploy key configured
- [ ] Can access: https://github.com/jmburke4/capstone-design-manager/tree/Cloud-V2

**SSH Setup** (choose one):
- [ ] SSH key passphrase removed (Option A - recommended)
- [ ] OR: ssh-agent running with key added (Option B)
- [ ] OR: Know your passphrase and can type it when prompted

**Local Environment**:
- [ ] In project directory: `/Users/cwk/VSC_Projects/capstone-design-manager`
- [ ] All scripts are executable: `ls -l scripts/*.sh`
- [ ] Docker running locally (for testing): `docker ps`

---

## 🚨 COMMON ISSUES

### "Permission denied" during SSH
**Solution**: Complete SSH key setup (Section 3 above)

### "Project not found"
**Solution**: Verify project ID is exactly `capstone-design-app-prod`

### "Branch not found" during clone
**Solution**: Push Cloud-V2 branch to GitHub first

### "Billing not enabled"
**Solution**: Enable billing in GCP Console

---

## 🎯 AFTER PREREQUISITES

Once all prerequisites are complete:

```bash
# Start deployment
./scripts/01-create-vm.sh
```

The script will validate prerequisites automatically and warn you if anything is missing.

---

## 📞 HELP

If you encounter issues with prerequisites:
- SSH setup: See Section 3 above
- GCP project: Double-check project ID matches exactly
- GitHub: Verify Cloud-V2 branch is pushed

---

**Estimated time to complete prerequisites**: 10-15 minutes (one-time setup)

**After prerequisites**: Deployment scripts will run smoothly without interruptions
