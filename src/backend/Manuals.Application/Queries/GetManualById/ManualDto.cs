namespace Manuals.Application.Queries.GetManualById;

/// <summary>
/// DTO voor handleiding gegevens
/// </summary>
public record ManualDto
{
    /// <summary>
    /// Unieke ID van de handleiding
    /// </summary>
    public int Id { get; init; }
    
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
    /// Originele bestandsnaam van de handleiding
    /// </summary>
    public string FileName { get; init; } = string.Empty;
    
    /// <summary>
    /// Datum waarop de handleiding is geüpload
    /// </summary>
    public DateTime UploadedAt { get; init; }
    
    /// <summary>
    /// Bestandsgrootte in bytes
    /// </summary>
    public long FileSize { get; init; }
    
    /// <summary>
    /// ID van het gekoppelde apparaat, indien aanwezig
    /// </summary>
    public int? DeviceId { get; init; }
    
    /// <summary>
    /// Naam van het gekoppelde apparaat, indien aanwezig
    /// </summary>
    public string? DeviceName { get; init; }
}
