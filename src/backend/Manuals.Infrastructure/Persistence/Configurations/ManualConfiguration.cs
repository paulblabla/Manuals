using Manuals.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Manuals.Infrastructure.Persistence.Configurations;

/// <summary>
/// Entity Framework configuratie voor Manual entity
/// </summary>
public class ManualConfiguration : IEntityTypeConfiguration<Manual>
{
    public void Configure(EntityTypeBuilder<Manual> builder)
    {
        // Primaire sleutel
        builder.HasKey(m => m.Id);
        
        // Properties
        builder.Property(m => m.Title)
            .IsRequired()
            .HasMaxLength(200);
            
        builder.Property(m => m.Brand)
            .IsRequired()
            .HasMaxLength(100);
            
        builder.Property(m => m.ModelNumber)
            .IsRequired()
            .HasMaxLength(50);
            
        builder.Property(m => m.FileName)
            .IsRequired()
            .HasMaxLength(255);
            
        builder.Property(m => m.BlobId)
            .IsRequired()
            .HasMaxLength(255);
            
        builder.Property(m => m.ContentType)
            .IsRequired()
            .HasMaxLength(100)
            .HasDefaultValue("application/pdf");
            
        builder.Property(m => m.UploadedAt)
            .IsRequired()
            .HasDefaultValueSql("GETUTCDATE()");
            
        // Relaties
        builder.HasOne(m => m.Device)
            .WithMany(d => d.Manuals)
            .HasForeignKey(m => m.DeviceId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
