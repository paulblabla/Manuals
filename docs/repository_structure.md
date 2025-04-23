# Repository en CI/CD Structuur

## Monorepo met Gerichte Workflows

Voor het Manuals project hanteren we een monorepo-benadering (alles in één repository), maar met gerichte CI/CD workflows om efficiëntie te waarborgen.

## Repository Structuur

```
/Manuals
  /docs                 # Projectdocumentatie
    project_plan.md
    aspnet_core_implementation.md
    application_insights_cost_management.md
    repository_structure.md
    ...
  /src
    /Manuals.API        # ASP.NET Core backend
    /Manuals.Frontend   # React frontend
    /Manuals.Application
    /Manuals.Domain
    /Manuals.Infrastructure
  /tests
    /Manuals.API.Tests
    /Manuals.Application.Tests
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
```

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
      - 'src/Manuals.API/**'
      - 'src/Manuals.Application/**'
      - 'src/Manuals.Domain/**'
      - 'src/Manuals.Infrastructure/**'
  pull_request:
    branches: [ main ]
    paths:
      - 'src/Manuals.API/**'
      - 'src/Manuals.Application/**'
      - 'src/Manuals.Domain/**'
      - 'src/Manuals.Infrastructure/**'

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
        run: dotnet publish src/Manuals.API/Manuals.API.csproj -c Release -o ${{env.DOTNET_ROOT}}/myapp
        
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
      - 'src/Manuals.Frontend/**'
  pull_request:
    branches: [ main ]
    paths:
      - 'src/Manuals.Frontend/**'

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
          cd src/Manuals.Frontend
          npm ci
          
      - name: Build
        run: |
          cd src/Manuals.Frontend
          npm run build
          
      - name: Test
        run: |
          cd src/Manuals.Frontend
          npm test
          
      - name: Deploy to Azure Static Web App
        if: github.event_name == 'push'
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "src/Manuals.Frontend/dist"
          api_location: ""
          output_location: ""
```

## Voordelen van deze Structuur

1. **Efficiëntie** - Alleen gewijzigde componenten worden gebouwd en gedeployed
2. **Snelheid** - Parallelle workflows voor onafhankelijke componenten
3. **Isolatie** - Wijzigingen aan één component beïnvloeden niet de deployment van andere componenten
4. **Overzicht** - Duidelijke organisatie van code en resources
5. **Schaalbaarheid** - Gemakkelijk uitbreidbaar naar meer componenten indien nodig

Deze structuur combineert de eenvoud van een monorepo met de efficiëntie van gerichte workflows die alleen triggeren wanneer relevante bestanden worden gewijzigd.