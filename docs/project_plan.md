# Project Plan: Manuals

## Project Overview
**Project Name:** Manuals  
**Project Type:** Proof of Concept  
**Purpose:** Een systeem ontwikkelen om handleidingen van huishoudelijke apparaten op te slaan en te doorzoeken met natuurlijke taalvragen  
**GitHub Repository:** paulblabla/Manuals

## Doelstellingen
1. Handleidingen van huishoudelijke apparaten opslaan en catalogiseren
2. Natuurlijke taalvragen over apparaten kunnen beantwoorden
3. Eenvoudig nieuwe handleidingen kunnen uploaden
4. Schaalbaarheid en uitbreidbaarheid volgens best practices garanderen
5. Kosteneffectieve implementatie met Azure gratis tiers

## Technologie Stack

### Frontend
- React met TypeScript
- Redux voor state management
- Tailwind CSS voor UI componenten
- Vite voor packaging

### Backend
- ASP.NET Core 8.0 Web API met Minimal APIs
- C# als programmeertaal met gebruik van record types
- Entity Framework Core voor data access
- MediatR voor implementatie van Mediator pattern
- FluentValidation voor request validatie
- AutoMapper voor object mapping
- Global Exception Handling via middleware
- Swagger/OpenAPI voor API documentatie
- RESTful API design

### Database & Storage
- Azure SQL Database (Basic/Free Tier) - 2GB gratis storage
- Azure Blob Storage - 5GB gratis voor PDF-opslag
- Lichtgewicht vector search-implementatie voor semantisch zoeken

### Cloud Infrastructure
- Azure App Service (F1 Free tier) voor backend hosting
- Azure Static Web Apps voor frontend hosting
- Azure Application Insights (gratis tier - max 5GB/maand) voor monitoring
- GitHub Actions voor CI/CD
- Infrastructure as Code met Bicep templates

## Branching Strategie & Deployment Workflow

> **⚠️ BELANGRIJK: Alle ontwikkeling MOET plaatsvinden op feature branches! Directe commits op de main branch zijn niet toegestaan.**

### Branching Strategie
- `main` branch: bevat productie-waardige code (NOOIT direct op deze branch werken)
- Feature branches: `feature/naam-van-feature` voor nieuwe ontwikkelingen (bijv. `feature/initial-setup`, `feature/pdf-upload`)
- Bugfix branches: `bugfix/naam-van-bugfix` voor probleemoplossing (bijv. `bugfix/invalid-pdf-handling`)
- Hotfix branches: `hotfix/naam-van-hotfix` voor urgente fixes (bijv. `hotfix/security-vulnerability`)

### Verplichte Git Workflow
1. **Creëer een feature branch:**
   ```
   git checkout main
   git pull
   git checkout -b feature/mijn-nieuwe-feature
   ```

2. **Maak wijzigingen op je feature branch:**
   - Commit regelmatig met duidelijke commit messages
   - Push regelmatig naar origin om werk te bewaren

3. **Maak een Pull Request aan naar main:**
   - Schrijf een duidelijke beschrijving van de wijzigingen
   - Voer self-review uit
   - Wacht op automated checks

4. **Merge naar main:**
   - Na goedkeuring merge je de PR naar main
   - NOOIT direct naar main pushen

### Pull Request (PR) Workflow voor Single Developer
1. Ontwikkeling vindt plaats op feature branches
2. Bij voltooien feature:
   - PR aanmaken naar `main`
   - Automatische build en test wordt uitgevoerd
   - Self-review van de code
3. Na goedkeuring PR:
   - Merge naar `main` branch
   - Automatische CI/CD pipeline start

### Branch Protection Rules voor `main`
- Verplichte succesvolle status checks:
  - Build check
  - Test check
  - Code quality check
- Geen directe commits op `main` (altijd via PR)
- Geen force pushes op `main`

### CI/CD Pipeline
1. **PR Validatie:**
   - Build applicatie
   - Voer unit tests uit
   - Voer code quality checks uit

2. **Post-Merge Deployment:**
   - Build applicatie
   - Voer alle tests uit
   - Deploy infrastructuur met Bicep
   - Deploy applicatie naar Azure
   - Voer smoke tests uit

## Architectuur

### Core Entiteiten
- `Manual`: Informatie over handleidingen (titel, merk, model)
- `Device`: Apparaatinformatie (type, locatie in huis)
- `SearchIndex`: Geëxtraheerde en verwerkte inhoud voor zoeken
- `Question`: Veelgestelde vragen en antwoorden

