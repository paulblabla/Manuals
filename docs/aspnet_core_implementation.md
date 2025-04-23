# ASP.NET Core Implementatie met CQRS en Minimal APIs

## Architectural Approach

Voor de ASP.NET Core backend zullen we de CQRS (Command Query Responsibility Segregation) pattern implementeren met behulp van MediatR, FluentValidation en AutoMapper. Deze combinatie biedt een schone, onderhoudbare en testbare codebase.

## Belangrijkste Features

### Minimal APIs
In plaats van traditionele controllers gebruiken we Minimal APIs voor eenvoudigere endpoints:
- Minder boilerplate code
- Directe integratie met dependency injection
- Betere performance
- Moderne C# features zoals record types

### Record Types voor DTOs
We gebruiken C# record types voor DTOs:
- Immutability garandeert data-integriteit
- Minder code (automatische implementatie van Equals, GetHashCode, etc.)
- Betere ondersteuning voor pattern matching
- Natural support voor deconstruction

### Global Exception Handling via Middleware
Excepties worden consistent afgehandeld via middleware:
- Centrale plek voor alle exceptie-afhandeling
- Consistente foutrespons formaat (Problem Details)
- Gedetailleerde logging van excepties
- Gebruiksvriendelijke foutmeldingen voor clients

### MediatR
MediatR implementeert het Mediator pattern en maakt het mogelijk om:
- Commands en queries te scheiden
- Single-responsibility principe te handhaven
- Cross-cutting concerns (zoals logging, validatie) via behaviors toe te voegen
- Request/response handlers te isoleren voor betere testbaarheid

### FluentValidation
FluentValidation zorgt voor:
- Declaratieve validatieregels
- Separatie van business logic en validatielogica
- Herbruikbare validatieregels
- Robuuste input validatie

### AutoMapper
AutoMapper zorgt voor:
- Clean mapping tussen domein modellen en DTOs
- Minder boilerplate code
- Consistente object transformaties

## Implementatie Structuur

```
/src
  /Manuals.API              # ASP.NET Core Web API project
    /Endpoints              # Gegroepeerde Minimal API endpoints
    /Models                 # API models/DTOs als record types
    /Middleware             # Custom middleware zoals exception handling
  
  /Manuals.Application      # Application logic
    /Commands               # Write operations
      /CreateManual         
        CreateManualCommand.cs
        CreateManualCommandHandler.cs
        CreateManualCommandValidator.cs
    /Queries                # Read operations
      /GetManualById
        GetManualByIdQuery.cs
        GetManualByIdQueryHandler.cs
    /Behaviors              # Cross-cutting concerns
      ValidationBehavior.cs
      LoggingBehavior.cs
    /Mappings               # AutoMapper profiles
      MappingProfile.cs
  
  /Manuals.Domain           # Domain models and business logic
    /Entities
    /Exceptions
    /ValueObjects
  
  /Manuals.Infrastructure   # Infrastructure concerns
    /Persistence            # Database access
      /Configurations
      ApplicationDbContext.cs
    /Services               # External services
      PdfExtractionService.cs
      VectorSearchService.cs
```

## Voorbeeld Minimal API Endpoints

```csharp
// In Program.cs

var app = builder.Build();

// Global Exception Handling Middleware
app.UseMiddleware<GlobalExceptionHandlingMiddleware>();

// Manuals endpoints
app.MapGroup("/api/manuals")
    .MapManualsEndpoints()
    .WithTags("Manuals");

app.Run();

// In EndpointExtensions.cs
public static class ManualsEndpoints
{
    public static RouteGroupBuilder MapManualsEndpoints(this RouteGroupBuilder group)
    {
        // Get manual by ID
        group.MapGet("/{id}", async (int id, IMediator mediator) =>
        {
            var result = await mediator.Send(new GetManualByIdQuery(id));
            return result != null ? Results.Ok(result) : Results.NotFound();
        })
        .WithName("GetManualById");
        
        // Create new manual
        group.MapPost("/", async (CreateManualCommand command, IMediator mediator) =>
        {
            var id = await mediator.Send(command);
            return Results.CreatedAtRoute("GetManualById", new { id });
        });
        
        // Search manuals
        group.MapGet("/search", async (string query, IMediator mediator) =>
            await mediator.Send(new SearchManualsQuery(query)));
        
        return group;
    }
}
```

## Voorbeeld Global Exception Handling Middleware

