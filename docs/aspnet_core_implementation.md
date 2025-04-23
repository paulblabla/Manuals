# ASP.NET Core Implementatie met CQRS en Controllers

## Architectural Approach

Voor de ASP.NET Core backend zullen we de CQRS (Command Query Responsibility Segregation) pattern implementeren met behulp van MediatR, FluentValidation en AutoMapper. Deze combinatie biedt een schone, onderhoudbare en testbare codebase.

## Belangrijkste Features

### Controllers met MediatR
In plaats van Minimal APIs gebruiken we traditionele controllers:
- Betere organisatie van gerelateerde endpoints
- Vertrouwde structuur die bekend is voor ASP.NET ontwikkelaars
- Goede ondersteuning voor attributen zoals [Authorize]
- Betere route-configuratie mogelijkheden

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
  /backend
    /Manuals.API              # ASP.NET Core Web API project
      /Controllers            # API controllers
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

## Voorbeeld Controllers

```csharp
// ManualsController.cs
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class ManualsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ILogger<ManualsController> _logger;

    public ManualsController(IMediator mediator, ILogger<ManualsController> logger)
    {
        _mediator = mediator;
        _logger = logger;
    }

    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ManualDto>> GetById(int id)
    {
        var result = await _mediator.Send(new GetManualByIdQuery(id));
        
        if (result == null)
        {
            return NotFound();
        }
        
        return Ok(result);
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<int>> Create([FromForm] CreateManualCommand command)
    {
        var id = await _mediator.Send(command);
        
        return CreatedAtAction(nameof(GetById), new { id }, id);
    }

    [HttpGet("search")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult<object>> Search([FromQuery] string query)
    {
        // In een echte implementatie zou dit een SearchManuals query aanroepen
        return Ok(new { Query = query, Results = Array.Empty<object>() });
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
// In Manuals.Application.Queries
public record ManualDto
{
    public int Id { get; init; }
    public string Title { get; init; } = string.Empty;
    public string Brand { get; init; } = string.Empty;
    public string ModelNumber { get; init; } = string.Empty;
    public string FileName { get; init; } = string.Empty;
    public DateTime UploadedAt { get; init; }
    public long FileSize { get; init; }
    public int? DeviceId { get; init; }
    public string? DeviceName { get; init; }
}

// In Manuals.Application.Commands
public record CreateManualCommand : IRequest<int>
{
    public string Title { get; init; } = string.Empty;
    public string Brand { get; init; } = string.Empty;
    public string ModelNumber { get; init; } = string.Empty;
    public IFormFile PdfFile { get; init; } = null!;
    public int? DeviceId { get; init; }
}
```

## Voorbeeld Command Handler

```csharp
public class CreateManualCommandHandler : IRequestHandler<CreateManualCommand, int>
{
    private readonly IApplicationDbContext _context;
    private readonly IPdfExtractionService _pdfService;
    private readonly IMapper _mapper;
    private readonly ILogger<CreateManualCommandHandler> _logger;

    public CreateManualCommandHandler(
        IApplicationDbContext context, 
        IPdfExtractionService pdfService,
        IMapper mapper,
        ILogger<CreateManualCommandHandler> logger)
    {
        _context = context;
        _pdfService = pdfService;
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<int> Handle(CreateManualCommand command, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Handleiding aanmaken: {Title}", command.Title);
        
        // Validatie gebeurt al via FluentValidation behavior
        var manual = new Manual
        {
            Title = command.Title,
            Brand = command.Brand,
            ModelNumber = command.ModelNumber,
            FileName = command.PdfFile.FileName,
            ContentType = command.PdfFile.ContentType,
            FileSize = command.PdfFile.Length,
            UploadedAt = DateTime.UtcNow,
            DeviceId = command.DeviceId
        };
        
        _context.Manuals.Add(manual);
        await _context.SaveChangesAsync(cancellationToken);
        
        _logger.LogInformation("Handleiding aangemaakt met ID: {ManualId}", manual.Id);
        
        // Process PDF en extraheer tekst
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
```

## Voordelen van deze Architectuur

1. **Gestructureerde Code**
   - Controllers bieden een traditionele, georganiseerde benadering
   - Record types zorgen voor immutable DTOs met minder code
   - Verbeterde leesbaarheid en onderhoudbaarheid

2. **Betere Error Handling**
   - Gecentraliseerde exception handling via middleware
   - Consistente foutrespons in Problem Details formaat
   - Betere gebruikerservaring bij fouten

3. **Separation of Concerns**
   - Controllers delegeren naar mediator
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

6. **Bekendheid en Adoptie**
   - Vertrouwde controller-gebaseerde architectuur
   - Gemakkelijker voor nieuwe ontwikkelaars om te begrijpen
   - Goede integratie met bestaande ASP.NET Core features

Dit patroon zorgt voor een goed gestructureerde, schaalbare en onderhoudbare ASP.NET Core applicatie die gemakkelijk kan worden uitgebreid naarmate de requirements groeien.
