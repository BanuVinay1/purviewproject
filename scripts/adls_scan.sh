#!/bin/bash

set -e
set -x

echo "Starting ADLS Scan Script..."
echo "Azure CLI version:"
az version

# Variables
PURVIEW_NAME="banupurview"
SCAN_NAME="automated_adls_scan1"
COLLECTION_NAME="default"
RESOURCE_GROUP="purviewproject"
SUBSCRIPTION_ID="e34ac57d-3802-4c72-9bf9-67b23f939b24"
STORAGE_ACCOUNT_NAME="pvadls1ixtg6uo5qrq4e"
RESOURCE_NAME="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Storage/storageAccounts/${STORAGE_ACCOUNT_NAME}"
CREDENTIAL_NAME="ADLS_Raw"
SCAN_RULE_SET_NAME="System-DefaultAzureStorage"

echo "Target Purview Account: $PURVIEW_NAME"
echo "Registering the ADLS account as a data source..."

# STEP 1 - Register the ADLS account as a data source
az rest --method put \
  --uri "https://${PURVIEW_NAME}.purview.azure.com/scanning/datasources/${STORAGE_ACCOUNT_NAME}?api-version=2022-09-01-preview" \
  --headers "Content-Type=application/json" \
  --resource "https://purview.azure.net" \
  --body @- <<EOF
{
  "kind": "AzureStorage",
  "properties": {
    "resourceReference": {
      "type": "ArmResourceReference",
      "referenceName": "${RESOURCE_NAME}"
    },
    "collection": {
      "type": "CollectionReference",
      "referenceName": "${COLLECTION_NAME}"
    }
  }
}
EOF

# STEP 2 - Create the scan
echo "Creating the scan..."

az rest --method put \
  --uri "https://${PURVIEW_NAME}.purview.azure.com/scanning/datasources/${STORAGE_ACCOUNT_NAME}/scans/${SCAN_NAME}?api-version=2022-09-01-preview" \
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
    "connectedVia": null,
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

# STEP 3 - Trigger the scan manually
echo "Triggering the scan..."

az rest --method post \
  --uri "https://${PURVIEW_NAME}.purview.azure.com/scanning/datasources/${STORAGE_ACCOUNT_NAME}/scans/${SCAN_NAME}/run?api-version=2022-09-01-preview" \
  --resource "https://purview.azure.net"
