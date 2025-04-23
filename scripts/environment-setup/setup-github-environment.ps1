# Hoofd setup script voor GitHub Environment
# Dit script maakt de benodigde gegevens voor een GitHub environment aan
# Parameters kunnen worden doorgegeven vanuit omgevingsspecifieke scripts

param (
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName,
    
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [string]$GithubOrg = "paulblabla",
    [string]$GithubRepo = "Manuals"
)

# Vaste parameter
$RoleName = "Contributor"

# Functie om JSON-bestand voor federated credential te maken
function Create-FederatedCredentialJson {
    param (
        [string]$name,
        [string]$issuer,
        [string]$subject,
        [string]$description
    )
    
    $credentialContent = @{
        name = $name
        issuer = $issuer
        subject = $subject
        description = $description
        audiences = @("api://AzureADTokenExchange")
    } | ConvertTo-Json
    
    $tempJsonFile = Join-Path $PSScriptRoot "credential.json"
    $credentialContent | Out-File -FilePath $tempJsonFile -Encoding utf8
    
    return $tempJsonFile
}

# ======== SETUP STARTEN ========
Write-Host "Setup starten voor environment: $EnvironmentName" -ForegroundColor Green
Write-Host "Subscription ID: $SubscriptionId" -ForegroundColor Cyan
Write-Host "Application Name: $AppName" -ForegroundColor Cyan

# Controleer of Azure CLI is geïnstalleerd
$azCliCheck = Get-Command az -ErrorAction SilentlyContinue
if (-not $azCliCheck) {
    Write-Error "Azure CLI is niet geïnstalleerd. Installeer Azure CLI eerst."
    exit 1
}

# Inloggen in Azure (opent browser)
Write-Host "Logging in to Azure..." -ForegroundColor Green
az login

# Selecteer specifieke subscription
Write-Host "Specifieke subscription selecteren..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId

# Controleer of juiste subscription is geselecteerd
$currentSub = az account show --query id -o tsv
if ($currentSub -ne $SubscriptionId) {
    Write-Error "Kon niet switchen naar de juiste subscription. Controleer of ID $SubscriptionId correct is."
    exit 1
}

# ======== SERVICE PRINCIPAL AANMAKEN ========
Write-Host "Service Principal aanmaken..." -ForegroundColor Green

# Controleer of app al bestaat
$existingApp = az ad app list --display-name $AppName --query "[0].appId" -o tsv
if ($existingApp) {
    Write-Host "App '$AppName' bestaat al met ID: $existingApp" -ForegroundColor Yellow
    $appId = $existingApp
} else {
    # Maak Azure AD App
    Write-Host "Azure AD App wordt aangemaakt voor GitHub deployment..." -ForegroundColor Green
    $appCreation = az ad app create --display-name $AppName | ConvertFrom-Json
    $appId = $appCreation.appId

    # Maak Service Principal
    Write-Host "Service Principal wordt aangemaakt..." -ForegroundColor Green
    $spCreation = az ad sp create --id $appId | ConvertFrom-Json
    
    # Even wachten tot service principal beschikbaar is in het systeem
    Write-Host "Even wachten tot Service Principal beschikbaar is..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
}

# ======== FEDERATED CREDENTIALS TOEVOEGEN ========
Write-Host "Federated Credentials toevoegen..." -ForegroundColor Green

# Federated credential naam gebaseerd op environment
$federatedCredentialName = "GitHub-Actions-$EnvironmentName"

# Maak JSON bestand voor de federated credential
$subject = "repo:$GithubOrg/$GithubRepo:environment:$EnvironmentName"
$credentialJsonPath = Create-FederatedCredentialJson -name $federatedCredentialName `
                                                   -issuer "https://token.actions.githubusercontent.com" `
                                                   -subject $subject `
                                                   -description "GitHub Actions for $EnvironmentName Environment"

# Controleer of federated credential al bestaat
$existingCred = az ad app federated-credential list --id $appId --query "[?name=='$federatedCredentialName'].name" -o tsv
if ($existingCred) {
    Write-Host "Federated credential '$federatedCredentialName' bestaat al. Wordt opnieuw aangemaakt..." -ForegroundColor Yellow
    az ad app federated-credential delete --id $appId --federated-credential-id $federatedCredentialName
}

# Voeg Federated Credentials toe
Write-Host "Federated credential wordt toegevoegd voor $AppName..." -ForegroundColor Green
az ad app federated-credential create --id $appId --parameters "@$credentialJsonPath"

# ======== RBAC RECHTEN TOEWIJZEN ========
Write-Host "RBAC-rechten toewijzen..." -ForegroundColor Green

# Verkrijg de Service Principal object ID
Write-Host "Service Principal object ID wordt opgehaald..." -ForegroundColor Green
$spObjectId = az ad sp list --display-name $AppName --query "[0].id" -o tsv

if (-not $spObjectId) {
    Write-Error "De Service Principal '$AppName' kon niet worden gevonden. Controleer of deze correct is aangemaakt."
    exit 1
}

# RBAC toewijzen op subscription niveau
$subScope = "/subscriptions/$SubscriptionId"
Write-Host "RBAC-rechten toewijzen op subscription niveau..." -ForegroundColor Yellow
az role assignment create --assignee-object-id $spObjectId `
                         --assignee-principal-type ServicePrincipal `
                         --role $RoleName `
                         --scope $subScope `
                         --only-show-errors

# ======== VOLTOOIDE SETUP ========
Write-Host "`n===== SETUP VOLTOOID VOOR ENVIRONMENT: $EnvironmentName =====" -ForegroundColor Green
Write-Host "Service Principal '$AppName' is aangemaakt en geconfigureerd" -ForegroundColor Green
Write-Host "Federated credentials zijn ingesteld voor GitHub Actions met environment '$EnvironmentName'" -ForegroundColor Green
Write-Host "RBAC-rechten 'Contributor' zijn toegewezen op subscription niveau" -ForegroundColor Green

Write-Host "`nBenodigde GitHub Secrets:" -ForegroundColor Yellow
Write-Host "AZURE_CLIENT_ID: $appId" -ForegroundColor Cyan
Write-Host "AZURE_TENANT_ID: $(az account show --query tenantId -o tsv)" -ForegroundColor Cyan
Write-Host "AZURE_SUBSCRIPTION_ID: $SubscriptionId" -ForegroundColor Cyan

Write-Host "`nVolgende stappen:" -ForegroundColor Yellow
Write-Host "1. Voeg de bovenstaande secrets toe aan je GitHub repository (Settings > Secrets > Actions)" -ForegroundColor White
Write-Host "2. Maak een '$EnvironmentName' environment aan in GitHub (Settings > Environments)" -ForegroundColor White
Write-Host "3. Start je GitHub Actions workflow" -ForegroundColor White

# Cleanup
if (Test-Path $credentialJsonPath) {
    Remove-Item -Path $credentialJsonPath -Force
}
