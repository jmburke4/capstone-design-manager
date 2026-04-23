#!/bin/bash
###############################################################################
# Deployment Configuration File
# 
# This file contains variables used across all deployment scripts.
# Source this file at the beginning of each deployment script.
# Future developer will definitely need to chnage USERNAME and EMAIL variables.
###############################################################################

# GCP Project Configuration
PROJECT_ID="capstone-design-app-prod"
ZONE="us-central1-b"
VM_NAME="capstone-prod-vm"
APP_DIR="capstone"

# VM User Configuration
# This is the username on the VM where the application is deployed
# For GCP compute instances, this is typically your GCP account username
VM_USERNAME="PUT_YOUR_USER_NAME_HERE"

# Domain Configuration
DEFAULT_DOMAIN="ua-capstone-projects.com"

# This should probably be the same email that is associated with the deployment domain
USER_EMAIL="PUT_YOUR_EMAIL_HERE"

# Export variables for use in docker-compose and other tools
export VM_USERNAME
export PROJECT_ID
export ZONE
export VM_NAME
export APP_DIR
export DEFAULT_DOMAIN
export USER_EMAIL
