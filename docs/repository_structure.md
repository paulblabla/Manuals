# Repository en CI/CD Structuur

## Monorepo met Gerichte Workflows

Voor het Manuals project hanteren we een monorepo-benadering (alles in één repository), maar met gerichte CI/CD workflows om efficiëntie te waarborgen.

> **⚠️ BELANGRIJK: Alle ontwikkeling MOET plaatsvinden volgens de branch strategie beschreven in [branching_workflow.md](./branching_workflow.md). Nooit direct op de main branch werken!**

## Repository Structuur

```
/Manuals
  /docs                 # Projectdocumentatie
    project_plan.md
    aspnet_core_implementation.md
    application_insights_cost_management.md
    repository_structure.md
    branching_workflow.md        # Gedetailleerde Git workflow
    git_cheatsheet.md            # Handige Git commando's
    ...
  /src
    /backend            # Backend code
      /Manuals.API        # ASP.NET Core backend
      /Manuals.Application
      /Manuals.Domain
      /Manuals.Infrastructure
    /frontend           # Frontend code
      /Manuals.Frontend   # React frontend
  /tests
    /backend            # Backend tests
      /Manuals.API.Tests
      /Manuals.Application.Tests
    /frontend           # Frontend tests
      /Manuals.Frontend.Tests
    ...
  /infra                # Bicep templates
    /modules
      appservice.bicep
      database.bicep
      storage.bicep
      staticwebapp.bicep
    main.bicep
    parameters.dev.json
    parameters.prod.json
  /scripts              # Hulpscripts voor het project
  /tools                # Tooling voor ontwikkeling
  /.github
    /workflows
      frontend.yml      # Alleen voor frontend wijzigingen
      backend.yml       # Alleen voor backend wijzigingen
      infrastructure.yml # Alleen voor infrastructure wijzigingen
      branch_enforce.yml # Controleer op juiste branch naamgeving
```

## Branching Strategie

We hanteren een strikte branching strategie:

1. **Main Branch**: Bevat altijd productie-waardige code
2. **Feature Branches**: Voor alle nieuwe ontwikkelingen (`feature/naam-van-feature`)
3. **Bugfix Branches**: Voor het oplossen van bugs (`bugfix/naam-van-bugfix`)
4. **Hotfix Branches**: Voor urgente fixes (`hotfix/naam-van-hotfix`)

Alle wijzigingen worden via Pull Requests geïntegreerd in de main branch, **nooit** via directe commits. Zie [branching_workflow.md](./branching_workflow.md) voor volledige details.

## GitHub Actions Workflows met Path Filters

### 1. Infrastructure Workflow (.github/workflows/infrastructure.yml)

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [ main ]
    paths:
      - 'infra/**'
  pull_request:
    branches: [ main ]
    paths:
      - 'infra/**'

jobs:
  deploy-infrastructure:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
          
      - name: Deploy Bicep
        uses: azure/arm-deploy@v1
        with:
          subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
          resourceGroupName: ${{ secrets.AZURE_RG }}
          template: ./infra/main.bicep
          parameters: ./infra/parameters.dev.json
```

### 2. Backend Workflow (.github/workflows/backend.yml)

```yaml
name: Build and Deploy Backend

on:
  push:
    branches: [ main ]
    paths:
      - 'src/backend/Manuals.API/**'
      - 'src/backend/Manuals.Application/**'
      - 'src/backend/Manuals.Domain/**'
      - 'src/backend/Manuals.Infrastructure/**'
  pull_request:
    branches: [ main ]
    paths:
      - 'src/backend/Manuals.API/**'
      - 'src/backend/Manuals.Application/**'
      - 'src/backend/Manuals.Domain/**'
      - 'src/backend/Manuals.Infrastructure/**'

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
          
      - name: Restore dependencies
        run: dotnet restore
        
      - name: Build
        run: dotnet build --no-restore
        
      - name: Test
        run: dotnet test --no-build --verbosity normal
        
  deploy:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
          
      - name: Publish
        run: dotnet publish src/backend/Manuals.API/Manuals.API.csproj -c Release -o ${{env.DOTNET_ROOT}}/myapp
        
      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: 'manuals-api-dev'
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
          package: ${{env.DOTNET_ROOT}}/myapp
