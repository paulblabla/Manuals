@description('Key Vault voor het opslaan van secrets')
param location string = resourceGroup().location
param environmentName string
param currentUserObjectId string = ''

var tags = {
  Environment: environmentName
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

var keyVaultName = 'kv-manuals-${environmentName}'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    accessPolicies: !empty(currentUserObjectId) ? [
      {
        tenantId: subscription().tenantId
        objectId: currentUserObjectId
        permissions: {
          keys: ['Get', 'List', 'Update', 'Create', 'Delete']
          secrets: ['Get', 'List', 'Set', 'Delete']
          certificates: ['Get', 'List', 'Update', 'Create', 'Delete']
        }
      }
    ] : []
    sku: {
      name: 'standard'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// Output
output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri