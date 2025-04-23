namespace Manuals.Domain.Entities;

/// <summary>
/// Representeert een zoekindex-item voor vector searching
/// </summary>
public class SearchIndex
{
    public int Id { get; set; }
    
    /// <summary>
    /// ID van de handleiding waartoe deze zoekindex behoort
    /// </summary>
    public int ManualId { get; set; }
    
    /// <summary>
    /// Referentie naar de handleiding
    /// </summary>
    public Manual? Manual { get; set; }
    
    /// <summary>
    /// Paginanummer in de handleiding (indien van toepassing)
    /// </summary>
    public int? PageNumber { get; set; }
    
    /// <summary>
    /// Hoofdstuktitel of sectie (indien van toepassing)
    /// </summary>
    public string? SectionTitle { get; set; }
    
    /// <summary>
    /// Tekstfragment dat is geïndexeerd
    /// </summary>
    public string Content { get; set; } = string.Empty;
    
    /// <summary>
    /// Vector representatie van de content, opgeslagen als array van floats
    /// </summary>
    public float[] Embedding { get; set; } = Array.Empty<float>();
}
