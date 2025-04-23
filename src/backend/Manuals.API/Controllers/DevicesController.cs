using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Manuals.API.Controllers;

/// <summary>
/// Controller voor het beheren van apparaten
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class DevicesController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ILogger<DevicesController> _logger;

    public DevicesController(IMediator mediator, ILogger<DevicesController> logger)
    {
        _mediator = mediator;
        _logger = logger;
    }

    /// <summary>
    /// Haalt alle apparaten op
    /// </summary>
    /// <returns>Lijst van apparaten</returns>
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult<object>> GetAll()
    {
        _logger.LogInformation("Alle apparaten ophalen");
        
        // In een echte implementatie zou dit een GetAllDevices query aanroepen
        return Ok(new { Devices = Array.Empty<object>() });
    }

    /// <summary>
    /// Haalt een apparaat op basis van ID op
    /// </summary>
    /// <param name="id">ID van het apparaat</param>
    /// <returns>Het opgevraagde apparaat of NotFound</returns>
    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<object>> GetById(int id)
    {
        _logger.LogInformation("Apparaat ophalen met ID: {Id}", id);
        
        // In een echte implementatie zou dit een GetDeviceById query aanroepen
        return Ok(new { Id = id, Name = "Voorbeeld apparaat" });
    }
}
