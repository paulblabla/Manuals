using MediatR;
using Microsoft.AspNetCore.Http;

namespace Manuals.Application.Commands.CreateManual;

/// <summary>
/// Command voor het aanmaken van een nieuwe handleiding
/// </summary>
public record CreateManualCommand : IRequest<int>
{
    /// <summary>
    /// Titel van de handleiding
    /// </summary>
    public string Title { get; init; } = string.Empty;
    
    /// <summary>
    /// Merk van het apparaat
    /// </summary>
    public string Brand { get; init; } = string.Empty;
    
    /// <summary>
    /// Modelnummer van het apparaat
    /// </summary>
    public string ModelNumber { get; init; } = string.Empty;
    
    /// <summary>
    /// PDF-bestand van de handleiding
    /// </summary>
    public IFormFile PdfFile { get; init; } = null!;
    
    /// <summary>
    /// Optionele koppeling aan een bestaand Device ID
    /// </summary>
    public int? DeviceId { get; init; }
}
