using AutoMapper;
using Manuals.Application.Commands.CreateManual;
using Manuals.Application.Queries.GetManualById;
using Manuals.Domain.Entities;

namespace Manuals.Application.Mappings;

/// <summary>
/// AutoMapper profiel voor object mappings
/// </summary>
public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // Domain naar DTO mappings
        CreateMap<Manual, ManualDto>()
            .ForMember(dest => dest.DeviceName, opt => opt.MapFrom(src => 
                src.Device != null ? src.Device.Name : null));
            
        // Command naar domain mappings
        CreateMap<CreateManualCommand, Manual>()
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.BlobId, opt => opt.Ignore())
            .ForMember(dest => dest.Device, opt => opt.Ignore())
            .ForMember(dest => dest.UploadedAt, opt => opt.MapFrom(_ => DateTime.UtcNow));
    }
}
