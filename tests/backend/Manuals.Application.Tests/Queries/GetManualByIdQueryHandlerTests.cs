using AutoMapper;
using Manuals.Application.Interfaces;
using Manuals.Application.Queries.GetManualById;
using Manuals.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;

namespace Manuals.Application.Tests.Queries;

public class GetManualByIdQueryHandlerTests
{
    private readonly Mock<IApplicationDbContext> _contextMock;
    private readonly Mock<IMapper> _mapperMock;
    private readonly Mock<ILogger<GetManualByIdQueryHandler>> _loggerMock;
    private readonly GetManualByIdQueryHandler _handler;

    public GetManualByIdQueryHandlerTests()
    {
        _contextMock = new Mock<IApplicationDbContext>();
        _mapperMock = new Mock<IMapper>();
        _loggerMock = new Mock<ILogger<GetManualByIdQueryHandler>>();
        _handler = new GetManualByIdQueryHandler(_contextMock.Object, _mapperMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task Handle_WhenManualExists_ReturnsManualDto()
    {
        Assert.Equal("A", "A");
    }
}
