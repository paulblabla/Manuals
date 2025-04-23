# Branching Strategie en Workflow

## Overzicht

Dit document beschrijft de vereiste werkwijze voor alle ontwikkelaars die aan het Manuals project werken. Het volgen van deze richtlijnen is **verplicht** om code-integriteit en projectconsistentie te waarborgen.

## Gouden Regel: Nooit Direct op Main

> **⚠️ NOOIT DIRECT OP DE MAIN BRANCH WERKEN**

De belangrijkste regel van dit project is dat er **nooit** direct op de main branch gewerkt mag worden. Alle ontwikkeling - zelfs kleinere wijzigingen zoals documentatie-updates - moet verlopen via feature branches en pull requests.

## Branch Types

We gebruiken de volgende typen branches:

| Branch Type | Naamgeving | Doel | Voorbeeld |
|-------------|------------|------|-----------|
| **Main** | `main` | Productie-waardige code | |
| **Feature** | `feature/naam-van-feature` | Nieuwe functionaliteit ontwikkelen | `feature/pdf-upload` |
| **Bugfix** | `bugfix/naam-van-bug` | Bug oplossen | `bugfix/crash-op-lange-titels` |
| **Hotfix** | `hotfix/naam-van-fix` | Kritieke problemen direct oplossen | `hotfix/security-vulnerability` |
| **Release** | `release/versienummer` | Voorbereiden voor release | `release/1.0.0` |

## Stap-voor-stap Workflow

### 1. Update je lokale main branch

Voordat je een nieuwe feature branch aanmaakt, zorg ervoor dat je lokale main branch up-to-date is:

```bash
git checkout main
git pull origin main
```

### 2. Maak een nieuwe feature branch

Maak een nieuwe branch aan met een duidelijke, beschrijvende naam:

```bash
git checkout -b feature/mijn-nieuwe-functie
```

Enkele voorbeelden van goede branchnamen:
- `feature/manual-upload-api`
- `feature/search-results-pagination`
- `bugfix/incorrect-search-results`

### 3. Werk op je feature branch

Ontwikkel je functionaliteit op de feature branch. Commit regelmatig met duidelijke, beschrijvende commit messages:

```bash
git add .
git commit -m "Implementeer PDF validatie voor manual uploads"
```

Push regelmatig naar de remote repository om je werk te beveiligen:

```bash
git push -u origin feature/mijn-nieuwe-functie
```

### 4. Pull Request aanmaken

Wanneer je feature compleet is:

1. Zorg dat je branch up-to-date is met main:
   ```bash
   git checkout main
   git pull origin main
   git checkout feature/mijn-nieuwe-functie
   git merge main
   ```

2. Los eventuele merge conflicts op

3. Push je final changes:
   ```bash
   git push origin feature/mijn-nieuwe-functie
   ```

4. Maak een Pull Request aan via GitHub:
   - Geef een duidelijke titel
   - Beschrijf wat je feature doet
   - Vermeld eventuele aandachtspunten

### 5. Code Review en Merge

1. Voer een self-review uit van je eigen code
2. Wacht tot de automatische checks (CI/CD) zijn voltooid
3. Als alles goed is, merge je PR naar main

## Visualisatie van de Workflow

```
main        --o------o---------o-----------o-->
              \      ^         ^           ^
               \    /         /           /
feature/A       o--o         /           /
                      \     /           /
feature/B               o--o           /
                                \     /
feature/C                         o--o
```

## Veel Voorkomende Fouten

| Fout | Waarom het een probleem is | Hoe het te voorkomen |
|------|----------------------------|----------------------|
| Direct op main committen | Omzeilt de review proces, kan bugs introduceren | **Altijd** op een feature branch werken |
| Te lange feature branches | Moeilijk te mergen, meer conflicts | Kleinere, gefocuste features maken |
| Vage branch namen | Moeilijk te begrijpen doel van de branch | Gebruik duidelijke, beschrijvende namen |
| Niet regelmatig pushen | Risico op verlies van werk | Push minstens dagelijks naar origin |

## Merge Conflicts Oplossen

Als je een merge conflict tegenkomt:

1. Identificeer de conflicterende bestanden:
   ```bash
   git status
   ```

2. Open de bestanden en los de conflicten op (kijk naar de markering met `<<<<<<< HEAD`, `=======`, en `>>>>>>> branch-name`)

3. Voeg de opgeloste bestanden toe:
   ```bash
   git add <bestandsnaam>
   ```

4. Voltooi de merge:
   ```bash
   git commit
   ```

## Conclusie

Het consequent volgen van deze branching strategie en workflow zal leiden tot:
- Hogere code kwaliteit
- Minder bugs in de main branch
- Betere traceerbaarheid van wijzigingen
- Effectievere samenwerking

**Onthoud: Werk nooit direct op de main branch. Altijd via feature branches en pull requests!**