```

### 3. Frontend Workflow (.github/workflows/frontend.yml)

```yaml
name: Build and Deploy Frontend

on:
  push:
    branches: [ main ]
    paths:
      - 'src/frontend/Manuals.Frontend/**'
  pull_request:
    branches: [ main ]
    paths:
      - 'src/frontend/Manuals.Frontend/**'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: |
          cd src/frontend/Manuals.Frontend
          npm ci
          
      - name: Build
        run: |
          cd src/frontend/Manuals.Frontend
          npm run build
          
      - name: Test
        run: |
          cd src/frontend/Manuals.Frontend
          npm test
          
      - name: Deploy to Azure Static Web App
        if: github.event_name == 'push'
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "src/frontend/Manuals.Frontend/dist"
          api_location: ""
          output_location: ""
```

### 4. Branch Naming Enforcement (.github/workflows/branch_enforce.yml)

```yaml
name: Branch Naming Convention Check

on:
  push:
    branches-ignore:
      - main

jobs:
  check-branch-name:
    runs-on: ubuntu-latest
    steps:
      - name: Check branch name
        run: |
          BRANCH_NAME=${GITHUB_REF#refs/heads/}
          echo "Branch name: $BRANCH_NAME"
          
          if [[ ! "$BRANCH_NAME" =~ ^(feature|bugfix|hotfix|release)/[a-z0-9-]+$ ]]; then
            echo "ERROR: Branch naam voldoet niet aan de naamgevingsconventie."
            echo "Branch namen moeten beginnen met 'feature/', 'bugfix/', 'hotfix/' of 'release/' gevolgd door een beschrijvende naam met kleine letters, cijfers en streepjes."
            echo "Bijvoorbeeld: feature/pdf-upload, bugfix/login-error, hotfix/security-fix"
            exit 1
          fi
          
          echo "Branch naam voldoet aan de conventie!"
```

## Volledige CI/CD Pijplijn

1. Ontwikkelaar maakt feature branch aan
2. Code wordt ontwikkeld en lokaal getest
3. PR wordt aangemaakt naar main
4. Automatische checks:
   - Branch naming convention
   - Build en tests
   - Code quality checks
5. Na goedkeuring wordt PR gemerged
6. Path-specifieke workflows worden getriggerd
7. Code wordt automatisch gedeployed naar ontwikkelomgeving

## Voordelen van deze Structuur

1. **Efficiëntie** - Alleen gewijzigde componenten worden gebouwd en gedeployed
2. **Snelheid** - Parallelle workflows voor onafhankelijke componenten
3. **Isolatie** - Wijzigingen aan één component beïnvloeden niet de deployment van andere componenten
4. **Overzicht** - Duidelijke organisatie van code en resources
5. **Schaalbaarheid** - Gemakkelijk uitbreidbaar naar meer componenten indien nodig
6. **Kwaliteitscontrole** - Geautomatiseerde controle van branch naming en code kwaliteit
7. **Veiligheidsniveau** - Bescherming van de main branch tegen directe wijzigingen

## Optimale Ontwikkelworkflow

1. **Start**: Begin altijd met een up-to-date feature branch
2. **Ontwikkel**: Maak kleinere, frequente commits met duidelijke messages
3. **Test**: Test lokaal voordat je wijzigingen pusht
4. **Update**: Houd je branch up-to-date met main om merge conflicts te minimaliseren
5. **PR**: Creëer een PR met duidelijke beschrijving van wijzigingen
6. **Review**: Voer een self-review uit en wacht op automatische checks
7. **Merge**: Na goedkeuring kan de PR worden gemerged
8. **Deployment**: Automatische deployment via de juiste workflow

Deze structuur combineert de eenvoud van een monorepo met de efficiëntie van gerichte workflows die alleen triggeren wanneer relevante bestanden worden gewijzigd, terwijl de kwaliteit van de code wordt bewaakt via een strikte branching strategie.
