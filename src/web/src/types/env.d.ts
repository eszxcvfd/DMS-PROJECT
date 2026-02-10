/// <reference types="vite/client" />

interface ImportMetaEnv {
  // Application Configuration
  readonly VITE_APP_TITLE: string;
  readonly VITE_API_BASE_URL: string;
  readonly VITE_SIGNALR_HUB_URL: string;
  readonly VITE_ENABLE_DEBUG: string;
  readonly VITE_LOG_LEVEL: 'debug' | 'info' | 'warn' | 'error';

  // Feature Flags
  readonly VITE_FEATURE_ANALYTICS: string;
  readonly VITE_FEATURE_NOTIFICATIONS: string;

  // Maps Configuration
  readonly VITE_MAP_DEFAULT_LAT: string;
  readonly VITE_MAP_DEFAULT_LNG: string;
  readonly VITE_MAP_DEFAULT_ZOOM: string;

  // Environment
  readonly VITE_NODE_ENV: 'development' | 'staging' | 'production';
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

declare const __APP_ENV__: string;
