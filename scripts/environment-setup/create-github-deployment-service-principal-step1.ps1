# Azure Service Principal Setup voor GitHub Deployment van Manuals Project

# Controleer of Azure CLI is geïnstalleerd
$azCliCheck = Get-Command az -ErrorAction SilentlyContinue
if (-not $azCliCheck) {
    Write-Error "Azure CLI is niet geïnstalleerd. Installeer Azure CLI eerst."
    exit 1
}

# Vaste naam voor de app
$appName = "Manuals-GitHub-Deployment"

# Inloggen in Azure (opent browser)
Write-Host "Logging in to Azure..." -ForegroundColor Green
az login

# Selecteer abonnement (optioneel)
$subscriptions = az account list --query "[].{name:name, id:id}" -o json | ConvertFrom-Json
if ($subscriptions.Length -gt 1) {
    Write-Host "Beschikbare abonnementen:" -ForegroundColor Yellow
    $subscriptions | Format-Table -AutoSize
    $selectedSubscription = Read-Host "Voer de naam of ID in van het abonnement dat je wilt gebruiken"
    az account set --subscription $selectedSubscription
}

# Verkrijg huidige abonnement ID
$subscriptionId = az account show --query id -o tsv

# Maak Azure AD App
Write-Host "Azure AD App wordt aangemaakt voor GitHub deployment..." -ForegroundColor Green
$appCreation = az ad app create --display-name $appName | ConvertFrom-Json
$appId = $appCreation.appId

# Maak Service Principal
Write-Host "Service Principal wordt aangemaakt voor GitHub deployment..." -ForegroundColor Green
$spCreation = az ad sp create-for-rbac --name $appName | ConvertFrom-Json

# Rol toewijzen
Write-Host "Contributor rol wordt toegewezen..." -ForegroundColor Green
$spObjectId = az ad sp show --id $appId --query id -o tsv
az role assignment create `
    --role Contributor `
    --subscription $subscriptionId `
    --assignee-object-id $spObjectId `
    --assignee-principal-type ServicePrincipal

# Toon resultaten
Write-Host "`nSetup Voltooid! Kopieer deze waarden voor GitHub Secrets:" -ForegroundColor Green
Write-Host "AZURE_CLIENT_ID: $appId" -ForegroundColor Cyan
Write-Host "AZURE_TENANT_ID: $($spCreation.tenant)" -ForegroundColor Cyan
Write-Host "AZURE_SUBSCRIPTION_ID: $subscriptionId" -ForegroundColor Cyan

# Waarschuwing over wachtwoord
Write-Host "`nLet op: Bewaar het Service Principal wachtwoord veilig!" -ForegroundColor Yellow
Write-Host "Wachtwoord: $($spCreation.password)" -ForegroundColor Red

Write-Host "`nVolgende stappen:" -ForegroundColor Yellow
Write-Host "1. Ga naar GitHub repository Settings > Secrets" -ForegroundColor White
Write-Host "2. Voeg deze secrets toe:" -ForegroundColor White
Write-Host "   - AZURE_CLIENT_ID: $appId" -ForegroundColor White
Write-Host "   - AZURE_TENANT_ID: $($spCreation.tenant)" -ForegroundColor White
Write-Host "   - AZURE_SUBSCRIPTION_ID: $subscriptionId" -ForegroundColor White