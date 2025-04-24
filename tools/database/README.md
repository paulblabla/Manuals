# Database Migratie Tool

Deze tool maakt het eenvoudig om Entity Framework migraties aan te maken voor de Manuals applicatie.

## Gebruik

1. **Dubbelklik op `Add-Migration.bat`** in Visual Studio Solution Explorer
2. **Voer een naam in** voor de migratie (bijv. "AddFieldToManual")
3. **Wacht** tot de migratie is aangemaakt
4. De migraties worden **automatisch toegepast** op de database bij de volgende keer opstarten van de applicatie

## Wat het script doet

Het script:
- Controleert of Entity Framework Core tools zijn geïnstalleerd
- Vraagt om een naam voor de migratie
- Maakt een nieuwe migratie aan in de juiste map
- Toont de gegenereerde bestanden

## Voorbeeld migratie namen

Enkele voorbeelden van goede migratie namen:
- `AddSearchIndexTable`
- `UpdateDeviceFields`
- `AddRelationshipBetweenManualAndDevice`
- `AddFileTypeColumn`

## Hoe werkt de deployment naar Azure?

Migraties worden automatisch toegepast bij het opstarten van de applicatie door de `ApplicationDbContextInitializer` in `Program.cs`. 

Wanneer je een nieuwe versie van de applicatie deployt naar Azure via de CI/CD pipeline, worden ontbrekende migraties automatisch toegepast tijdens het opstarten.

## Belangrijk

- Zorg dat je je wijzigingen in de code hebt aangebracht **voordat** je de migratie aanmaakt
- Vergeet niet om de gegenereerde migratiebestanden in Git te committen
- Migraties worden opgeslagen in `src/backend/Manuals.Infrastructure/Persistence/Migrations`
