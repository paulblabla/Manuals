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
        // Arrange
        var manualId = 1;
        var manual = new Manual
        {
            Id = manualId,
            Title = "Test Manual",
            Brand = "Test Brand",
            ModelNumber = "ABC123",
            UploadedAt = DateTime.UtcNow,
            FileName = "test.pdf",
            BlobId = "test-blob-id",
            FileSize = 1024
        };

        var manualDto = new ManualDto
        {
            Id = manualId,
            Title = "Test Manual",
            Brand = "Test Brand",
            ModelNumber = "ABC123"
        };

        var query = new GetManualByIdQuery(manualId);

        // Mock DbSet
        var mockManualsDbSet = new Mock<DbSet<Manual>>();
        var manuals = new List<Manual> { manual }.AsQueryable();
        
        // We moeten hier minimaal de basic LINQ operaties mocken
        // IQueryable implementatie
        mockManualsDbSet.As<IQueryable<Manual>>().Setup(m => m.Provider).Returns(manuals.Provider);
        mockManualsDbSet.As<IQueryable<Manual>>().Setup(m => m.Expression).Returns(manuals.Expression);
        mockManualsDbSet.As<IQueryable<Manual>>().Setup(m => m.ElementType).Returns(manuals.ElementType);
        mockManualsDbSet.As<IQueryable<Manual>>().Setup(m => m.GetEnumerator()).Returns(manuals.GetEnumerator());

        // DbContext setup
        _contextMock.Setup(c => c.Manuals).Returns(mockManualsDbSet.Object);

        // Mapper setup
        _mapperMock.Setup(m => m.Map<ManualDto>(It.IsAny<Manual>())).Returns(manualDto);

        // Act
        var result = await _handler.Handle(query, CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(manualId, result.Id);
        Assert.Equal("Test Manual", result.Title);
    }
}
