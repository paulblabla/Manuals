@description('Azure SQL Database voor Manuals project')
param location string = resourceGroup().location
param sqlServerName string
param tags object = {}

// Database naam
param databaseName string = 'manuals-db'

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlServerName
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: tags
  sku: {
    name: 'Basic'  // Gratis tier met 2GB opslag
    tier: 'Basic'
  }
  properties: {
    maxSizeBytes: 2147483648  // 2GB
  }
}

output sqlDatabaseName string = sqlDatabase.name
output sqlDatabaseId string = sqlDatabase.id