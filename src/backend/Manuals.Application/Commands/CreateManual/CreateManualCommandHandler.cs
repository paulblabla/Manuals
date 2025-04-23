using Manuals.Application.Interfaces;
using Manuals.Domain.Entities;
using MediatR;
using AutoMapper;
using Microsoft.Extensions.Logging;

namespace Manuals.Application.Commands.CreateManual;

/// <summary>
/// Handler voor CreateManualCommand
/// </summary>
public class CreateManualCommandHandler : IRequestHandler<CreateManualCommand, int>
{
    private readonly IApplicationDbContext _context;
    private readonly IPdfExtractionService _pdfService;
    private readonly IMapper _mapper;
    private readonly ILogger<CreateManualCommandHandler> _logger;

    public CreateManualCommandHandler(
        IApplicationDbContext context, 
        IPdfExtractionService pdfService,
        IMapper mapper,
        ILogger<CreateManualCommandHandler> logger)
    {
        _context = context;
        _pdfService = pdfService;
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<int> Handle(CreateManualCommand command, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Handleiding aanmaken: {Title}", command.Title);
        
        // Validatie gebeurt al via FluentValidation behavior
        var manual = new Manual
        {
            Title = command.Title,
            Brand = command.Brand,
            ModelNumber = command.ModelNumber,
            FileName = command.PdfFile.FileName,
            ContentType = command.PdfFile.ContentType,
            FileSize = command.PdfFile.Length,
            UploadedAt = DateTime.UtcNow,
            DeviceId = command.DeviceId
        };
        
        _context.Manuals.Add(manual);
        await _context.SaveChangesAsync(cancellationToken);
        
        _logger.LogInformation("Handleiding aangemaakt met ID: {ManualId}", manual.Id);
        
        // Process PDF en extraheer tekst
        using (var stream = command.PdfFile.OpenReadStream())
        {
            await _pdfService.ProcessManualPdfAsync(
                stream, 
                manual.Id, 
                cancellationToken);
        }
        
        return manual.Id;
    }
}
