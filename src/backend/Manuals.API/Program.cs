using Manuals.API.Endpoints;
using Manuals.API.Middleware;
using Manuals.Application;
using Manuals.Infrastructure;
using Manuals.Infrastructure.Persistence;
using System.Reflection;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
// Application Insights
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    // Beperkt de hoeveelheid telemetrie tot 25% van alle events volgens kostenstrategie
    options.EnableAdaptiveSampling = true;
    options.EnableHeartbeat = true;
    options.EnableQuickPulseMetricStream = true;
    options.EnablePerformanceCounterCollectionModule = false;
});

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins(
                builder.Configuration.GetValue<string>("Frontend:BaseUrl") ?? "http://localhost:5173")
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
    });
});

// API documentatie
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    // XML documentatie voor Swagger
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    options.IncludeXmlComments(xmlPath);
    
    options.SwaggerDoc("v1", new() { 
        Title = "Manuals API", 
        Version = "v1",
        Description = "API voor het beheren van handleidingen voor huishoudelijke apparaten"
    });
});

// JSON serialization options
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
    options.SerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
    options.SerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
});

// Project layers
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    
    // In development mode, create database if it doesn't exist
    using (var scope = app.Services.CreateScope())
    {
        var initializer = scope.ServiceProvider.GetRequiredService<ApplicationDbContextInitializer>();
        await initializer.InitializeAsync();
        await initializer.SeedAsync();
    }
}

app.UseHttpsRedirection();
app.UseCors("AllowFrontend");

// Global exception handling middleware
app.UseMiddleware<GlobalExceptionHandlingMiddleware>();

// Map endpoints
app.MapManualsEndpoints();

app.Run();
