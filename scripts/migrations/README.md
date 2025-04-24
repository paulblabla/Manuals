# Database Migratie Scripts

Deze map bevat scripts om gemakkelijk Entity Framework migraties aan te maken en toe te passen op je database.

## Beschikbare Scripts

### 1. Add-Migration.bat

Dubbelklik op dit bestand om een nieuwe database migratie aan te maken. Je wordt gevraagd een naam voor de migratie in te voeren.

**Gebruik:** Voer dit script uit nadat je wijzigingen hebt aangebracht in de database modellen (entities).

### 2. Update-Database.bat

Dubbelklik op dit bestand om de database bij te werken met de meest recente migraties.

**Gebruik:** Voer dit script uit om je lokale database bij te werken na het aanmaken van een nieuwe migratie.

## Gebruik van PowerShell Scripts

De .bat bestanden zijn wrappers rond de volgende PowerShell scripts, die je ook direct kunt gebruiken:

### add-migration.ps1

```powershell
# Voer uit vanuit de PowerShell prompt
.\add-migration.ps1 -MigrationName "MijnNieuweMigratie"
```

### update-database.ps1

```powershell
# Voer uit vanuit de PowerShell prompt
.\update-database.ps1 -Environment "Development"
```

## Scripts opnemen in Visual Studio

Om deze scripts gemakkelijk vanuit Visual Studio te kunnen gebruiken:

1. Open de solution in Visual Studio
2. Rechtsklik op de solution in de Solution Explorer
3. Kies "Add > Existing Item..."
4. Navigeer naar de `scripts/migrations` map
5. Selecteer alle scripts en klik op "Add"

Nu kun je rechtsklikken op de scripts in Solution Explorer en "Open" kiezen om ze te bewerken, 
of "Open With > PowerShell ISE" om ze in PowerShell ISE te openen en uit te voeren.

## Azure Deployment

Voor Azure deployments worden migraties automatisch toegepast bij het opstarten van de applicatie 
via de `ApplicationDbContextInitializer` in `Program.cs`. Zorg ervoor dat je gegenereerde 
migraties naar GitHub pusht voordat je deployed naar Azure.
