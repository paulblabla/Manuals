# Application Insights Kostenbeheer Strategie

Om ervoor te zorgen dat we binnen de 5GB/maand limiet blijven van de gratis Application Insights tier, implementeren we de volgende strategieën:

## 1. Sampling Configuratie

Azure Application Insights biedt sampling om het volume van verzonden telemetrie te verminderen zonder de statistische juistheid aan te tasten.

```csharp
// In Program.cs
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    // Beperkt de hoeveelheid telemetrie tot 25% van alle events
    options.EnableAdaptiveSampling = true;
    options.EnableHeartbeat = true;
    options.EnableQuickPulseMetricStream = true;
    options.EnablePerformanceCounterCollectionModule = false; // Optioneel uitschakelen voor minder data
});
```

## 2. Selectieve Telemetrie

We configureren specifiek welke telemetrie we willen verzamelen en wat we kunnen uitschakelen:

```csharp
// In Program.cs
builder.Services.ConfigureTelemetryModule<DependencyTrackingTelemetryModule>((module, o) =>
{
    // Alleen belangrijke dependencies tracken
    module.EnableSqlCommandTextInstrumentation = false;
});

builder.Services.ConfigureTelemetryModule<RequestTrackingTelemetryModule>((module, o) =>
{
    // Bepaalde paden uitsluiten van tracking
    module.Handlers.Add("Microsoft.AspNetCore.StaticFiles.StaticFileMiddleware");
});
```

## 3. Monitoring en Alerting

Implementeer monitoring op het Application Insights gegevensgebruik zelf:

```bicep
// In Bicep template
resource dailyCapAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'ai-datacap-alert'
  location: 'global'
  properties: {
    description: 'Alert when Application Insights approaches data cap'
    severity: 1
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT1H'
    windowSize: 'PT1H'
    criteria: {
      allOf: [
        {
          threshold: 4000000000  // Alert bij 4GB (80% van 5GB)
          name: 'DataCapApproaching'
          metricNamespace: 'Microsoft.Insights/components'
          metricName: 'DataCapBytes'
          operator: 'GreaterThan'
          timeAggregation: 'Total'
        }
      ]
    }
    actions: [
      // Actie configuraties, bijvoorbeeld webhook naar Teams/Slack
    ]
  }
}
```

## 4. Automatisch Uitschakelen bij Limietbereik

Als ultieme veiligheidsmaatregel kunnen we Application Insights automatisch uitschakelen als we de limiet naderen:

```csharp
// In een middleware of service
public class TelemetryLimitMiddleware
{
    private readonly TelemetryClient _telemetryClient;
    private readonly IConfiguration _configuration;
    
    // Throttle telemetrie als limiet bereikt wordt
    public async Task InvokeAsync(HttpContext context)
    {
        var currentUsage = await GetCurrentAIUsage(); // Implementatie om current usage op te halen
        var maxAllowedUsage = 4500000000; // 4.5GB als veilige grens
        
        if (currentUsage > maxAllowedUsage)
        {
            _telemetryClient.EnableTelemetry = false; // Tijdelijk uitschakelen
        }
        
        // Vervolg middleware chain
    }
}
```

## 5. Optimalisatie van Logboekregistratie

- Gebruik filtering voor logs om alleen belangrijke data te verzenden
- Beperk de hoeveelheid property-data in elke telemetrie-item
- Gebruik log niveaus effectief (Error, Warning, Information, etc.)

```csharp
// Log configuratie
builder.Host.ConfigureLogging(logging =>
{
    logging.AddApplicationInsights();
    logging.AddFilter<ApplicationInsightsLoggerProvider>("", LogLevel.Warning); // Alleen Warning en hoger
});
```

Door deze maatregelen kunnen we Application Insights effectief gebruiken binnen de gratis tier, terwijl we nog steeds de meest waardevolle inzichten krijgen zonder kosten te maken.