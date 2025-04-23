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
    
    // Daily cap configuration
    dailyQuotaInGB: dailyQuotaInGB
    
    // Sampling configuration
    samplingSettings: {
      samplingType: 'adaptive'
      maxTelemetryItemsPerSecond: 5
    }
  }
}

// Alert voor data cap
resource dailyCapAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'ai-datacap-alert-${environmentName}'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert wanneer Application Insights de datacap nadert'
    severity: 2
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT1H'
    windowSize: 'PT1H'
    criteria: {
      allOf: [
        {
          threshold: 4000000000  // 4GB (80% van 5GB)
          name: 'DataCapApproaching'
          metricNamespace: 'Microsoft.Insights/components'
          metricName: 'DataCapBytes'
          operator: 'GreaterThan'
          timeAggregation: 'Total'
        }
      ]
    }
    actions: []  // Geen extra acties in gratis tier
  }
}

output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsName string = appInsights.name
output appInsightsConnectionString string = appInsights.properties.ConnectionString