namespace Manuals.Application.Interfaces;

/// <summary>
/// Interface voor PDF-extractie service
/// </summary>
public interface IPdfExtractionService
{
    /// <summary>
    /// Verwerk een PDF-bestand en extraheer de tekst met relevante metadata
    /// </summary>
    /// <param name="stream">Stream van het PDF-bestand</param>
    /// <param name="manualId">ID van de handleiding</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Taak die aangeeft of het verwerken is voltooid</returns>
    Task ProcessManualPdfAsync(Stream stream, int manualId, CancellationToken cancellationToken = default);
}