```csharp
public class GlobalExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionHandlingMiddleware> _logger;

    public GlobalExceptionHandlingMiddleware(RequestDelegate next, 
        ILogger<GlobalExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred");
            await HandleExceptionAsync(context, ex);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/problem+json";
        
        var statusCode = exception switch
        {
            ValidationException => StatusCodes.Status400BadRequest,
            NotFoundException => StatusCodes.Status404NotFound,
            _ => StatusCodes.Status500InternalServerError
        };
        
        var problemDetails = new ProblemDetails
        {
            Status = statusCode,
            Title = GetTitle(exception),
            Detail = exception.Message,
            Instance = context.Request.Path
        };
        
        context.Response.StatusCode = statusCode;
        
        await context.Response.WriteAsJsonAsync(problemDetails);
    }
    
    private static string GetTitle(Exception exception) => exception switch
    {
        ValidationException => "Validation error",
        NotFoundException => "Resource not found",
        _ => "An unexpected error occurred"
    };
}
```

## Voorbeeld DTOs als Record Types

```csharp
// In Manuals.API/Models
public record ManualDto(int Id, string Title, string Brand, string ModelNumber);

public record CreateManualCommand(string Title, string Brand, string ModelNumber, 
    IFormFile PdfFile) : IRequest<int>;

public record SearchManualsQuery(string Query) : IRequest<SearchResultsDto>;

public record SearchResultsDto(IEnumerable<SearchResultDto> Results, int TotalCount);

public record SearchResultDto(int Id, string Title, string Excerpt, float Score);
```

## Voorbeeld Command Handler

```csharp
public class CreateManualCommandHandler : IRequestHandler<CreateManualCommand, int>
{
    private readonly IApplicationDbContext _context;
    private readonly IPdfExtractionService _pdfService;
    private readonly IMapper _mapper;

    public CreateManualCommandHandler(
        IApplicationDbContext context, 
        IPdfExtractionService pdfService,
        IMapper mapper)
    {
        _context = context;
        _pdfService = pdfService;
        _mapper = mapper;
    }

    public async Task<int> Handle(CreateManualCommand command, CancellationToken cancellationToken)
    {
        // Validatie gebeurt al via FluentValidation behavior
        
        var manual = _mapper.Map<Manual>(command);
        
        _context.Manuals.Add(manual);
        await _context.SaveChangesAsync(cancellationToken);
        
        // Process PDF and extract text
        using (var stream = command.PdfFile.OpenReadStream())
        {
            await _pdfService.ProcessManualPdfAsync(
                stream, 
                manual.Id, 
                cancellationToken);
        }
        
        return manual.Id;
    }
}

// FluentValidation voor record command
public class CreateManualCommandValidator : AbstractValidator<CreateManualCommand>
{
    public CreateManualCommandValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty()
            .MaximumLength(200);
            
        RuleFor(x => x.Brand)
            .NotEmpty()
            .MaximumLength(100);
            
        RuleFor(x => x.ModelNumber)
            .NotEmpty()
            .MaximumLength(50);
            
        RuleFor(x => x.PdfFile)
            .NotNull()
            .Must(x => x != null && x.ContentType == "application/pdf")
            .WithMessage("File must be a PDF document");
    }
}
```

## Voordelen van deze Architectuur

1. **Moderne, Compacte Code**
   - Minimal APIs reduceren boilerplate code
   - Record types zorgen voor immutable DTOs met minder code
   - Verbeterde leesbaarheid en onderhoudbaarheid

2. **Betere Error Handling**
   - Gecentraliseerde exception handling via middleware
   - Consistente foutrespons in Problem Details formaat
   - Betere gebruikerservaring bij fouten

3. **Separation of Concerns**
   - Endpoints delegeren naar mediator
   - Business logic zit in command/query handlers
   - Validatie is gescheiden van business logic

4. **Testbaarheid**
   - Elke component is gemakkelijk te mocken en te testen
   - Unit tests kunnen zich richten op specifieke handlers
   - Validatie kan afzonderlijk worden getest

5. **Schaalbaarheid en Onderhoudbaarheid**
   - Duidelijke scheiding tussen lees- en schrijfoperaties
   - Gemakkelijk uit te breiden met nieuwe functionaliteit
   - Cross-cutting concerns kunnen worden toegevoegd via behaviors

6. **Performance**
   - Minimal APIs hebben minder overhead dan controllers
   - Records zijn geoptimaliseerd voor value-based operaties
   - Queries kunnen worden geoptimaliseerd voor leesoperaties

Dit patroon zorgt voor een moderne, goed schaalbare en onderhoudbare ASP.NET Core applicatie die gemakkelijk kan worden uitgebreid naarmate de requirements groeien.
