@description('Key Vault voor Manuals project')
@param('location') location string = resourceGroup().location
@param('environmentName') environmentName string
@param('tenantId') tenantId string = subscription().tenantId

var tags = {
  Environment: environmentName
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'kv-manuals-${environmentName}'
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: []
    enabledForTemplateDeployment: true
    enableRbacAuthorization: false
    softDeleteRetentionInDays: 7
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
    }
  }
}

// Voorbeeld van een secret (kan later dynamisch worden toegevoegd)
resource databasePasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'SqlAdminPassword'
  properties: {
    // Werkelijke wachtwoord wordt later toegevoegd
    value: ''
  }
}

output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri