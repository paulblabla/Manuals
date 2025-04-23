using AutoMapper;
using Manuals.Application.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Manuals.Application.Queries.GetManualById;

/// <summary>
/// Handler voor GetManualByIdQuery
/// </summary>
public class GetManualByIdQueryHandler : IRequestHandler<GetManualByIdQuery, ManualDto?>
{
    private readonly IApplicationDbContext _context;
    private readonly IMapper _mapper;
    private readonly ILogger<GetManualByIdQueryHandler> _logger;

    public GetManualByIdQueryHandler(
        IApplicationDbContext context,
        IMapper mapper,
        ILogger<GetManualByIdQueryHandler> logger)
    {
        _context = context;
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<ManualDto?> Handle(GetManualByIdQuery request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Handleiding ophalen met ID: {ManualId}", request.Id);
        
        var manual = await _context.Manuals
            .Include(m => m.Device)
            .FirstOrDefaultAsync(m => m.Id == request.Id, cancellationToken);
        
        if (manual == null)
        {
            _logger.LogWarning("Handleiding niet gevonden met ID: {ManualId}", request.Id);
            return null;
        }
        
        var result = _mapper.Map<ManualDto>(manual);
        
        // Voeg extra informatie toe die niet direct in de automapper mapping zit
        if (manual.Device != null)
        {
            result = result with { DeviceName = manual.Device.Name };
        }
        
        return result;
    }
}
