@description('Azure SQL Server voor Manuals project')
param location string = resourceGroup().location
param environmentName string
@secure()
param adminUsername string
param keyVaultName string
param secretName string = 'sqlAdminPassword'
param adminGroupName string
param adminGroupObjectId string

var tags = {
  Environment: environmentName
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

// Referentie naar het bestaande secret in KeyVault
resource sqlPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' existing = {
  name: '${keyVaultName}/${secretName}'
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: 'sqlserver-manuals-${environmentName}'
  location: location
  tags: tags
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: sqlPasswordSecret.properties.value
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
output sqlServerFQDN string = sqlServer.properties.fullyQualifiedDomainName
output sqlServerId string = sqlServer.id
