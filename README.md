# Manuals

Een proof-of-concept applicatie voor het opslaan en doorzoeken van handleidingen van huishoudelijke apparaten met natuurlijke taalvragen.

## Projectstructuur

Het project gebruikt een schone architectuur met Domain-Driven Design principes:

```
/Manuals
  /docs                 # Projectdocumentatie
  /src
    /backend            # Backend code
      /Manuals.API        # ASP.NET Core Web API
      /Manuals.Application # Applicatielaag met commands en queries
      /Manuals.Domain     # Domeinlaag met entities en business regels
      /Manuals.Infrastructure # Infrastructuurlaag met database en services
    /frontend           # Frontend code
      /Manuals.Frontend   # React frontend
  /tests                # Unit en integratie tests
    /backend
    /frontend
  /infra                # Bicep templates voor Azure deployment
```

## Technologie Stack

- **Backend**: ASP.NET Core 8.0 met Minimal APIs, MediatR, FluentValidation, AutoMapper
- **Frontend**: React met TypeScript, Redux, Tailwind CSS
- **Database**: Azure SQL Database
- **Storage**: Azure Blob Storage voor PDF opslag
- **Cloud**: Azure App Service, Azure Static Web Apps
- **CI/CD**: GitHub Actions
- **IaC**: Bicep templates

## Lokale Ontwikkeling

### Vereisten

- .NET 8.0 SDK
- Node.js en npm
- SQL Server (LocalDB is voldoende)
- Azure Storage Emulator (Azurite)

### Backend Opstarten

```bash
cd src/backend/Manuals.API
dotnet restore
dotnet run
```

De API is beschikbaar op https://localhost:7082 en http://localhost:5095, Swagger documentatie op /swagger.

### Frontend Opstarten

```bash
cd src/frontend/Manuals.Frontend
npm install
npm run dev
```

De frontend is beschikbaar op http://localhost:5173.

## Features

- Handleidingen uploaden en catalogiseren
- Handleidingen koppelen aan apparaten
- Zoeken met natuurlijke taalvragen
- Semantisch zoeken met vector embeddings

## Branching Strategie

> **⚠️ BELANGRIJK: Alle ontwikkeling MOET plaatsvinden op feature branches! Directe commits op de main branch zijn niet toegestaan.**

Zie [branching_workflow.md](./docs/branching_workflow.md) voor details.

## Documentatie

Alle projectdocumentatie is beschikbaar in de `/docs` map:

- [Project Plan](./docs/project_plan.md)
- [ASP.NET Core Implementatie](./docs/aspnet_core_implementation.md)
- [Application Insights Kostenbeheer](./docs/application_insights_cost_management.md)
- [Repository Structuur](./docs/repository_structure.md)
- [Branching Workflow](./docs/branching_workflow.md)
- [Git Cheatsheet](./docs/git_cheatsheet.md)

## License

Dit project is eigendom van de ontwikkelaar en niet beschikbaar voor hergebruik zonder toestemming.
