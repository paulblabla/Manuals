// Deployment op subscription niveau
targetScope = 'subscription'

@description('Hoofd Bicep template voor Manuals project')
param location string = 'westeurope'
param sqlLocation string = 'westeurope'
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

// Resource group aanmaken
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Key Vault aanmaken om secrets op te slaan
module keyVault 'modules/KeyVault.bicep' = {
  name: 'keyVaultDeployment'
  scope: resourceGroup
  params: {
    location: location
    environmentName: environmentName
    currentUserObjectId: sqlAdminGroupObjectId // Geef de SQL admin groep rechten op de Key Vault
  }
}

// SQL wachtwoord beheren (ophalen of genereren)
module sqlPassword 'modules/SqlPasswordManagement.bicep' = {
  name: 'sqlPasswordManagement'
  scope: resourceGroup
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'sqlAdminPassword'
    location: location
  }
  dependsOn: [
    keyVault
  ]
}

// Modules importeren
module appInsights 'modules/ApplicationInsights.bicep' = {
  name: 'applicationInsightsDeployment'
  scope: resourceGroup
  params: {
    location: location
    environmentName: environmentName
  }
}

module storage 'modules/Storage.bicep' = {
  name: 'storageDeployment'
  scope: resourceGroup
  params: {
    location: location
    environmentName: environmentName
  }
}

// Database module deployen 
module database 'modules/SqlDatabase.bicep' = {
  name: 'databaseDeployment'
  scope: resourceGroup
  params: {
    location: sqlLocation
    environmentName: environmentName
    adminUsername: sqlAdminUsername
    adminPassword: sqlPassword.outputs.sqlPassword
    adminGroupName: sqlAdminGroupName
    adminGroupObjectId: sqlAdminGroupObjectId
  }
}

// App Service module met Managed Identity
module appService 'modules/AppService.bicep' = {
  name: 'appServiceDeployment'
  scope: resourceGroup
  params: {
    location: location
    environmentName: environmentName
    sqlServerName: database.outputs.sqlServerName
    sqlDatabaseName: database.outputs.sqlDatabaseName
  }
}

// Role assignment voor App Service Managed Identity naar SQL
module sqlRoleAssignment 'modules/SqlRoleAssignment.bicep' = {
  name: 'sqlRoleAssignmentDeployment'
  scope: resourceGroup
  params: {
    sqlServerName: database.outputs.sqlServerName
    principalId: appService.outputs.appServicePrincipalId
  }
  dependsOn: [
    database
    appService
  ]
}

// SQL User aanmaken voor de Managed Identity
module sqlDbUser 'modules/SqlDatabaseUser.bicep' = {
  name: 'sqlDbUserDeployment'
  scope: resourceGroup
  params: {
    location: location
    sqlServerName: database.outputs.sqlServerName
    sqlDatabaseName: database.outputs.sqlDatabaseName
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: sqlPassword.outputs.sqlPassword
    appServiceName: appService.outputs.appServiceName
    appServicePrincipalId: appService.outputs.appServicePrincipalId
  }
  dependsOn: [
    sqlRoleAssignment
  ]
}

module staticWebApp 'modules/StaticWebApp.bicep' = {
  name: 'staticWebAppDeployment'
  scope: resourceGroup
  params: {
    location: location
    environmentName: environmentName
  }
}

// App Insights connection string instellen als App Setting
module appInsightsConfig 'modules/AppServiceConfig.bicep' = {
  name: 'appInsightsConfigDeployment'
  scope: resourceGroup
  params: {
    appServiceName: appService.outputs.appServiceName
    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
  }
  dependsOn: [
    appService
    appInsights
  ]
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
output isNewSqlPassword bool = sqlPassword.outputs.isNewPassword