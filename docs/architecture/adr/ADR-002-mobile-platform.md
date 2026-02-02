# ADR-002: Mobile Platform Selection

## Status
**Accepted** - 2026-02-02

## Context

We need to develop a mobile application for field sales representatives (NVBH) that supports:
- GPS location tracking in the background
- Camera integration for product/store photos
- Offline data storage and synchronization
- Push notifications
- Biometric authentication
- Optimal battery consumption

Key constraints:
- Android platform required (per stakeholder requirement)
- Native-like performance for GPS and camera
- Reliable background processing
- Offline-first architecture

## Decision

We will use **Native Android with Kotlin** and Jetpack Compose for the mobile application.

### Specific Technologies:
- **Kotlin 1.9.x** - Primary language
- **Jetpack Compose 1.5.x** - Modern declarative UI
- **Hilt** - Dependency injection
- **Room Database** - Local SQLite storage
- **WorkManager** - Background task scheduling
- **Retrofit + OkHttp** - Network communication
- **Coil** - Image loading
- **Google Maps SDK** - Mapping and location

### Architecture Pattern:
- MVVM + Clean Architecture
- Offline-first with sync queue

## Consequences

### Positive
- **Performance**: Native performance for GPS, camera, and background processing
- **Battery optimization**: Full control over battery-efficient location tracking
- **Offline support**: Room database provides robust local storage
- **Platform features**: Direct access to all Android APIs without bridges
- **Jetpack Compose**: Modern, declarative UI with excellent developer experience
- **Kotlin coroutines**: Elegant async programming for sync operations
- **Google ecosystem**: Seamless integration with Google Maps, FCM, Play Store

### Negative
- **Android only**: No code sharing with potential iOS app
- **Development cost**: Native development typically costs more than cross-platform
- **Team expertise**: Requires Android-specific expertise

### Risks
- **iOS demand**: Future iOS requirement would need separate development
- **Mitigation**: Architecture designed to share business logic concepts

## Alternatives Considered

### Flutter
- **Pros**: Cross-platform, single codebase, hot reload
- **Cons**:
  - Background GPS tracking has platform-specific quirks
  - Camera integration less reliable than native
  - Larger app size (~20-30 MB baseline)
  - Dart language less common in enterprise
- **Decision**: Rejected due to background processing concerns

### React Native
- **Pros**: JavaScript, large community, code sharing
- **Cons**:
  - Background location tracking issues
  - Performance overhead for heavy GPS usage
  - Bridge architecture adds latency
  - Dependency on native modules for critical features
- **Decision**: Rejected due to performance concerns for location-heavy app

### Kotlin Multiplatform Mobile (KMM)
- **Pros**: Share business logic, native UI
- **Cons**:
  - Still maturing ecosystem
  - Limited iOS-specific resources in team
  - Additional complexity for code sharing
- **Decision**: Considered for future, rejected for initial release

### Java (Native Android)
- **Pros**: Mature, stable, large talent pool
- **Cons**:
  - Verbose compared to Kotlin
  - No null safety
  - Less modern async patterns
- **Decision**: Rejected in favor of Kotlin's modern features

## Implementation Notes

### Project Structure
```
app/
├── src/main/java/com/diligo/dms/
│   ├── presentation/
│   │   ├── ui/              # Compose screens
│   │   ├── viewmodel/       # ViewModels
│   │   └── navigation/      # Navigation graphs
│   ├── domain/
│   │   ├── model/           # Domain models
│   │   ├── usecase/         # Use cases
│   │   └── repository/      # Repository interfaces
│   ├── data/
│   │   ├── remote/          # Retrofit services
│   │   ├── local/           # Room database
│   │   ├── repository/      # Implementations
│   │   └── sync/            # Sync manager
│   └── di/                  # Hilt modules
```

### Key Dependencies
```kotlin
// build.gradle.kts
dependencies {
    // Core
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")

    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.01.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")

    // DI
    implementation("com.google.dagger:hilt-android:2.48")

    // Database
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")

    // Network
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")

    // Background
    implementation("androidx.work:work-runtime-ktx:2.9.0")

    // Location
    implementation("com.google.android.gms:play-services-location:21.0.1")
    implementation("com.google.android.gms:play-services-maps:18.2.0")
}
```

### Offline-First Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer                              │
│              (Jetpack Compose + ViewModel)              │
├─────────────────────────────────────────────────────────┤
│                   Domain Layer                           │
│              (Use Cases + Repository Interfaces)         │
├─────────────────────────────────────────────────────────┤
│                    Data Layer                            │
│  ┌─────────────────┐      ┌─────────────────┐          │
│  │  Room Database  │◄────►│  Sync Manager   │          │
│  │  (Local First)  │      │  (WorkManager)  │          │
│  └─────────────────┘      └────────┬────────┘          │
│                                    │                    │
│                           ┌────────▼────────┐          │
│                           │   Remote API    │          │
│                           │   (Retrofit)    │          │
│                           └─────────────────┘          │
└─────────────────────────────────────────────────────────┘
```

## References

- [Android Developer Guidelines](https://developer.android.com/guide)
- [Jetpack Compose Documentation](https://developer.android.com/jetpack/compose)
- [WorkManager for Background Tasks](https://developer.android.com/topic/libraries/architecture/workmanager)
- [Room Persistence Library](https://developer.android.com/training/data-storage/room)
