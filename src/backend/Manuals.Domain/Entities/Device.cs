namespace Manuals.Domain.Entities;

/// <summary>
/// Representeert een apparaat waarvoor handleidingen beschikbaar zijn
/// </summary>
public class Device
{
    public int Id { get; set; }
    
    /// <summary>
    /// Naam van het apparaat
    /// </summary>
    public string Name { get; set; } = string.Empty;
    
    /// <summary>
    /// Type apparaat (bijv. "Oven", "Wasmachine", etc.)
    /// </summary>
    public string DeviceType { get; set; } = string.Empty;
    
    /// <summary>
    /// Merk van het apparaat
    /// </summary>
    public string Brand { get; set; } = string.Empty;
    
    /// <summary>
    /// Modelnummer van het apparaat
    /// </summary>
    public string ModelNumber { get; set; } = string.Empty;
    
    /// <summary>
    /// Serienummer van het apparaat
    /// </summary>
    public string? SerialNumber { get; set; }
    
    /// <summary>
    /// Aankoopdatum van het apparaat
    /// </summary>
    public DateTime? PurchaseDate { get; set; }
    
    /// <summary>
    /// Locatie van het apparaat in huis
    /// </summary>
    public string? Location { get; set; }
    
    /// <summary>
    /// Datum waarop dit item is aangemaakt
    /// </summary>
    public DateTime CreatedAt { get; set; }
    
    /// <summary>
    /// Datum waarop dit item voor het laatst is bijgewerkt
    /// </summary>
    public DateTime LastUpdatedAt { get; set; }
    
    /// <summary>
    /// Collectie van handleidingen die bij dit apparaat horen
    /// </summary>
    public ICollection<Manual>? Manuals { get; set; }
}
