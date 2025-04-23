@description('Application Insights configuratie voor Manuals project')
param location string = resourceGroup().location
param environmentName string
param dailyQuotaInGB int = 4  // Net onder de 5GB limiet

var tags = {
  Environment: environmentName
  Project: 'Manuals'
  ManagedBy: 'Bicep'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-manuals-${environmentName}'
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
  }
}

output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsName string = appInsights.name
output appInsightsConnectionString string = appInsights.properties.ConnectionString