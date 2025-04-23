@description('Hoofd Bicep template voor Manuals project')
param location string = resourceGroup().location
param environmentName string

// Parameters voor gevoelige gegevens
@secure()
param sqlAdminUsername string
@secure()
param sqlAdminPassword string

// Modules importeren
module appInsights 'modules/applicationinsights.bicep' = {
  name: 'applicationInsightsDeployment'
  params: {
    location: location
    environmentName: environmentName
  }
}

module storage 'modules/storage.bicep' = {
  name: 'storageDeployment'
  params: {
    location: location
    environmentName: environmentName
  }
}

module database 'modules/database.bicep' = {
  name: 'databaseDeployment'
  params: {
    location: location
    environmentName: environmentName
    adminUsername: sqlAdminUsername
    adminPassword: sqlAdminPassword
  }
}

module appService 'modules/appservice.bicep' = {
  name: 'appServiceDeployment'
  params: {
    location: location
    environmentName: environmentName
  }
}

module staticWebApp 'modules/staticwebapp.bicep' = {
  name: 'staticWebAppDeployment'
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