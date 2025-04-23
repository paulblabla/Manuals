@description('Storage account voor Manuals project')
@param('location') location string = resourceGroup().location
@param('environmentName') environmentName string

var tags = {
  Environment: environmentName
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'stomanualspdfs${environmentName}'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'  // Lokaal redundante opslag (goedkoopste optie)
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Allow'  // Vereenvoudigd voor gratis tier
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
    }
  }
}

// Blob container voor handleidingen
resource manualsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccount.name}/default/manuals'
  properties: {
    publicAccess: 'None'  // Geen publieke toegang
  }
}

// Container voor tijdelijke uploads
resource uploadsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccount.name}/default/uploads'
  properties: {
    publicAccess: 'None'  // Geen publieke toegang
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output primaryAccessKey string = storageAccount.listKeys().keys[0].value
output manualsContainerName string = manualsContainer.name
output uploadsContainerName string = uploadsContainer.name
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=core.windows.net;'