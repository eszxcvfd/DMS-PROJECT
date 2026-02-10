# Backend Configuration Setup

## Required Configuration Files

Copy `appsettings.example.json` to create your environment-specific configuration files:

```bash
# Development
cp appsettings.example.json appsettings.Development.json

# Staging
cp appsettings.example.json appsettings.Staging.json

# Production
cp appsettings.example.json appsettings.Production.json
```

## Configuration Values

### Database Connection (Neon PostgreSQL)
```json
"ConnectionStrings": {
  "DefaultConnection": "Host=your-neon-host;Database=neondb;Username=your-username;Password=your-password;SSL Mode=Require;Trust Server Certificate=true"
}
```

Get your connection string from: [Neon Console](https://console.neon.tech/)

### Cloudinary Setup
```json
"Cloudinary": {
  "CloudName": "your-cloud-name",
  "ApiKey": "your-api-key",
  "ApiSecret": "your-api-secret"
}
```

Get your credentials from: [Cloudinary Console](https://console.cloudinary.com/)

### CORS Configuration
```json
"AllowedOrigins": [
  "http://localhost:5173",  // Vite dev server
  "http://localhost:3000",  // Alternative frontend
  "https://yourdomain.com"  // Production domain
]
```

## Security Notes

⚠️ **NEVER commit actual credentials to git!**

- ✅ `appsettings.example.json` - Template only (committed)
- ❌ `appsettings.json` - Ignored by git
- ❌ `appsettings.Development.json` - Ignored by git
- ❌ `appsettings.Staging.json` - Ignored by git
- ❌ `appsettings.Production.json` - Ignored by git

Use environment variables in production for sensitive data.
