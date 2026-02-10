using Microsoft.AspNetCore.Mvc;
using DmsVipPro.Application.Interfaces;
using Microsoft.Extensions.Configuration;

namespace DmsVipPro.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CloudinaryController : ControllerBase
{
    private readonly IFileService _fileService;
    private readonly IConfiguration _configuration;
    private readonly ILogger<CloudinaryController> _logger;

    public CloudinaryController(
        IFileService fileService, 
        IConfiguration configuration,
        ILogger<CloudinaryController> logger)
    {
        _fileService = fileService;
        _configuration = configuration;
        _logger = logger;
    }

    /// <summary>
    /// Check Cloudinary configuration
    /// </summary>
    [HttpGet("config")]
    public IActionResult GetConfig()
    {
        var cloudName = _configuration["Cloudinary:CloudName"];
        var apiKey = _configuration["Cloudinary:ApiKey"];
        var apiSecret = _configuration["Cloudinary:ApiSecret"];

        var isConfigured = !string.IsNullOrEmpty(cloudName) 
            && !string.IsNullOrEmpty(apiKey) 
            && !string.IsNullOrEmpty(apiSecret);

        return Ok(new
        {
            configured = isConfigured,
            cloudName = cloudName,
            apiKey = apiKey?.Substring(0, Math.Min(4, apiKey.Length)) + "****", // Masked
            hasApiSecret = !string.IsNullOrEmpty(apiSecret),
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Upload a file to Cloudinary
    /// </summary>
    [HttpPost("upload")]
    public async Task<IActionResult> Upload([FromForm] IFormFile file, [FromForm] string folder = "uploads")
    {
        try
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest(new { message = "No file provided" });
            }

            _logger.LogInformation("Uploading file: {FileName}, Size: {Size} bytes, Folder: {Folder}", 
                file.FileName, file.Length, folder);

            var url = await _fileService.UploadFileAsync(file, folder);

            return Ok(new
            {
                success = true,
                url = url,
                fileName = file.FileName,
                fileSize = file.Length,
                folder = folder,
                timestamp = DateTime.UtcNow
            });
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogError(ex, "Cloudinary not configured");
            return StatusCode(503, new { message = "Cloudinary service is not configured", error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Upload failed");
            return StatusCode(500, new { message = "Upload failed", error = ex.Message });
        }
    }

    /// <summary>
    /// Delete a file from Cloudinary
    /// </summary>
    [HttpDelete("delete")]
    public async Task<IActionResult> Delete([FromQuery] string fileUrl)
    {
        try
        {
            if (string.IsNullOrEmpty(fileUrl))
            {
                return BadRequest(new { message = "File URL is required" });
            }

            await _fileService.DeleteFileAsync(fileUrl);

            return Ok(new
            {
                success = true,
                message = "File deleted successfully",
                fileUrl = fileUrl,
                timestamp = DateTime.UtcNow
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Delete failed for URL: {FileUrl}", fileUrl);
            return StatusCode(500, new { message = "Delete failed", error = ex.Message });
        }
    }
}
