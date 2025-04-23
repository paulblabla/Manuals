@description('Storage account voor Manuals project')
param location string = resourceGroup().location
param environmentName string

var tags = {
  Environment: environmentName
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

// Unieke naam voor storage account garanderen
var storageAccountName = 'stomanualspdfs${environmentName}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'  // Lokaal redundante opslag (goedkoopste optie)
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Allow'  // Vereenvoudigd voor gratis tier
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
    }
  }
}

// Blob service resource expliciet definiëren
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

// Blob container voor handleidingen
resource manualsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: blobService
  name: 'manuals'
  properties: {
    publicAccess: 'None'  // Geen publieke toegang
  }
}

// Container voor tijdelijke uploads
resource uploadsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: blobService
  name: 'uploads'
  properties: {
    publicAccess: 'None'  // Geen publieke toegang
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
// Gebruik een veiligere benadering voor verbindingsgegevens - vermijd directe keys in outputs
@description('Storage account connection string zonder access keys')
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};'
output manualsContainerName string = manualsContainer.name
output uploadsContainerName string = uploadsContainer.name