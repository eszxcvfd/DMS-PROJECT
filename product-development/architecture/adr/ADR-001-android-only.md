# ADR-001: Android-Only Mobile Platform

## Status

Accepted

## Date

2026-02-02

## Context

DMS VIPPro requires a mobile application for field sales representatives (NVBH) to perform their daily tasks including customer visits, order creation, and photo capture. We need to decide which mobile platform(s) to support.

The target users (NVBH) are field workers who may not have high-end devices. The application needs to work reliably in areas with poor connectivity and support offline operations.

## Decision Drivers

- **Cost constraints**: Free tier deployment is a primary requirement
- **Target audience**: Vietnam market where Android dominates (>80% market share)
- **Development resources**: Single developer/small team
- **Feature requirements**: GPS tracking, camera, offline storage, background sync
- **Time to market**: Need to launch quickly with Phase 1 features

## Considered Options

### 1. Native Android (Kotlin)
- Single platform development
- Full access to native APIs
- Best performance for GPS and camera
- One codebase to maintain

### 2. Native iOS (Swift) + Android (Kotlin)
- Covers both platforms
- Best UX for each platform
- Double development effort
- Double maintenance cost

### 3. Cross-Platform (Flutter)
- Single codebase for both platforms
- Good performance
- Requires learning Dart
- Some native features may need plugins

### 4. Cross-Platform (React Native)
- Single codebase
- JavaScript ecosystem
- Performance overhead
- Native modules for complex features

### 5. Progressive Web App (PWA)
- Single codebase
- Limited offline capabilities
- No app store presence
- Limited native API access

## Decision

**We will develop a native Android application using Kotlin.**

### Rationale

1. **Market Fit**: Android has >80% market share in Vietnam. Supporting iOS would only reach <20% of potential users while doubling development cost.

2. **Native Performance**: GPS tracking, camera operations, and offline sync require reliable native performance. Kotlin provides direct access to Android APIs.

3. **Cost Efficiency**: Single platform means single codebase, single testing effort, and single deployment pipeline. This aligns with the free-tier budget constraint.

4. **Offline Requirements**: Room database (SQLite) provides excellent offline support with seamless sync capabilities. Native integration is more reliable than cross-platform alternatives.

5. **Background Operations**: Android's WorkManager provides robust background sync that's essential for the offline-first architecture.

6. **Play Store**: One-time $25 registration fee vs $99/year for Apple Developer Program.

## Consequences

### Positive

- Reduced development time and cost
- Full native API access for GPS, camera, background services
- Better battery optimization with native implementation
- Simpler CI/CD pipeline
- Easier debugging and testing
- Strong community support and documentation

### Negative

- iOS users cannot use the app
- Potential limitation if company wants to expand to iOS later
- No code reuse if iOS version is eventually needed
- Limited to Android-specific skills

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| iOS demand from users | Low | Medium | Monitor feedback, budget for iOS if needed |
| Android fragmentation | Medium | Low | Target API 26+ (Android 8.0), covers 95%+ devices |
| Kotlin skill shortage | Low | Medium | Kotlin is widely adopted, easy to learn from Java |

## Future Considerations

If iOS support becomes necessary in the future:

1. **Option A**: Develop native iOS app separately (estimated 3-4 months)
2. **Option B**: Migrate to Kotlin Multiplatform (shares business logic)
3. **Option C**: Rewrite in Flutter (complete rewrite, but unified codebase)

The modular architecture (Clean Architecture) will facilitate any of these options by keeping business logic separate from platform-specific code.

## References

- [StatCounter Vietnam Mobile OS Market Share](https://gs.statcounter.com/os-market-share/mobile/viet-nam)
- [Android Kotlin Documentation](https://developer.android.com/kotlin)
- [02-CONTAINER-ARCHITECTURE.md](../02-CONTAINER-ARCHITECTURE.md)
