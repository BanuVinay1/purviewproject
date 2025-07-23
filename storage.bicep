// File: storage-kv-adf.bicep
// This deploys 2 ADLS Gen2, 1 Blob Storage account, a Key Vault, Azure Data Factory, 2 SQL Servers with Databases in Central India,
// and an additional SQL Server + DB in East US specifically for lineage scanning with Purview

targetScope = 'resourceGroup'

param location string = resourceGroup().location
var unique = uniqueString(resourceGroup().id)

resource adls1 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'pvadls1${unique}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    accessTier: 'Hot'
  }
}

resource adls2 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'pvadls2${unique}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    accessTier: 'Hot'
  }
}

resource blob1 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'pvblob1${unique}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'pvkv${unique}'
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableSoftDelete: true
    enabledForDeployment: true
    enabledForTemplateDeployment: true
  }
}

resource df 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: 'pvdf${unique}'
  location: location
  properties: {}
}

resource sql1 'Microsoft.Sql/servers@2021-11-01' = {
  name: 'pvsql1${unique}'
  location: location
  properties: {
    administratorLogin: 'sqladminuser'
    administratorLoginPassword: 'Pa$$w0rd1234!'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
}

resource hrdb 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sql1
  name: 'hrdb'
  location: location
  properties: {}
}

resource sql2 'Microsoft.Sql/servers@2021-11-01' = {
  name: 'pvsql2${unique}'
  location: location
  properties: {
    administratorLogin: 'sqladminuser'
    administratorLoginPassword: 'Pa$$w0rd1234!'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
}

resource financedb 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sql2
  name: 'financedb'
  location: location
  properties: {}
}

// New SQL Server and DB in East US for Purview Lineage Scan
resource sqlLineage 'Microsoft.Sql/servers@2021-11-01' = {
  name: 'pvsqllineage${unique}'
  location: 'eastus2'
  properties: {
    administratorLogin: 'sqladminuser'
    administratorLoginPassword: 'Pa$$w0rd1234!'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
}

resource dbLineage 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlLineage
  name: 'lineagedb'
  location: 'eastus2'
  properties: {}
}

output adls1Name string = adls1.name
output adls2Name string = adls2.name
output blob1Name string = blob1.name
output kvName string = kv.name
output dataFactoryName string = df.name
output sql1Name string = sql1.name
output sql2Name string = sql2.name
output sqlLineageName string = sqlLineage.name
