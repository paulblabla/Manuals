namespace Manuals.Domain.Exceptions;

/// <summary>
/// Exception voor het geval dat een opgevraagde resource niet bestaat
/// </summary>
public class NotFoundException : Exception
{
    public NotFoundException() : base("De opgevraagde resource werd niet gevonden.")
    {
    }

    public NotFoundException(string message) : base(message)
    {
    }

    public NotFoundException(string message, Exception innerException) : base(message, innerException)
    {
    }

    public NotFoundException(string name, object key) : base($"Entity '{name}' ({key}) werd niet gevonden.")
    {
    }
}
