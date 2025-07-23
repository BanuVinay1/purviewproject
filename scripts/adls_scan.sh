#!/bin/bash

set -euo pipefail
set -x

echo "🔁 Starting ADLS Scan Script..."

# Show Azure CLI version
az version

# ========= Configuration =========
PURVIEW_NAME="banupurview"
SCAN_NAME="automated_adls_scan1"
COLLECTION_NAME="banupurview"
PURVIEW_RESOURCE_GROUP="personal"
SUBSCRIPTION_ID="e34ac57d-3802-4c72-9bf9-67b23f939b24"

STORAGE_ACCOUNT_NAME="pvadls1ixtg6uo5qrq4e"
STORAGE_RESOURCE_GROUP="purviewproject"

CREDENTIAL_NAME="ADLS_Raw"
SCAN_RULE_SET_NAME="System-DefaultAzureStorage"

ARM_RESOURCE_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${STORAGE_RESOURCE_GROUP}/providers/Microsoft.Storage/storageAccounts/${STORAGE_ACCOUNT_NAME}"
RESOURCE_PATH="${ARM_RESOURCE_ID:1}"  # Remove leading slash for REST URI

# ========= Register Data Source =========
echo "📌 Registering ADLS as a data source in Purview..."

az rest --method put \
  --uri "https://${PURVIEW_NAME}.purview.azure.com/scanning/datasources/${STORAGE_ACCOUNT_NAME}?api-version=2023-10-01-preview" \
  --headers "Content-Type=application/json" \
  --resource "https://purview.azure.net" \
  --body @- <<EOF
{
  "kind": "AzureStorage",
  "properties": {
    "resourceReference": {
      "type": "ArmResourceReference",
      "referenceName": "${ARM_RESOURCE_ID}"
    },
    "collection": {
      "type": "CollectionReference",
      "referenceName": "${COLLECTION_NAME}"
    }
  }
}
EOF

echo "✅ Data source registered."

# ========= Create Scan =========
echo "🛠️ Creating scan configuration..."

az rest --method put \
  --uri "https://${PURVIEW_NAME}.purview.azure.com/scanning/datasources/${STORAGE_ACCOUNT_NAME}?api-version=2023-10-01-preview" \
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
        "startTime": "2025-07-25T00:00:00Z"
      }
    }
  }
}
EOF

echo "✅ Scan configuration created."

# ========= Trigger Scan =========
echo "🚀 Triggering the scan..."

az rest --method post \
  --uri "https://${PURVIEW_NAME}.purview.azure.com/scanning/datasources/${STORAGE_ACCOUNT_NAME}/scans/${SCAN_NAME}/run?api-version=2023-10-01-preview" \
  --resource "https://purview.azure.net"

echo "🎉 ADLS scan triggered successfully!"