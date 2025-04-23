using MediatR;

namespace Manuals.Application.Queries.GetManualById;

/// <summary>
/// Query voor het ophalen van een handleiding op basis van ID
/// </summary>
public record GetManualByIdQuery(int Id) : IRequest<ManualDto?>;
