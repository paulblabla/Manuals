@description('Script om SQL Database gebruikers in te stellen voor Managed Identity')
param location string = resourceGroup().location
param sqlServerName string
param sqlDatabaseName string
param sqlAdminUsername string
param keyVaultName string
param secretName string = 'sqlAdminPassword'
param appServiceName string
param appServicePrincipalId string

// TODO Haal password hier uit ketvault
resource sqlPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' existing = {
  name: '${keyVaultName}/${secretName}'
}


// DeploymentScript om SQL-gebruikers in te stellen
resource setupSqlUserScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'setupSqlUser-${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.40.0'
    timeout: 'PT30M'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'SQLSERVER'
        value: sqlServerName
      }
      {
        name: 'DATABASE'
        value: sqlDatabaseName
      }
      {
        name: 'ADMIN_USERNAME'
        value: sqlAdminUsername
      }
      {
        name: 'ADMIN_PASSWORD'
        value: sqlPasswordSecret.properties.value
      }
      {
        name: 'APPSERVICE_NAME'
        value: appServiceName
      }
      {
        name: 'PRINCIPAL_ID'
        value: appServicePrincipalId
      }
    ]
    scriptContent: '''
      #!/bin/bash
      
      # Installeren van sqlcmd en andere dependencies
      echo "Installeren van dependencies..."
      apt-get update
      apt-get install -y curl unixodbc gnupg
      
      # Microsoft repositories toevoegen voor MSSQL-tools
      curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
      curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
      apt-get update
      ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools
      echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
      source ~/.bashrc
      
      # Wachten tot SQL Server beschikbaar is
      echo "Wachten tot SQL Server beschikbaar is..."
      sleep 30
      
      # SQL-script aanmaken om de gebruiker in te stellen
      SQL_SCRIPT=$(cat <<EOF
      -- Maak de gebruiker aan op basis van managed identity
      IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'$APPSERVICE_NAME')
      BEGIN
          CREATE USER [$APPSERVICE_NAME] FROM EXTERNAL PROVIDER;
          ALTER ROLE db_datareader ADD MEMBER [$APPSERVICE_NAME];
          ALTER ROLE db_datawriter ADD MEMBER [$APPSERVICE_NAME];
          ALTER ROLE db_ddladmin ADD MEMBER [$APPSERVICE_NAME];
          PRINT 'Gebruiker $APPSERVICE_NAME aangemaakt en rechten toegekend.';
      END
      ELSE
      BEGIN
          PRINT 'Gebruiker $APPSERVICE_NAME bestaat al.';
      END
      GO
      EOF
      )
      
      echo "SQL Script uitvoeren..."
      echo "$SQL_SCRIPT" > setup_user.sql
      
      # SQL-script uitvoeren
      /opt/mssql-tools/bin/sqlcmd -S $SQLSERVER.database.windows.net -d $DATABASE -U $ADMIN_USERNAME -P $ADMIN_PASSWORD -i setup_user.sql
      
      if [ $? -eq 0 ]; then
          echo "SQL gebruiker succesvol ingesteld."
          echo "{ \"status\": \"success\" }" > $AZ_SCRIPTS_OUTPUT_PATH
      else
          echo "Fout bij het instellen van SQL gebruiker."
          echo "{ \"status\": \"failed\" }" > $AZ_SCRIPTS_OUTPUT_PATH
      fi
    '''
    cleanupPreference: 'OnSuccess'
    // Toegang tot KeyVault geven aan het script
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output status string = setupSqlUserScript.properties.outputs.status
