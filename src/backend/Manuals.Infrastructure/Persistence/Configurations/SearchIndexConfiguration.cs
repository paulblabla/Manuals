using Manuals.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System.Text.Json;

namespace Manuals.Infrastructure.Persistence.Configurations;

/// <summary>
/// Entity Framework configuratie voor SearchIndex entity
/// </summary>
public class SearchIndexConfiguration : IEntityTypeConfiguration<SearchIndex>
{
    public void Configure(EntityTypeBuilder<SearchIndex> builder)
    {
        // Primaire sleutel
        builder.HasKey(si => si.Id);
        
        // Properties
        builder.Property(si => si.Content)
            .IsRequired()
            .HasColumnType("nvarchar(max)");
        
        // Embeddings opslaan als JSON array
        builder.Property(si => si.Embedding)
            .HasConversion(
                v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                v => JsonSerializer.Deserialize<float[]>(v, (JsonSerializerOptions?)null) ?? Array.Empty<float>())
            .HasColumnType("nvarchar(max)");
            
        builder.Property(si => si.SectionTitle)
            .HasMaxLength(255);
        
        // Relaties
        builder.HasOne<Manual>()
            .WithMany()
            .HasForeignKey(si => si.ManualId)
            .OnDelete(DeleteBehavior.Cascade);
            
        // Indexen voor zoekfunctionaliteit
        builder.HasIndex(si => si.ManualId);
    }
}
