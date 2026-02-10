using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DmsVipPro.Infrastructure.Data;

namespace DmsVipPro.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<HealthController> _logger;

    public HealthController(ApplicationDbContext context, ILogger<HealthController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Basic health check endpoint
    /// </summary>
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new
        {
            status = "healthy",
            timestamp = DateTime.UtcNow,
            environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")
        });
    }

    /// <summary>
    /// Database health check endpoint
    /// </summary>
    [HttpGet("database")]
    public async Task<IActionResult> CheckDatabase()
    {
        try
        {
            // Try to connect to database
            var canConnect = await _context.Database.CanConnectAsync();
            
            if (!canConnect)
            {
                return StatusCode(503, new
                {
                    status = "unhealthy",
                    message = "Cannot connect to database",
                    timestamp = DateTime.UtcNow
                });
            }

            // Get pending migrations
            var pendingMigrations = await _context.Database.GetPendingMigrationsAsync();
            var appliedMigrations = await _context.Database.GetAppliedMigrationsAsync();

            _logger.LogInformation("Database health check successful. Applied migrations: {Count}", appliedMigrations.Count());

            return Ok(new
            {
                status = "healthy",
                database = new
                {
                    connected = true,
                    provider = _context.Database.ProviderName,
                    appliedMigrations = appliedMigrations.Count(),
                    pendingMigrations = pendingMigrations.Count(),
                    migrations = new
                    {
                        applied = appliedMigrations,
                        pending = pendingMigrations
                    }
                },
                timestamp = DateTime.UtcNow
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Database health check failed");
            
            return StatusCode(503, new
            {
                status = "unhealthy",
                message = "Database connection failed",
                error = ex.Message,
                timestamp = DateTime.UtcNow
            });
        }
    }
}
