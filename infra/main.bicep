// Deployment op subscription niveau
targetScope = 'subscription'

@description('Hoofd Bicep template voor Manuals project')
param location string = 'westeurope'
param environmentName string

// Parameters voor gevoelige gegevens
@secure()
param sqlAdminUsername string
@secure()
param sqlAdminPassword string

// Resource group naam opbouwen op basis van environment
var resourceGroupName = 'rg-manuals-${environmentName}'

// Tags voor alle resources
var tags = {
  Environment: environmentName
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

// Resource group aanmaken
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Modules importeren
module appInsights 'modules/applicationinsights.bicep' = {
  name: 'applicationInsightsDeployment'
  scope: resourceGroup  // Specifiek de resource group aangeven
  params: {
    location: location
    environmentName: environmentName
  }
}

module storage 'modules/storage.bicep' = {
  name: 'storageDeployment'
  scope: resourceGroup  // Specifiek de resource group aangeven
  params: {
    location: location
    environmentName: environmentName
  }
}

module database 'modules/database.bicep' = {
  name: 'databaseDeployment'
  scope: resourceGroup  // Specifiek de resource group aangeven
  params: {
    location: location
    environmentName: environmentName
    adminUsername: sqlAdminUsername
    adminPassword: sqlAdminPassword
  }
}

module appService 'modules/appservice.bicep' = {
  name: 'appServiceDeployment'
  scope: resourceGroup  // Specifiek de resource group aangeven
  params: {
    location: location
    environmentName: environmentName
  }
}

module staticWebApp 'modules/staticwebapp.bicep' = {
  name: 'staticWebAppDeployment'
  scope: resourceGroup  // Specifiek de resource group aangeven
  params: {
    location: location
    environmentName: environmentName
  }
}

// Outputs verzamelen voor gebruik in andere scripts/configuraties
output appInsightsInstrumentationKey string = appInsights.outputs.appInsightsInstrumentationKey
output storageAccountName string = storage.outputs.storageAccountName
output sqlServerName string = database.outputs.sqlServerName
output sqlDatabaseName string = database.outputs.sqlDatabaseName
output appServiceName string = appService.outputs.appServiceName
output staticWebAppName string = staticWebApp.outputs.staticWebAppName
output resourceGroupName string = resourceGroup.name