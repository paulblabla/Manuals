using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Manuals.Infrastructure.Persistence;

/// <summary>
/// Initialiseert en seed de database
/// </summary>
public class ApplicationDbContextInitializer
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ApplicationDbContextInitializer> _logger;

    public ApplicationDbContextInitializer(
        ApplicationDbContext context,
        ILogger<ApplicationDbContextInitializer> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Initialiseert de database (creëert indien nodig)
    /// </summary>
    public async Task InitializeAsync()
    {
        try
        {
            // Controleer of er een migratie nodig is
            if (_context.Database.IsSqlServer() && (await _context.Database.GetPendingMigrationsAsync()).Any())
            {
                _logger.LogInformation("Database migraties worden toegepast");
                await _context.Database.MigrateAsync();
                _logger.LogInformation("Database migraties succesvol toegepast");
            }
            else if (!await _context.Database.CanConnectAsync())
            {
                _logger.LogInformation("Database wordt aangemaakt");
                await _context.Database.EnsureCreatedAsync();
                _logger.LogInformation("Database succesvol aangemaakt");
            }
            else
            {
                _logger.LogInformation("Database is up-to-date, geen actie nodig");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Er is een fout opgetreden bij het initialiseren van de database");
            throw;
        }
    }

    /// <summary>
    /// Seed de database met initiële data (alleen in development)
    /// </summary>
    public async Task SeedAsync()
    {
        try
        {
            await TrySeedAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Er is een fout opgetreden bij het seeden van de database");
            throw;
        }
    }

    private async Task TrySeedAsync()
    {
        // Seed alleen als er nog geen devices zijn
        if (!_context.Devices.Any())
        {
            _logger.LogInformation("Database wordt geseeded met testdata");

            // Voeg enkele voorbeeldapparaten toe
            _context.Devices.AddRange(
                new Domain.Entities.Device
                {
                    Name = "Wasmachine Samsung EcoBubble",
                    DeviceType = "Wasmachine",
                    Brand = "Samsung",
                    ModelNumber = "WW90T684DLH",
                    SerialNumber = "WM202201001",
                    PurchaseDate = new DateTime(2022, 1, 15),
                    Location = "Bijkeuken"
                },
                new Domain.Entities.Device
                {
                    Name = "Bosch Vaatwasser",
                    DeviceType = "Vaatwasser",
                    Brand = "Bosch",
                    ModelNumber = "SMV4HTX31E",
                    SerialNumber = "DW202108123",
                    PurchaseDate = new DateTime(2021, 8, 5),
                    Location = "Keuken"
                },
                new Domain.Entities.Device
                {
                    Name = "Philips Airfryer XXL",
                    DeviceType = "Airfryer",
                    Brand = "Philips",
                    ModelNumber = "HD9650/90",
                    SerialNumber = "AF202010999",
                    PurchaseDate = new DateTime(2020, 10, 22),
                    Location = "Keuken"
                }
            );

            await _context.SaveChangesAsync();
            _logger.LogInformation("Seed voltooid");
        }
        else
        {
            _logger.LogInformation("Database bevat al data, geen seed nodig");
        }
    }
}
