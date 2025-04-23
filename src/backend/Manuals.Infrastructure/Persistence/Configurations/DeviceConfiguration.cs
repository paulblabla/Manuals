using Manuals.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Manuals.Infrastructure.Persistence.Configurations;

/// <summary>
/// Entity Framework configuratie voor Device entity
/// </summary>
public class DeviceConfiguration : IEntityTypeConfiguration<Device>
{
    public void Configure(EntityTypeBuilder<Device> builder)
    {
        // Primaire sleutel
        builder.HasKey(d => d.Id);
        
        // Properties
        builder.Property(d => d.Name)
            .IsRequired()
            .HasMaxLength(200);
            
        builder.Property(d => d.DeviceType)
            .IsRequired()
            .HasMaxLength(100);
            
        builder.Property(d => d.Brand)
            .IsRequired()
            .HasMaxLength(100);
            
        builder.Property(d => d.ModelNumber)
            .IsRequired()
            .HasMaxLength(50);
            
        builder.Property(d => d.SerialNumber)
            .HasMaxLength(100);
            
        builder.Property(d => d.Location)
            .HasMaxLength(100);
            
        builder.Property(d => d.CreatedAt)
            .IsRequired()
            .HasDefaultValueSql("GETUTCDATE()");
            
        builder.Property(d => d.LastUpdatedAt)
            .IsRequired()
            .HasDefaultValueSql("GETUTCDATE()");
    }
}
