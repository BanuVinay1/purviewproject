#!/bin/bash

set -euo pipefail
set -x

echo "🔁 Starting ADLS Scan Script..."

# Confirm Azure CLI setup
az version

# ========= CONFIGURATION =========
PURVIEW_NAME="banupurview"
SUBSCRIPTION_ID="e34ac57d-3802-4c72-9bf9-67b23f939b24"
RESOURCE_GROUP="purviewproject"
STORAGE_ACCOUNT_NAME="pvadls1ixtg6uo5qrq4e"
SCAN_NAME="automated_adls_scan1"
CREDENTIAL_NAME="gha"
COLLECTION_NAME="banupurview"
SCAN_RULE_SET_NAME="System-DefaultAzureStorage"

# ========= CREATE SCAN CONFIGURATION =========
echo "🛠️ Creating scan configuration..."

az rest --method put \
  --uri "https://${PURVIEW_NAME}.scan.purview.azure.com/scanning/datasources/${STORAGE_ACCOUNT_NAME}/scans/${SCAN_NAME}?api-version=2023-10-01-preview" \
  --headers "Content-Type=application/json" \
  --resource "https://purview.azure.net" \
  --body @- <<EOF
{
  "kind": "AzureStorage",
  "properties": {
    "collection": {
      "type": "CollectionReference",
      "referenceName": "${COLLECTION_NAME}"
    },
    "credential": {
      "referenceName": "${CREDENTIAL_NAME}",
      "type": "CredentialReference"
    },
    "scanRulesetName": "${SCAN_RULE_SET_NAME}",
    "scanRulesetType": "System",
    "trigger": {
      "schedule": {
        "interval": 7,
        "intervalUnit": "Day",
        "startTime": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
      }
    }
  }
}
EOF

echo "✅ Scan configuration created."

# ========= TRIGGER THE SCAN =========
echo "🚀 Triggering the scan..."

az rest --method post \
  --uri "https://${PURVIEW_NAME}.scan.purview.azure.com/scanning/datasources/${STORAGE_ACCOUNT_NAME}/scans/${SCAN_NAME}/run?api-version=2023-10-01-preview" \
  --resource "https://purview.azure.net"

echo "🎉 ADLS scan triggered successfully!"
