using Microsoft.AspNetCore.Http;

namespace DmsVipPro.Application.Interfaces;

public interface IFileService
{
    Task<string> UploadFileAsync(IFormFile file, string folderName);
    Task DeleteFileAsync(string fileUrl);
}
