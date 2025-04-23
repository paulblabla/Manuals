using System.Reflection;
using FluentValidation;
using Manuals.Application.Behaviors;
using Manuals.Application.Mappings;
using MediatR;
using Microsoft.Extensions.DependencyInjection;

namespace Manuals.Application;

/// <summary>
/// Extensie methoden voor dependency injection configuratie
/// </summary>
public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        // MediatR
        services.AddMediatR(cfg => {
            cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
            
            // Pipeline behaviors in volgorde van uitvoering
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(LoggingBehavior<,>));
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        });
        
        // FluentValidation
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());
        
        // AutoMapper
        services.AddAutoMapper(typeof(MappingProfile).Assembly);
        
        return services;
    }
}
