using FluentValidation;

namespace Manuals.Application.Commands.CreateManual;

/// <summary>
/// Validator voor het CreateManualCommand
/// </summary>
public class CreateManualCommandValidator : AbstractValidator<CreateManualCommand>
{
    public CreateManualCommandValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Titel is verplicht.")
            .MaximumLength(200).WithMessage("Titel mag niet langer zijn dan 200 karakters.");
            
        RuleFor(x => x.Brand)
            .NotEmpty().WithMessage("Merk is verplicht.")
            .MaximumLength(100).WithMessage("Merk mag niet langer zijn dan 100 karakters.");
            
        RuleFor(x => x.ModelNumber)
            .NotEmpty().WithMessage("Modelnummer is verplicht.")
            .MaximumLength(50).WithMessage("Modelnummer mag niet langer zijn dan 50 karakters.");
            
        RuleFor(x => x.PdfFile)
            .NotNull().WithMessage("PDF bestand is verplicht.")
            .Must(x => x != null && x.ContentType == "application/pdf")
            .WithMessage("Bestand moet een PDF document zijn.");
            
        RuleFor(x => x.PdfFile.Length)
            .LessThanOrEqualTo(10 * 1024 * 1024) // 10 MB
            .WithMessage("PDF bestand mag niet groter zijn dan 10 MB.");
    }
}
