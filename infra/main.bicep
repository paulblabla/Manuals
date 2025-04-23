// Deployment op subscription niveau
targetScope = 'subscription'

@description('Hoofd Bicep template voor Manuals project')
param location string = 'westeurope'
param environmentName string

// SQL Azure AD Admin parameters
param sqlAdminUsername string
param sqlAdminGroupName string
param sqlAdminGroupObjectId string

// Resource group naam opbouwen op basis van environment
var resourceGroupName = 'rg-manuals-${environmentName}'

// Tags voor alle resources
var tags = {
  Environment: environmentName
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

// Genereer een sterk wachtwoord voor SQL Server
var sqlPasswordLength = 24
var chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()_+-='
var sqlPassword = '${take(uniqueString(subscription().id, resourceGroup.id, deployment().name), 8)}${take(uniqueString(resourceGroup.name, subscription().subscriptionId), 8)}Aa1!'

// Resource group aanmaken
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Key Vault aanmaken om secrets op te slaan
module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVaultDeployment'
  scope: resourceGroup
  params: {
    location: location
    environmentName: environmentName
    currentUserObjectId: sqlAdminGroupObjectId // Geef de SQL admin groep rechten op de Key Vault
  }
}

// SQL wachtwoord opslaan in Key Vault
module sqlPasswordSecret 'modules/keyvaultsecret.bicep' = {
  name: 'sqlPasswordSecret'
  scope: resourceGroup
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'sqlAdminPassword'
    secretValue: sqlPassword
  }
  dependsOn: [
    keyVault
  ]
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
    adminPassword: sqlPassword
    adminGroupName: sqlAdminGroupName
    adminGroupObjectId: sqlAdminGroupObjectId
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
output keyVaultName string = keyVault.outputs.keyVaultName
output keyVaultUri string = keyVault.outputs.keyVaultUri

// Bij eerste deployment, toon SQL wachtwoord (alleen in logs)
@description('SQL Server Admin wachtwoord - ALLEEN ZICHTBAAR BIJ EERSTE DEPLOYMENT')
output sqlServerPassword string = sqlPassword
