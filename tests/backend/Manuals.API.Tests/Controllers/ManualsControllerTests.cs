using Manuals.API.Controllers;
using Manuals.Application.Queries.GetManualById;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;

namespace Manuals.API.Tests.Controllers;

public class ManualsControllerTests
{
    private readonly Mock<IMediator> _mediatorMock;
    private readonly Mock<ILogger<ManualsController>> _loggerMock;
    private readonly ManualsController _controller;

    public ManualsControllerTests()
    {
        _mediatorMock = new Mock<IMediator>();
        _loggerMock = new Mock<ILogger<ManualsController>>();
        _controller = new ManualsController(_mediatorMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task GetById_WhenManualExists_ReturnsOkResult()
    {
        // Arrange
        var manualId = 1;
        var manualDto = new ManualDto 
        { 
            Id = manualId,
            Title = "Test Manual",
            Brand = "Test Brand",
            ModelNumber = "ABC123"
        };

        _mediatorMock.Setup(x => x.Send(It.IsAny<GetManualByIdQuery>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(manualDto);

        // Act
        var result = await _controller.GetById(manualId);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var returnValue = Assert.IsType<ManualDto>(okResult.Value);
        Assert.Equal(manualId, returnValue.Id);
    }
}
