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
module sqlPassword 'modules/SqlServerPasswordManagement.bicep' = {
  name: 'sqlPasswordManagement'
  scope: resourceGroup
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'sqlAdminPassword'
    location: location
  }
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

// SQL Server module deployen
module sqlServer 'modules/SqlServer.bicep' = {
  name: 'sqlServerDeployment'
  scope: resourceGroup
  params: {
    location: sqlLocation
    environmentName: environmentName
    adminUsername: sqlAdminUsername
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'sqlAdminPassword'
    adminGroupName: sqlAdminGroupName
    adminGroupObjectId: sqlAdminGroupObjectId
  }
  dependsOn:[
    sqlPassword
  ]
}

// SQL Database module deployen
module sqlDatabase 'modules/SqlDatabase.bicep' = {
  name: 'sqlDatabaseDeployment'
  scope: resourceGroup
  params: {
    location: sqlLocation
    sqlServerName: sqlServer.outputs.sqlServerName
    tags: tags
  }
}

// App Service module met Managed Identity
module appService 'modules/AppService.bicep' = {
  name: 'appServiceDeployment'
  scope: resourceGroup
  params: {
    location: location
    environmentName: environmentName
  }
}

// Role assignment voor App Service Managed Identity naar SQL
module sqlRoleAssignment 'modules/SqlServerRoleAssignment.bicep' = {
  name: 'sqlRoleAssignmentDeployment'
  scope: resourceGroup
  params: {
    sqlServerName: sqlServer.outputs.sqlServerName
    principalId: appService.outputs.appServicePrincipalId
  }
}

// SQL User aanmaken voor de Managed Identity
module sqlDbUser 'modules/SqlDatabaseUser.bicep' = {
  name: 'sqlDbUserDeployment'
  scope: resourceGroup
  params: {
    location: location
    sqlServerName: sqlServer.outputs.sqlServerName
    sqlDatabaseName: sqlDatabase.outputs.sqlDatabaseName
    sqlAdminUsername: sqlAdminUsername
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'sqlAdminPassword'
    appServiceName: appService.outputs.appServiceName
    appServicePrincipalId: appService.outputs.appServicePrincipalId
  }
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
    environmentName: environmentName
    appServiceName: appService.outputs.appServiceName
    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
  }
}

// Outputs verzamelen voor gebruik in andere scripts/configuraties
output appInsightsInstrumentationKey string = appInsights.outputs.appInsightsInstrumentationKey
output storageAccountName string = storage.outputs.storageAccountName
output sqlServerName string = sqlServer.outputs.sqlServerName
output sqlDatabaseName string = sqlDatabase.outputs.sqlDatabaseName
output appServiceName string = appService.outputs.appServiceName
output staticWebAppName string = staticWebApp.outputs.staticWebAppName
output resourceGroupName string = resourceGroup.name
output keyVaultName string = keyVault.outputs.keyVaultName
output keyVaultUri string = keyVault.outputs.keyVaultUri
