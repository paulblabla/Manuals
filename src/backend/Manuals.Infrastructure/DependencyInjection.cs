using Manuals.Application.Interfaces;
using Manuals.Infrastructure.Persistence;
using Manuals.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Azure;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Manuals.Infrastructure;

/// <summary>
/// Extensie methoden voor dependency injection configuratie
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services, 
        IConfiguration configuration)
    {
        // Database
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(
                configuration.GetConnectionString("DefaultConnection"),
                b => b.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName)));

        services.AddScoped<IApplicationDbContext>(provider => 
            provider.GetRequiredService<ApplicationDbContext>());
            
        // Database initializer
        services.AddScoped<ApplicationDbContextInitializer>();
            
        // Azure Storage
        services.AddAzureClients(clientBuilder =>
        {
            clientBuilder.AddBlobServiceClient(
                configuration.GetConnectionString("AzureStorage"));
        });
        
        // Services
        services.AddScoped<IPdfExtractionService, PdfExtractionService>();
        services.AddScoped<VectorSearchService>();
        
        return services;
    }
}