### API Endpoints
- `/api/manuals` - CRUD operaties voor handleidingen
- `/api/devices` - CRUD operaties voor apparaten
- `/api/search` - Zoekopdrachten verwerken
- `/api/upload` - Handleidingen uploaden

### Vector Search Implementatie
- Open-source embedding modellen (zoals SentenceTransformers)
- Vectoropslag in Azure SQL Database
- Implementatie van similarity search in backend code

## Project Structuur

### Directory Structuur
```
/Manuals
  /docs                 # Projectdocumentatie
  /src
    /backend            # Backend projecten
      /Manuals.API
      /Manuals.Application
      /Manuals.Domain
      /Manuals.Infrastructure
    /frontend           # Frontend projecten
      /Manuals.Frontend
  /tests
    /backend            # Backend tests
      /Manuals.API.Tests
      /Manuals.Application.Tests
    /frontend           # Frontend tests  
      /Manuals.Frontend.Tests
  /infra                # Bicep templates
    /modules
    main.bicep
    parameters.*.json
  /scripts
  /tools
```

## Infrastructuur als Code (Bicep)

### Bicep Structuur
```
/infra
  /modules
    appservice.bicep
    database.bicep
    storage.bicep
    staticwebapp.bicep
  main.bicep
  parameters.dev.json
  parameters.prod.json
```

### Azure Resources (Free Tier)
- Azure SQL Database (Basic tier)
- Azure Blob Storage
- Azure App Service (F1 Free tier)
- Azure Static Web Apps (Free tier)

## Project Fasering

### Fase 1: Opzet & Architectuur (2-3 weken)
- GitHub repository opzetten
- Bicep templates ontwikkelen
- CI/CD workflows configureren
- Database schema ontwerpen
- API endpoints definiëren

### Fase 2: Core Infrastructuur (3-4 weken)
- Database implementatie
- Blob storage configuratie
- PDF upload en processing
- Document extractie logica
- Basis vector search implementeren

### Fase 3: Backend Implementatie (4-5 weken)
- API endpoints implementeren
- Entity Framework models
- PDF parsing en text extractie
- Zoekmechanisme implementeren
- Tests schrijven

### Fase 4: Frontend Implementatie (3-4 weken)
- React applicatie setup
- UI componenten
- PDF upload interface
- Zoekinterface
- Responsive design

### Fase 5: Testen & Optimalisatie (2-3 weken)
- End-to-end tests
- Performance optimalisatie
- Vector search verfijning
- UX verbeteringen

### Fase 6: Deployment & Documentatie (1-2 weken)
- Azure deployment finaliseren
- Gebruikersdocumentatie
- Technische documentatie
- Handleiding voor toekomstige uitbreidingen

## Beperkingen & Risico's van Gratis Tiers

- App Service Free tier heeft dagelijkse CPU-limiet van 60 minuten
- SQL Database Basic tier beperkt tot 2GB
- Application Insights beperkt tot 5GB data per maand (monitoring beperken indien nodig)
- Geen SLA's voor gratis diensten
- Lagere performance bij grotere datavolumes

## Success Criteria
1. Systeem kan minimaal 20 handleidingen opslaan en indexeren
2. Natuurlijke taalvragen geven relevante resultaten
3. Uploaden van nieuwe handleidingen werkt soepel
4. Volledig geautomatiseerde deployment via GitHub naar Azure
5. Codebase volgt best practices en is voorbereid op toekomstige uitbreidingen

## Toekomstige Uitbreidingen
1. Upgrade naar betaalde Azure tiers voor betere performance
2. Implementatie van geavanceerde Azure Cognitive Search
3. Integratie met Azure OpenAI voor verbeterde vraagbeantwoording
4. Mobiele app ontwikkeling
5. Integratie met smarthome systemen

## Volgende Stappen
1. GitHub repository aanmaken
2. Basis Bicep templates ontwikkelen
3. Database schema uitwerken
4. CI/CD workflows configureren
5. Eerste API endpoints implementeren

## Checklist voor Ontwikkelaars

Voor je begint met coderen:
- [ ] Werk altijd op een feature branch (NOOIT direct op main)
- [ ] Zorg dat je branch up-to-date is met main
- [ ] Zorg voor duidelijke commit messages
- [ ] Volg de naamgevingsconventies voor branches

Voor je een PR aanmaakt:
- [ ] Lokale tests uitvoeren en laten slagen
- [ ] Code formatteren volgens projectstandaarden
- [ ] Documentatie bijwerken waar nodig
- [ ] PR beschrijving volledig invullen
