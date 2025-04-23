# Script om een Azure AD groep aan te maken voor SQL administratortoegang
# Deze groep kan worden gebruikt als SQL Admin voor alle omgevingen

# Parameters
param (
    [Parameter(Mandatory=$false)]
    [string]$GroupName = "SQL Database Administrators",
    
    [Parameter(Mandatory=$false)]
    [string]$GroupDescription = "Deze groep heeft administratortoegang tot SQL databases in het Manuals project"
)

# Controleer of Azure CLI is geïnstalleerd
$azCliCheck = Get-Command az -ErrorAction SilentlyContinue
if (-not $azCliCheck) {
    Write-Error "Azure CLI is niet geïnstalleerd. Installeer Azure CLI eerst."
    exit 1
}

# Inloggen in Azure (opent browser indien nog niet ingelogd)
Write-Host "Inloggen bij Azure indien nodig..." -ForegroundColor Green
az account show | Out-Null
if ($LASTEXITCODE -ne 0) {
    az login
}

# Controleer of groep al bestaat
Write-Host "Controleren of groep '$GroupName' al bestaat..." -ForegroundColor Yellow
$existingGroup = az ad group list --display-name $GroupName --query "[0].id" -o tsv

if ($existingGroup) {
    Write-Host "Groep '$GroupName' bestaat al met object ID: $existingGroup" -ForegroundColor Cyan
    
    # Ophalen van groepsleden
    Write-Host "Huidige groepsleden:" -ForegroundColor Yellow
    az ad group member list --group $GroupName --query "[].{Naam:displayName, Email:userPrincipalName}" -o table
    
    # Voeg de huidige gebruiker toe aan de groep als deze nog geen lid is
    $currentUser = az ad signed-in-user show --query "userPrincipalName" -o tsv
    $isMember = az ad group member check --group $GroupName --member-id $currentUser --query "value" -o tsv
    
    if ($isMember -eq "true") {
        Write-Host "Je bent al lid van de groep '$GroupName'" -ForegroundColor Green
    } else {
        Write-Host "Je wordt toegevoegd aan de groep '$GroupName'..." -ForegroundColor Yellow
        az ad group member add --group $GroupName --member-id $currentUser
        Write-Host "Je bent nu lid van de groep '$GroupName'" -ForegroundColor Green
    }
    
    Write-Host "`nGebruik de volgende object ID in je Bicep parameters:" -ForegroundColor Green
    Write-Host $existingGroup -ForegroundColor Cyan
} else {
    # Maak de groep aan
    Write-Host "Groep '$GroupName' wordt aangemaakt..." -ForegroundColor Yellow
    $newGroup = az ad group create --display-name $GroupName --description $GroupDescription --mail-nickname "SQLAdmins" | ConvertFrom-Json
    
    # Groep Object ID ophalen
    $groupObjectId = $newGroup.id
    
    Write-Host "Groep '$GroupName' is aangemaakt met object ID: $groupObjectId" -ForegroundColor Green
    
    # Voeg de huidige gebruiker toe aan de groep
    $currentUser = az ad signed-in-user show --query "id" -o tsv
    Write-Host "Je wordt toegevoegd aan de groep '$GroupName'..." -ForegroundColor Yellow
    az ad group member add --group $groupObjectId --member-id $currentUser
    
    Write-Host "`nGebruik de volgende object ID in je Bicep parameters:" -ForegroundColor Green
    Write-Host $groupObjectId -ForegroundColor Cyan
    
    Write-Host "`nPas deze waarde aan in de volgende bestanden:" -ForegroundColor Yellow
    Write-Host "- infra/parameters.dev.json" -ForegroundColor White
    Write-Host "- infra/parameters.test.json" -ForegroundColor White
    Write-Host "- infra/parameters.prod.json" -ForegroundColor White
}
