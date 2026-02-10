using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using DmsVipPro.Application.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace DmsVipPro.Infrastructure.Services;

public class CloudinaryService : IFileService
{
    private readonly Cloudinary? _cloudinary;
    private readonly ILogger<CloudinaryService> _logger;

    public CloudinaryService(IConfiguration configuration, ILogger<CloudinaryService> logger)
    {
        _logger = logger;
        
        var cloudName = configuration["Cloudinary:CloudName"];
        var apiKey = configuration["Cloudinary:ApiKey"];
        var apiSecret = configuration["Cloudinary:ApiSecret"];

        // Initialize with credentials if available, otherwise log warning
        if (!string.IsNullOrEmpty(cloudName) && !string.IsNullOrEmpty(apiKey) && !string.IsNullOrEmpty(apiSecret))
        {
            var account = new Account(cloudName, apiKey, apiSecret);
            _cloudinary = new Cloudinary(account);
            _cloudinary.Api.Secure = true;
        }
        else
        {
            _logger.LogWarning("Cloudinary configuration is missing. File uploads will fail.");
        }
    }

    public async Task<string> UploadFileAsync(IFormFile file, string folderName)
    {
        if (_cloudinary == null)
        {
            throw new InvalidOperationException("Cloudinary service is not configured.");
        }

        if (file == null || file.Length == 0)
        {
            throw new ArgumentException("File is empty", nameof(file));
        }

        try 
        {
            using var stream = file.OpenReadStream();
            
            var uploadParams = new ImageUploadParams
            {
                File = new FileDescription(file.FileName, stream),
                Folder = folderName,
                Transformation = new Transformation().Quality("auto").FetchFormat("auto"),
                Overwrite = true
            };

            var uploadResult = await _cloudinary.UploadAsync(uploadParams);

            if (uploadResult.Error != null)
            {
                _logger.LogError("Cloudinary upload error: {Error}", uploadResult.Error.Message);
                throw new Exception($"Cloudinary upload failed: {uploadResult.Error.Message}");
            }

            return uploadResult.SecureUrl.ToString();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error uploading file to Cloudinary");
            throw;
        }
    }

    public async Task DeleteFileAsync(string fileUrl)
    {
        if (_cloudinary == null || string.IsNullOrEmpty(fileUrl))
        {
            return;
        }

        try
        {
            // Extract public ID from URL
            // Example: https://res.cloudinary.com/cloudname/image/upload/v1234567890/folder/filename.jpg
            var uri = new Uri(fileUrl);
            var pathSegments = uri.Segments;
            
            // Find "upload" segment to locate the start of the path
            int uploadIndex = -1;
            for (int i = 0; i < pathSegments.Length; i++)
            {
                if (pathSegments[i].Trim('/').Equals("upload", StringComparison.OrdinalIgnoreCase))
                {
                    uploadIndex = i;
                    break;
                }
            }

            if (uploadIndex != -1 && uploadIndex + 2 < pathSegments.Length)
            {
                // Skip "upload" and version "v12345/"
                // Join remaining segments: folder/filename.jpg
                var relevantSegments = string.Join("", pathSegments.Skip(uploadIndex + 2));
                
                // Remove extension to get public ID: folder/filename
                var publicId = Path.ChangeExtension(relevantSegments, null);

                var deletionParams = new DeletionParams(publicId);
                var result = await _cloudinary.DestroyAsync(deletionParams);

                if (result.Result != "ok" && result.Result != "not found")
                {
                     _logger.LogWarning("Failed to delete file from Cloudinary. Result: {Result}, PublicId: {PublicId}", result.Result, publicId);
                }
            }
        }
        catch (Exception ex)
        {
             _logger.LogError(ex, "Error deleting file from Cloudinary: {Url}", fileUrl);
        }
    }
}
