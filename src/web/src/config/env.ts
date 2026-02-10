/**
 * Environment Configuration Utility
 * Provides type-safe access to environment variables
 */

interface AppConfig {
  // Application Configuration
  appTitle: string;
  apiBaseUrl: string;
  signalRHubUrl: string;
  enableDebug: boolean;
  logLevel: 'debug' | 'info' | 'warn' | 'error';

  // Feature Flags
  features: {
    analytics: boolean;
    notifications: boolean;
  };

  // Maps Configuration
  map: {
    defaultLat: number;
    defaultLng: number;
    defaultZoom: number;
  };

  // Environment
  environment: 'development' | 'staging' | 'production';
  isDevelopment: boolean;
  isStaging: boolean;
  isProduction: boolean;
}

/**
 * Get environment variable with fallback value
 */
function getEnvVar(key: keyof ImportMetaEnv, fallback: string = ''): string {
  return import.meta.env[key] ?? fallback;
}

/**
 * Parse boolean from string
 */
function parseBoolean(value: string): boolean {
  return value === 'true' || value === '1';
}

/**
 * Parse number from string
 */
function parseNumber(value: string, fallback: number = 0): number {
  const parsed = parseFloat(value);
  return isNaN(parsed) ? fallback : parsed;
}

/**
 * Application configuration object
 */
export const config: AppConfig = {
  // Application Configuration
  appTitle: getEnvVar('VITE_APP_TITLE', 'DMS VIP Pro'),
  apiBaseUrl: getEnvVar('VITE_API_BASE_URL', 'http://localhost:5000/api'),
  signalRHubUrl: getEnvVar('VITE_SIGNALR_HUB_URL', 'http://localhost:5000/hubs'),
  enableDebug: parseBoolean(getEnvVar('VITE_ENABLE_DEBUG', 'false')),
  logLevel: (getEnvVar('VITE_LOG_LEVEL', 'info') as AppConfig['logLevel']),

  // Feature Flags
  features: {
    analytics: parseBoolean(getEnvVar('VITE_FEATURE_ANALYTICS', 'false')),
    notifications: parseBoolean(getEnvVar('VITE_FEATURE_NOTIFICATIONS', 'true')),
  },

  // Maps Configuration
  map: {
    defaultLat: parseNumber(getEnvVar('VITE_MAP_DEFAULT_LAT', '10.8231')),
    defaultLng: parseNumber(getEnvVar('VITE_MAP_DEFAULT_LNG', '106.6297')),
    defaultZoom: parseNumber(getEnvVar('VITE_MAP_DEFAULT_ZOOM', '13')),
  },

  // Environment
  environment: (getEnvVar('VITE_NODE_ENV', 'development') as AppConfig['environment']),
  isDevelopment: getEnvVar('VITE_NODE_ENV', 'development') === 'development',
  isStaging: getEnvVar('VITE_NODE_ENV', 'development') === 'staging',
  isProduction: getEnvVar('VITE_NODE_ENV', 'development') === 'production',
};

/**
 * Validate required environment variables
 */
export function validateEnv(): void {
  const requiredVars: (keyof ImportMetaEnv)[] = [
    'VITE_API_BASE_URL',
    'VITE_SIGNALR_HUB_URL',
  ];

  const missing = requiredVars.filter((key) => !import.meta.env[key]);

  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(', ')}\n` +
      'Please check your .env file and ensure all required variables are set.'
    );
  }
}

/**
 * Get environment info for debugging
 */
export function getEnvInfo(): Record<string, unknown> {
  return {
    environment: config.environment,
    apiBaseUrl: config.apiBaseUrl,
    enableDebug: config.enableDebug,
    logLevel: config.logLevel,
    features: config.features,
  };
}

// Validate environment on module load in development
if (config.isDevelopment || config.isStaging) {
  try {
    validateEnv();
    console.log('✅ Environment variables validated successfully');
    if (config.enableDebug) {
      console.log('🔧 Environment Info:', getEnvInfo());
    }
  } catch (error) {
    console.error('❌ Environment validation failed:', error);
  }
}

export default config;
