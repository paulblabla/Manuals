@description('Key Vault waar het SQL wachtwoord is opgeslagen')
param keyVaultName string
param secretName string = 'sqlAdminPassword'
param location string = resourceGroup().location

resource keyVaultResource 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource checkPasswordScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'checkSqlPassword-${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.40.0'
    timeout: 'PT5M'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'KEYVAULT_NAME'
        value: keyVaultName
      }
      {
        name: 'SECRET_NAME'
        value: secretName
      }
      {
        name: 'SUBSCRIPTION_ID'
        value: subscription().subscriptionId
      }
      {
        name: 'RESOURCE_GROUP'
        value: resourceGroup().name
      }
      {
        name: 'DEPLOYMENT_NAME'
        value: deployment().name
      }
    ]
    scriptContent: '''
      #!/bin/bash
      
      # Controleer of het secret al bestaat
      SECRET_EXISTS=$(az keyvault secret list --vault-name $KEYVAULT_NAME --query "[?name=='$SECRET_NAME'].name" -o tsv)
      
      if [ -n "$SECRET_EXISTS" ]; then
        # Secret bestaat, gebruik bestaand wachtwoord
        echo "Secret bestaat al, bestaand wachtwoord wordt gebruikt"
        SECRET_VALUE=$(az keyvault secret show --vault-name $KEYVAULT_NAME --name $SECRET_NAME --query "value" -o tsv)
        echo "{ \"password\": \"$SECRET_VALUE\", \"isNew\": false }" > $AZ_SCRIPTS_OUTPUT_PATH
      else
        # Secret bestaat niet, genereer een nieuw wachtwoord
        echo "Secret bestaat niet, nieuw wachtwoord wordt gemaakt"
        
        # Genereer een sterk wachtwoord
        UNIQUE_STRING_1=$(echo -n "$SUBSCRIPTION_ID$RESOURCE_GROUP$DEPLOYMENT_NAME" | md5sum | head -c 8)
        UNIQUE_STRING_2=$(echo -n "$RESOURCE_GROUP$SUBSCRIPTION_ID" | md5sum | head -c 8)
        NEW_PASSWORD="${UNIQUE_STRING_1}${UNIQUE_STRING_2}Aa1!"
        
        # Sla het nieuwe wachtwoord op in Key Vault
        az keyvault secret set --vault-name $KEYVAULT_NAME --name $SECRET_NAME --value "$NEW_PASSWORD" > /dev/null
        echo "{ \"password\": \"$NEW_PASSWORD\", \"isNew\": true }" > $AZ_SCRIPTS_OUTPUT_PATH
      fi
    '''
    cleanupPreference: 'OnSuccess'
  }
}

// Verwijderd @secure() decorator omdat deze niet wordt ondersteund voor outputs
output sqlPassword string = json(checkPasswordScript.properties.outputs).password
output isNewPassword bool = json(checkPasswordScript.properties.outputs).isNew