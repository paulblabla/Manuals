using Manuals.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Manuals.Application.Interfaces;

/// <summary>
/// Interface voor database context
/// </summary>
public interface IApplicationDbContext
{
    DbSet<Manual> Manuals { get; }
    DbSet<Device> Devices { get; }
    DbSet<SearchIndex> SearchIndices { get; }
    
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
