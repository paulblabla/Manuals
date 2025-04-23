using FluentValidation;
using MediatR;
using Microsoft.Extensions.Logging;

namespace Manuals.Application.Behaviors;

/// <summary>
/// MediatR pipeline behavior voor validatie van requests
/// </summary>
/// <typeparam name="TRequest">Request type</typeparam>
/// <typeparam name="TResponse">Response type</typeparam>
public class ValidationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;
    private readonly ILogger<ValidationBehavior<TRequest, TResponse>> _logger;

    public ValidationBehavior(
        IEnumerable<IValidator<TRequest>> validators,
        ILogger<ValidationBehavior<TRequest, TResponse>> logger)
    {
        _validators = validators;
        _logger = logger;
    }

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        if (!_validators.Any())
        {
            return await next();
        }
        
        var typeName = request.GetType().Name;
        
        _logger.LogDebug("Validating request {RequestType}", typeName);
        
        var context = new ValidationContext<TRequest>(request);
        
        // Voer alle validators parallel uit
        var validationResults = await Task.WhenAll(
            _validators.Select(v => v.ValidateAsync(context, cancellationToken)));
        
        var failures = validationResults
            .SelectMany(r => r.Errors)
            .Where(f => f != null)
            .ToList();
        
        if (failures.Count != 0)
        {
            _logger.LogWarning(
                "Validation failed for {RequestType}. Errors: {ValidationErrors}", 
                typeName, 
                string.Join(", ", failures.Select(f => f.ErrorMessage)));
            
            throw new ValidationException(failures);
        }
        
        _logger.LogDebug("Validation successful for {RequestType}", typeName);
        
        return await next();
    }
}
