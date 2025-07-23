// File: sql-lineage-eastus.bicep
// Purpose: Deploy a single SQL Server and DB in East US for Purview lineage scan

targetScope = 'resourceGroup'

param location string = 'eastus2'
var unique = uniqueString(resourceGroup().id)

resource sqlLineage 'Microsoft.Sql/servers@2021-11-01' = {
  name: 'pvsqllineage${unique}'
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

resource dbLineage 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlLineage
  name: 'lineagedb'
  location: location
  properties: {}
}

output sqlLineageName string = sqlLineage.name
output dbLineageName string = dbLineage.name
