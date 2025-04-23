using iText.Kernel.Pdf;
using iText.Kernel.Pdf.Canvas.Parser;
using iText.Kernel.Pdf.Canvas.Parser.Listener;
using Manuals.Application.Interfaces;
using Manuals.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Manuals.Infrastructure.Services;

/// <summary>
/// Service voor het extraheren van tekst uit PDF-bestanden
/// </summary>
public class PdfExtractionService : IPdfExtractionService
{
    private readonly IApplicationDbContext _context;
    private readonly ILogger<PdfExtractionService> _logger;

    public PdfExtractionService(
        IApplicationDbContext context,
        ILogger<PdfExtractionService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task ProcessManualPdfAsync(Stream stream, int manualId, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Start extractie van tekst uit PDF voor handleiding ID: {ManualId}", manualId);
        
        try
        {
            // Zoek de manual op in de database
            var manual = await _context.Manuals
                .FirstOrDefaultAsync(m => m.Id == manualId, cancellationToken);
                
            if (manual == null)
            {
                _logger.LogError("Handleiding niet gevonden tijdens PDF-extractie. ID: {ManualId}", manualId);
                throw new InvalidOperationException($"Handleiding niet gevonden: {manualId}");
            }
            
            // Lees de PDF en extraheer tekst
            using var pdfReader = new PdfReader(stream);
            using var pdfDocument = new PdfDocument(pdfReader);
            
            var pageCount = pdfDocument.GetNumberOfPages();
            _logger.LogInformation("PDF heeft {PageCount} pagina's", pageCount);
            
            for (int i = 1; i <= pageCount; i++)
            {
                if (cancellationToken.IsCancellationRequested)
                {
                    _logger.LogWarning("PDF extractie geannuleerd voor handleiding ID: {ManualId}", manualId);
                    break;
                }
                
                var page = pdfDocument.GetPage(i);
                var text = PdfTextExtractor.GetTextFromPage(page, new SimpleTextExtractionStrategy());
                
                // Sla de tekst op in de zoekindex
                if (!string.IsNullOrWhiteSpace(text))
                {
                    var searchIndex = new SearchIndex
                    {
                        ManualId = manualId,
                        PageNumber = i,
                        Content = text,
                        // In een echte implementatie zou hier een embedding worden gegenereerd
                        Embedding = new float[384] // Voorbeeld dimensie voor embedding
                    };
                    
                    _context.SearchIndices.Add(searchIndex);
                    
                    _logger.LogDebug("Tekst geëxtraheerd van pagina {PageNumber}", i);
                }
            }
            
            // Update manual met nieuwe metadata
            manual.BlobId = Guid.NewGuid().ToString(); // Dit zou normaal gezien een echte blob ID zijn
            
            await _context.SaveChangesAsync(cancellationToken);
            
            _logger.LogInformation("PDF extractie voltooid voor handleiding ID: {ManualId}, {PageCount} pagina's verwerkt", 
                manualId, pageCount);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Fout bij PDF extractie voor handleiding ID: {ManualId}", manualId);
            throw;
        }
    }
}
