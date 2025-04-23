targetScope = 'subscription'

@description('Naam van de resource group')
param resourceGroupName string

@description('Regio voor de resource group')
param location string = 'westeurope'

@description('Tags voor de resource group')
param tags object = {
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

// Resource group aanmaken
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Output resource group naam en ID
output resourceGroupName string = resourceGroup.name
output resourceGroupId string = resourceGroup.id
