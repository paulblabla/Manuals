@description('Secret toevoegen aan Key Vault')
param keyVaultName string
param secretName string

@secure()
param secretValue string

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: '${keyVaultName}/${secretName}'
  properties: {
    value: secretValue
  }
}

output secretUri string = keyVaultSecret.properties.secretUri
