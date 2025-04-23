namespace Manuals.Domain.Entities;

/// <summary>
/// Representeert een handleiding voor een apparaat
/// </summary>
public class Manual
{
    public int Id { get; set; }
    
    /// <summary>
    /// Titel van de handleiding
    /// </summary>
    public string Title { get; set; } = string.Empty;
    
    /// <summary>
    /// Merk van het apparaat
    /// </summary>
    public string Brand { get; set; } = string.Empty;
    
    /// <summary>
    /// Modelnummer van het apparaat
    /// </summary>
    public string ModelNumber { get; set; } = string.Empty;
    
    /// <summary>
    /// Datum waarop de handleiding is geüpload
    /// </summary>
    public DateTime UploadedAt { get; set; }
    
    /// <summary>
    /// Bestandsnaam van het originele PDF-bestand
    /// </summary>
    public string FileName { get; set; } = string.Empty;
    
    /// <summary>
    /// Unieke identifier van het PDF-bestand in de blob storage
    /// </summary>
    public string BlobId { get; set; } = string.Empty;
    
    /// <summary>
    /// Content type van het bestand (normaalgesproken application/pdf)
    /// </summary>
    public string ContentType { get; set; } = "application/pdf";
    
    /// <summary>
    /// Grootte van het bestand in bytes
    /// </summary>
    public long FileSize { get; set; }
    
    /// <summary>
    /// Optioneel: een Device waaraan deze handleiding is gekoppeld
    /// </summary>
    public Device? Device { get; set; }
    
    /// <summary>
    /// Optioneel: ID van het Device waaraan deze handleiding is gekoppeld
    /// </summary>
    public int? DeviceId { get; set; }
}
