using Manuals.Application.Interfaces;
using Manuals.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System.Reflection;

namespace Manuals.Infrastructure.Persistence;

/// <summary>
/// De hoofddatabase context voor de applicatie
/// </summary>
public class ApplicationDbContext : DbContext, IApplicationDbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) 
        : base(options)
    {
    }

    public DbSet<Manual> Manuals => Set<Manual>();
    public DbSet<Device> Devices => Set<Device>();
    public DbSet<SearchIndex> SearchIndices => Set<SearchIndex>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Alle entity configuraties automatisch toepassen
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
        
        base.OnModelCreating(modelBuilder);
    }
    
    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        // Update timestamps voor entiteiten die we bijhouden
        UpdateAuditableEntities();
        
        return await base.SaveChangesAsync(cancellationToken);
    }
    
    private void UpdateAuditableEntities()
    {
        var now = DateTime.UtcNow;
        
        foreach (var entry in ChangeTracker.Entries<Device>())
        {
            if (entry.State == EntityState.Added)
            {
                entry.Entity.CreatedAt = now;
                entry.Entity.LastUpdatedAt = now;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.LastUpdatedAt = now;
            }
        }
    }
}
