@description('App Service voor Manuals API')
param location string = resourceGroup().location
param environmentName string
param appServicePlanName string = 'asp-manuals-${environmentName}'
param appName string = 'app-manuals-api-${environmentName}'

var tags = {
  Environment: environmentName
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

// App Service Plan (Free Tier)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'F1'  // Free tier
    tier: 'Free'
  }
  kind: 'app'
  properties: {
    zoneRedundant: false
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  tags: tags
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0'  // .NET 8.0
      alwaysOn: false  // Niet beschikbaar in Free tier
      ftpsState: 'Disabled'  // FTPS uitschakelen voor extra beveiliging
      minTlsVersion: '1.2'  // Minimale TLS versie
      
      // Basis app settings
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environmentName
        }
      ]
    }
  }

  // Basis web config voor extra beveiliging
  resource webConfig 'config' = {
    name: 'web'
    properties: {
      httpLoggingEnabled: true
      remoteDebuggingEnabled: false
    }
  }
}

output appServiceName string = webApp.name
output appServiceId string = webApp.id
output appServiceHostName string = webApp.properties.defaultHostName