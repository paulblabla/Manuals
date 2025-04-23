@description('Azure SQL Database voor Manuals project')
param location string = resourceGroup().location
param environmentName string
@secure()
param adminUsername string
@secure()
param adminPassword string
param adminGroupName string
param adminGroupObjectId string

var tags = {
  Environment: environmentName
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: 'sqlserver-manuals-${environmentName}'
  location: location
  tags: tags
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    
    // Minimale TLS-versie voor beveiliging
    minimalTlsVersion: '1.2'
    
    // Azure AD Groep als administrator
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: adminGroupName
      sid: adminGroupObjectId
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: false
    }
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: 'manuals-db'
  location: location
  tags: tags
  sku: {
    name: 'Basic'  // Gratis tier met 2GB opslag
    tier: 'Basic'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648  // 2GB
    
  }
}

// Firewall regel om Azure services toe te staan
resource sqlServerFirewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sqlDatabase.name
output sqlServerFQDN string = sqlServer.properties.fullyQualifiedDomainName
