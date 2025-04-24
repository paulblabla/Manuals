# Script voor het bijwerken van de database met de nieuwste migratie
param(
    [string]$Environment = "Development"
)

# Pad naar de solution folder bepalen
$solutionRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
$infraProject = Join-Path -Path $solutionRoot -ChildPath "src\backend\Manuals.Infrastructure\Manuals.Infrastructure.csproj"
$startupProject = Join-Path -Path $solutionRoot -ChildPath "src\backend\Manuals.API\Manuals.API.csproj"

Write-Host "Manuals Database Update Tool" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
Write-Host "Solution pad: $solutionRoot" -ForegroundColor Gray
Write-Host "Omgeving: $Environment" -ForegroundColor Gray

# Controleer op dotnet ef tool
try {
    $efVersion = dotnet ef --version
    Write-Host "Entity Framework Core Tools versie: $efVersion" -ForegroundColor Green
}
catch {
    Write-Host "Entity Framework Core Tools niet gevonden. Deze wordt nu geïnstalleerd..." -ForegroundColor Yellow
    dotnet tool install --global dotnet-ef
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installatie van EF Core Tools mislukt. Zorg dat je .NET SDK hebt geïnstalleerd." -ForegroundColor Red
        Write-Host "Druk op een toets om af te sluiten..."
        $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        exit 1
    }
}

# Vraag om bevestiging
Write-Host "`nJe staat op het punt de database bij te werken met de laatste migraties." -ForegroundColor Yellow
$confirm = Read-Host "Weet je zeker dat je door wilt gaan? (j/n)"

if ($confirm.ToLower() -ne "j" -and $confirm.ToLower() -ne "ja") {
    Write-Host "Update geannuleerd." -ForegroundColor Yellow
    Write-Host "Druk op een toets om af te sluiten..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    exit 0
}

# Navigeer naar de solution root
Push-Location $solutionRoot

try {
    # Toon pending migrations
    Write-Host "`nControleren op pending migraties..." -ForegroundColor Yellow
    $pendingCommand = "dotnet ef migrations list --project `"$infraProject`" --startup-project `"$startupProject`" --environment $Environment"
    Write-Host "Uitvoeren: $pendingCommand" -ForegroundColor Gray
    
    Invoke-Expression $pendingCommand
    
    # Voer de update uit
    Write-Host "`nDatabase bijwerken..." -ForegroundColor Yellow
    $command = "dotnet ef database update --project `"$infraProject`" --startup-project `"$startupProject`" --environment $Environment"
    Write-Host "Uitvoeren: $command" -ForegroundColor Gray
    
    Invoke-Expression $command
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nDatabase succesvol bijgewerkt!" -ForegroundColor Green
    }
    else {
        Write-Host "`nFout bij het bijwerken van de database. Controleer de foutmeldingen hierboven." -ForegroundColor Red
    }
}
catch {
    Write-Host "Er is een fout opgetreden: $_" -ForegroundColor Red
}
finally {
    # Ga terug naar de oorspronkelijke directory
    Pop-Location
    
    Write-Host "`nDruk op een toets om af te sluiten..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}
