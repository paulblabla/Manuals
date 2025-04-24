# Script voor het aanmaken van een nieuwe database migratie
param(
    [string]$MigrationName = ""
)

# Pad naar de solution folder bepalen
$solutionRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
$infraProject = Join-Path -Path $solutionRoot -ChildPath "src\backend\Manuals.Infrastructure\Manuals.Infrastructure.csproj"
$startupProject = Join-Path -Path $solutionRoot -ChildPath "src\backend\Manuals.API\Manuals.API.csproj"
$migrationsFolder = Join-Path -Path $solutionRoot -ChildPath "src\backend\Manuals.Infrastructure\Persistence\Migrations"

Write-Host "Manuals Database Migratie Tool" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host "Solution pad: $solutionRoot" -ForegroundColor Gray

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

# Vraag om migratie naam als die niet is opgegeven
if ([string]::IsNullOrWhiteSpace($MigrationName)) {
    $MigrationName = Read-Host "Geef een naam voor de migratie (bijvoorbeeld: AddFieldToManual)"
}

# Controleer of de naam geldig is
if ([string]::IsNullOrWhiteSpace($MigrationName)) {
    Write-Host "Geen geldige migratie naam opgegeven. Het script wordt afgesloten." -ForegroundColor Red
    Write-Host "Druk op een toets om af te sluiten..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    exit 1
}

Write-Host "`nMigratie genereren: '$MigrationName'" -ForegroundColor Yellow

# Navigeer naar de solution root
Push-Location $solutionRoot

try {
    # Voer de EF migratie commando uit
    $command = "dotnet ef migrations add $MigrationName --project `"$infraProject`" --startup-project `"$startupProject`" --output-dir Persistence\Migrations"
    Write-Host "Uitvoeren: $command" -ForegroundColor Gray
    
    Invoke-Expression $command
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nMigratie succesvol aangemaakt!" -ForegroundColor Green
        
        # Toon de gegenereerde bestanden
        Write-Host "`nGegenereerde migratiebestanden:" -ForegroundColor Cyan
        Get-ChildItem -Path $migrationsFolder -Filter "*$MigrationName*" | ForEach-Object {
            Write-Host " - $($_.Name)" -ForegroundColor White
        }
        
        Write-Host "`nVergeet niet om de migratie toe te voegen aan Git:" -ForegroundColor Yellow
        Write-Host "git add `"src\backend\Manuals.Infrastructure\Persistence\Migrations`"" -ForegroundColor Gray
    }
    else {
        Write-Host "`nFout bij het aanmaken van de migratie. Controleer de foutmeldingen hierboven." -ForegroundColor Red
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
