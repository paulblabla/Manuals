@description('Role assignment voor SQL server toegang via Managed Identity')
param sqlServerName string
param principalId string
param principalType string = 'ServicePrincipal'

// Resource ID van de SQL Server
var sqlServerId = resourceId('Microsoft.Sql/servers', sqlServerName)

// SQL Server resource ophalen
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlServerName
}

// Role Assignment voor de App Service Managed Identity
// Dit geeft de service principal de SQL Contributor rol op de SQL Server
resource sqlRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, sqlServer.id, principalId, 'SqlContributor')
  scope: sqlServer
  properties: {
    principalId: principalId
    // SQL Contributor role
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '6d8ee4ec-f05a-4a1d-8b40-e833da248195')
    principalType: principalType
  }
}

output roleAssignmentId string = sqlRoleAssignment.id
output roleDefinitionId string = sqlRoleAssignment.properties.roleDefinitionId