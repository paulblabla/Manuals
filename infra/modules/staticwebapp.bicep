@description('Static Web App voor Manuals Frontend')
param location string = resourceGroup().location
param environmentName string
param appName string = 'stapp-manuals-${environmentName}'

var tags = {
  Environment: environmentName
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: appName
  location: location
  tags: tags
  sku: {
    name: 'Free'  // Free tier voor statische website
    tier: 'Free'
  }
  properties: {}
}

output staticWebAppName string = staticWebApp.name
output staticWebAppId string = staticWebApp.id
output staticWebAppDefaultHostname string = staticWebApp.properties.defaultHostname