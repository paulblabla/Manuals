using Manuals.Application.Commands.CreateManual;
using Manuals.Application.Queries.GetManualById;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Manuals.API.Endpoints;

/// <summary>
/// Extensie methoden voor handleidingen endpoints
/// </summary>
public static class ManualsEndpoints
{
    public static WebApplication MapManualsEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/manuals")
            .WithTags("Manuals")
            .WithOpenApi();
        
        // Get manual by ID
        group.MapGet("/{id}", async (int id, IMediator mediator) =>
        {
            var result = await mediator.Send(new GetManualByIdQuery(id));
            return result != null ? Results.Ok(result) : Results.NotFound();
        })
        .WithName("GetManualById")
        .Produces<ManualDto>(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status404NotFound)
        .WithDescription("Haalt een handleiding op basis van ID op");
        
        // Create new manual
        group.MapPost("/", async ([FromForm] CreateManualCommand command, IMediator mediator) =>
        {
            var id = await mediator.Send(command);
            return Results.CreatedAtRoute("GetManualById", new { id }, id);
        })
        .WithName("CreateManual")
        .Accepts<CreateManualCommand>("multipart/form-data")
        .Produces<int>(StatusCodes.Status201Created)
        .Produces(StatusCodes.Status400BadRequest)
        .WithDescription("Upload een nieuwe handleiding");
        
        // Search manuals (placeholder voor nu)
        group.MapGet("/search", async (string query, IMediator mediator) =>
        {
            // In een echte implementatie zou dit een SearchManuals query aanroepen
            return Results.Ok(new { Query = query, Results = Array.Empty<object>() });
        })
        .WithName("SearchManuals")
        .Produces(StatusCodes.Status200OK)
        .WithDescription("Zoekt in de handleidingen op basis van natuurlijke taal query");
        
        return app;
    }
}
