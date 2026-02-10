using DmsVipPro.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;

namespace DmsVipPro.Tests.Infrastructure;

public class CloudinaryServiceTests
{
    private readonly Mock<IConfiguration> _mockConfiguration;
    private readonly Mock<ILogger<CloudinaryService>> _mockLogger;

    public CloudinaryServiceTests()
    {
        _mockConfiguration = new Mock<IConfiguration>();
        _mockLogger = new Mock<ILogger<CloudinaryService>>();
        
        // Mock configuration
        _mockConfiguration.Setup(c => c["Cloudinary:CloudName"]).Returns("test_cloud");
        _mockConfiguration.Setup(c => c["Cloudinary:ApiKey"]).Returns("test_key");
        _mockConfiguration.Setup(c => c["Cloudinary:ApiSecret"]).Returns("test_secret");
    }

    [Fact]
    public void Constructor_ShouldInitialize_WhenConfigurationIsValid()
    {
        // Act
        var service = new CloudinaryService(_mockConfiguration.Object, _mockLogger.Object);

        // Assert
        Assert.NotNull(service);
    }
    
    [Fact]
    public void Constructor_ShouldLogWarning_WhenConfigurationIsMissing()
    {
        // Arrange
        var emptyConfig = new Mock<IConfiguration>();
        emptyConfig.Setup(c => c["Cloudinary:CloudName"]).Returns("");

        // Act
        var service = new CloudinaryService(emptyConfig.Object, _mockLogger.Object);

        // Assert
        Assert.NotNull(service);
        _mockLogger.Verify(
            x => x.Log(
                LogLevel.Warning,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString().Contains("Cloudinary configuration is missing")),
                null,
                It.IsAny<Func<It.IsAnyType, Exception, string>>()),
            Times.Once);
    }
}
