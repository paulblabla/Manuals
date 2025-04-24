@description('Configure application settings en connection strings voor App Service')
param appServiceName string
param environmentName string
param appInsightsConnectionString string = ''
param sqlServerName string = ''
param sqlDatabaseName string = ''
param frontendBaseUrl string = 'https://app-manuals-frontend-${environmentName}.azurestaticapps.net'

// Bestaande App Service ophalen
resource webApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: appServiceName
}

// Application settings updaten
resource appSettings 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: webApp
  name: 'appsettings'
  properties: {
    // Basis app settings
    ASPNETCORE_ENVIRONMENT: environmentName
    
    // Application Insights settings
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
    
    // App specifieke settings
    'Frontend:BaseUrl': frontendBaseUrl
  }
}

// Connection strings configureren
resource connectionStrings 'Microsoft.Web/sites/config@2022-03-01' = if (!empty(sqlServerName) && !empty(sqlDatabaseName)) {
  parent: webApp
  name: 'connectionstrings'
  properties: {
    DefaultConnection: {
      value: 'Server=${sqlServerName}.database.windows.net;Database=${sqlDatabaseName};Authentication=Active Directory MSI;MultipleActiveResultSets=true;'
      type: 'SQLAzure'
    }
  }
}

output status string = 'App Service configuration updated'
