#!/bin/bash

# Firebase Billing Alerts Setup Script
# This script helps you set up billing alerts for your Mat Kenya Firebase project

set -e  # Exit on error

echo "================================================"
echo "  Mat Kenya Firebase Billing Alerts Setup"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed${NC}"
    echo "Install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if user is logged in
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo -e "${YELLOW}You need to login to gcloud${NC}"
    gcloud auth login
fi

echo -e "${GREEN}✓ gcloud CLI detected${NC}"
echo ""

# Get project ID
echo "Enter your Firebase Project ID:"
read -r PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Error: Project ID cannot be empty${NC}"
    exit 1
fi

# Set project
gcloud config set project "$PROJECT_ID"
echo -e "${GREEN}✓ Project set to: $PROJECT_ID${NC}"
echo ""

# Get billing account
echo "Fetching billing accounts..."
BILLING_ACCOUNTS=$(gcloud beta billing accounts list --format="value(name)")

if [ -z "$BILLING_ACCOUNTS" ]; then
    echo -e "${RED}Error: No billing accounts found${NC}"
    echo "Create one at: https://console.cloud.google.com/billing"
    exit 1
fi

echo "Available billing accounts:"
gcloud beta billing accounts list

echo ""
echo "Enter your Billing Account ID (format: 012345-67890A-BCDEF0):"
read -r BILLING_ACCOUNT

# Enable required APIs
echo ""
echo "Enabling required APIs..."
gcloud services enable cloudbilling.googleapis.com
gcloud services enable cloudpubsub.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
echo -e "${GREEN}✓ APIs enabled${NC}"

# Create Pub/Sub topic
echo ""
echo "Creating Pub/Sub topic for billing alerts..."
if gcloud pubsub topics describe billing-alerts &> /dev/null; then
    echo -e "${YELLOW}Topic 'billing-alerts' already exists${NC}"
else
    gcloud pubsub topics create billing-alerts
    echo -e "${GREEN}✓ Pub/Sub topic created${NC}"
fi

# Set monthly budget
echo ""
echo "Enter your monthly budget in USD (e.g., 100 for $100/month):"
read -r BUDGET_AMOUNT

if ! [[ "$BUDGET_AMOUNT" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Budget must be a number${NC}"
    exit 1
fi

# Create budget with alerts
echo ""
echo "Creating budget with alert thresholds at 50%, 80%, 90%, 100%, and 110%..."

gcloud beta billing budgets create \
  --billing-account="$BILLING_ACCOUNT" \
  --display-name="Mat Kenya Monthly Budget" \
  --budget-amount="$BUDGET_AMOUNT" \
  --threshold-rule=percent=0.5 \
  --threshold-rule=percent=0.8 \
  --threshold-rule=percent=0.9 \
  --threshold-rule=percent=1.0 \
  --threshold-rule=percent=1.1 \
  --all-updates-rule-pubsub-topic="projects/$PROJECT_ID/topics/billing-alerts"

echo -e "${GREEN}✓ Budget created successfully!${NC}"
echo ""

# Get alert emails
echo "Enter email addresses for budget alerts (comma-separated):"
read -r ALERT_EMAILS

# Note about email setup
echo ""
echo -e "${YELLOW}Note: Email notifications need to be set up in Google Cloud Console${NC}"
echo "Go to: https://console.cloud.google.com/billing/budgets"
echo "Edit your budget and add email addresses: $ALERT_EMAILS"
echo ""

# Deploy budget monitoring function
echo "Would you like to deploy the budget monitoring Cloud Function? (y/n)"
read -r DEPLOY_FUNCTION

if [ "$DEPLOY_FUNCTION" = "y" ]; then
    echo ""
    echo "Deploying budget monitoring function..."

    cd firebase/functions
    npm install
    cd ../..

    firebase deploy --only functions:budgetMonitor,functions:dailyUsageCheck

    echo -e "${GREEN}✓ Cloud Functions deployed${NC}"
fi

# Summary
echo ""
echo "================================================"
echo "  Setup Complete! ✓"
echo "================================================"
echo ""
echo "Summary:"
echo "  Project: $PROJECT_ID"
echo "  Budget: \$$BUDGET_AMOUNT/month"
echo "  Alert thresholds: 50%, 80%, 90%, 100%, 110%"
echo ""
echo "Next steps:"
echo "  1. Add email addresses in Google Cloud Console"
echo "  2. Test alerts by simulating usage"
echo "  3. Monitor daily usage in Firebase Console"
echo "  4. Review budget alerts collection in Firestore"
echo ""
echo "Monitoring dashboard:"
echo "  https://console.cloud.google.com/billing/budgets?project=$PROJECT_ID"
echo ""
echo "Firebase Console:"
echo "  https://console.firebase.google.com/project/$PROJECT_ID"
echo ""
echo -e "${GREEN}All set! Your billing alerts are now active.${NC}"
