# Azure AD App Federated Credentials toevoegen
$appName = "Manuals-GitHub-Deployment"

# Verkrijg de App ID
$appId = az ad app list --display-name $appName --query "[0].appId" -o tsv

# GitHub Organization en Repository
$githubOrg = "paulblabla"
$githubRepo = "Manuals"

# Pad naar het credential bestand
$credentialFilePath = Join-Path $PSScriptRoot "credential.json"

# Genereer de credential JSON inhoud
$credentialContent = @{
  name = "GitHub-Actions-Development"
  issuer = "https://token.actions.githubusercontent.com"
  subject = "repo:$githubOrg/$githubRepo:environment:development"
  description = "GitHub Actions for Development Environment"
  audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json

# Schrijf naar bestand
$credentialContent | Out-File -FilePath $credentialFilePath -Encoding utf8

# Voeg Federated Credentials toe
Write-Host "Federated credential wordt toegevoegd voor $appName..." -ForegroundColor Green
az ad app federated-credential create --id $appId --parameters $credentialFilePath

Write-Host "Federated credential is succesvol toegevoegd!" -ForegroundColor Green
