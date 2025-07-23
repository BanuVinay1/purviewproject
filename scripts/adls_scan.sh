#!/bin/bash

set -e
set -x

echo "🔁 Starting ADLS Scan Script..."

az version

# Variables
PURVIEW_NAME="banupurview"
SCAN_NAME="automated_adls_scan1"
COLLECTION_NAME="banupurview"  # Or "default" if that's your collection
RESOURCE_GROUP="purviewproject"
SUBSCRIPTION_ID="e34ac57d-3802-4c72-9bf9-67b23f939b24"
STORAGE_ACCOUNT_NAME="pvadls1ixtg6uo5qrq4e"
CREDENTIAL_NAME="ADLS_Raw"
SCAN_RULE_SET_NAME="System-DefaultAzureStorage"

ARM_RESOURCE_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Storage/storageAccounts/${STORAGE_ACCOUNT_NAME}"

echo "📌 Registering ADLS as a data source in Purview..."

az rest --method put \
  --uri "https://${PURVIEW_NAME}.scan.purview.azure.com/scanning/datasources/${STORAGE_ACCOUNT_NAME}?api-version=2022-12-01-preview" \
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

echo "🛠️ Creating scan configuration..."

az rest --method put \
  --uri "https://${PURVIEW_NAME}.scan.purview.azure.com/scanning/datasources/${STORAGE_ACCOUNT_NAME}/scans/${SCAN_NAME}?api-version=2022-12-01-preview" \
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

echo "🚀 Triggering the scan..."

az rest --method post \
  --uri "https://${PURVIEW_NAME}.scan.purview.azure.com/scanning/datasources/${STORAGE_ACCOUNT_NAME}/scans/${SCAN_NAME}/run?api-version=2022-12-01-preview" \
  --resource "https://purview.azure.net"

echo "🎉 ADLS scan triggered successfully!"
