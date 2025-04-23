using Manuals.Application.Commands.CreateManual;
using Manuals.Application.Queries.GetManualById;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Manuals.API.Controllers;

/// <summary>
/// Controller voor het beheren van handleidingen
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class ManualsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ILogger<ManualsController> _logger;

    public ManualsController(IMediator mediator, ILogger<ManualsController> logger)
    {
        _mediator = mediator;
        _logger = logger;
    }

    /// <summary>
    /// Haalt een handleiding op basis van ID op
    /// </summary>
    /// <param name="id">ID van de handleiding</param>
    /// <returns>De opgevraagde handleiding of NotFound</returns>
    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ManualDto>> GetById(int id)
    {
        _logger.LogInformation("Handleiding ophalen met ID: {Id}", id);
        
        var result = await _mediator.Send(new GetManualByIdQuery(id));
        
        if (result == null)
        {
            return NotFound();
        }
        
        return Ok(result);
    }

    /// <summary>
    /// Upload een nieuwe handleiding
    /// </summary>
    /// <param name="command">De createManualCommand met bestandsgegevens</param>
    /// <returns>ID van de nieuwe handleiding</returns>
    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<int>> Create([FromForm] CreateManualCommand command)
    {
        _logger.LogInformation("Nieuwe handleiding uploaden: {Title}", command.Title);
        
        var id = await _mediator.Send(command);
        
        return CreatedAtAction(nameof(GetById), new { id }, id);
    }

    /// <summary>
    /// Zoekt in de handleidingen op basis van natuurlijke taal query
    /// </summary>
    /// <param name="query">De zoekopdracht</param>
    /// <returns>Zoekresultaten</returns>
    [HttpGet("search")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult<object>> Search([FromQuery] string query)
    {
        _logger.LogInformation("Zoeken naar handleidingen met query: {Query}", query);
        
        // In een echte implementatie zou dit een SearchManuals query aanroepen
        return Ok(new { Query = query, Results = Array.Empty<object>() });
    }
}
