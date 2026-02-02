# ADR-006: Offline-First Mobile Architecture

## Status

Accepted

## Date

2026-02-02

## Context

DILIGO DMS mobile app is used by field sales representatives (NVBH) who frequently work in areas with poor or no internet connectivity. The app must support full functionality offline and sync data when connectivity is restored.

## Decision Drivers

- **Network reliability**: Rural Vietnam has inconsistent coverage
- **User productivity**: Work cannot stop due to connectivity issues
- **Data integrity**: No data loss during offline periods
- **Battery efficiency**: Minimize network operations
- **Sync complexity**: Handle conflicts gracefully

## Considered Options

### 1. Offline-First (Local-First)
- All data in local database
- Background sync when online
- Conflict resolution strategy
- Full functionality offline

### 2. Cache-Only
- Cache recently accessed data
- Require network for writes
- Limited offline functionality
- Simpler implementation

### 3. Online-Only with Retry
- Queue failed requests
- Retry when online
- Blocking on network errors
- Simplest implementation

### 4. PWA Service Worker
- Web-based offline
- Limited native features
- Browser dependency
- Not suitable for Android app

## Decision

**We will implement an Offline-First architecture using Room (SQLite) with background sync via WorkManager.**

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              OFFLINE-FIRST ARCHITECTURE                                  │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                              ANDROID APP                                         │   │
│  │                                                                                  │   │
│  │   ┌─────────────────┐                                                           │   │
│  │   │    UI Layer     │                                                           │   │
│  │   │   (Compose)     │                                                           │   │
│  │   └────────┬────────┘                                                           │   │
│  │            │ observes                                                            │   │
│  │            ▼                                                                     │   │
│  │   ┌─────────────────┐                                                           │   │
│  │   │   Repository    │◄──────────────── Single Source of Truth                   │   │
│  │   │    (Local DB)   │                                                           │   │
│  │   └────────┬────────┘                                                           │   │
│  │            │                                                                     │   │
│  │     ┌──────┴──────┐                                                             │   │
│  │     │             │                                                             │   │
│  │     ▼             ▼                                                             │   │
│  │   ┌───────┐   ┌───────┐                                                        │   │
│  │   │ Room  │   │Pending│                                                        │   │
│  │   │  DAO  │   │ Sync  │                                                        │   │
│  │   │       │   │ Queue │                                                        │   │
│  │   └───────┘   └───┬───┘                                                        │   │
│  │                   │                                                             │   │
│  │                   ▼                                                             │   │
│  │   ┌─────────────────────────────────────────────────────────────────────────┐  │   │
│  │   │                         SYNC ENGINE                                      │  │   │
│  │   │                                                                          │  │   │
│  │   │   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐               │  │   │
│  │   │   │ WorkManager  │   │  Network     │   │  Conflict    │               │  │   │
│  │   │   │ (Background) │   │  Monitor     │   │  Resolver    │               │  │   │
│  │   │   └──────────────┘   └──────────────┘   └──────────────┘               │  │   │
│  │   │                                                                          │  │   │
│  │   └──────────────────────────────────────────────────────────────────────────┘  │   │
│  │                                    │                                             │   │
│  └────────────────────────────────────┼─────────────────────────────────────────────┘   │
│                                       │                                                  │
│                                       │ When Online                                      │
│                                       ▼                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                              API SERVER                                          │   │
│  │                                                                                  │   │
│  │   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐                       │   │
│  │   │ GET /sync    │   │ POST /sync   │   │ Conflict     │                       │   │
│  │   │ (Download)   │   │ (Upload)     │   │ Detection    │                       │   │
│  │   └──────────────┘   └──────────────┘   └──────────────┘                       │   │
│  │                                                                                  │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### Rationale

1. **User Experience**: NVBH can work seamlessly regardless of connectivity. No blocking operations.

2. **Data Reliability**: Local database as source of truth prevents data loss.

3. **Battery Efficiency**: WorkManager batches sync operations and respects battery/network constraints.

4. **Conflict Handling**: Explicit conflict resolution strategy for predictable behavior.

## Data Sync Strategy

### Download (Server → Mobile)

```kotlin
// Delta sync - only fetch changes since last sync
suspend fun syncDownload() {
    val lastSyncTime = syncMetadataDao.getLastSyncTime()

    val response = api.getDeltaSync(since = lastSyncTime)

    database.withTransaction {
        // Upsert customers, products, routes
        customerDao.upsertAll(response.customers)
        productDao.upsertAll(response.products)
        routeDao.upsertAll(response.routes)

        // Update sync timestamp
        syncMetadataDao.updateLastSyncTime(response.serverTime)
    }
}
```

### Upload (Mobile → Server)

```kotlin
// Upload pending changes
suspend fun syncUpload() {
    val pendingVisits = visitDao.getPendingSyncVisits()
    val pendingOrders = orderDao.getPendingSyncOrders()
    val pendingPhotos = photoDao.getPendingSyncPhotos()

    val response = api.uploadSync(
        visits = pendingVisits,
        orders = pendingOrders,
        photos = pendingPhotos
    )

    database.withTransaction {
        // Update local records with server IDs
        response.visitMappings.forEach { (localId, serverId) ->
            visitDao.updateServerId(localId, serverId)
        }

        // Mark as synced
        visitDao.markAsSynced(pendingVisits.map { it.id })
        orderDao.markAsSynced(pendingOrders.map { it.id })
    }
}
```

## Conflict Resolution

| Data Type | Strategy | Rationale |
|-----------|----------|-----------|
| **Master Data** (Customers, Products) | Server Wins | Admin changes are authoritative |
| **Visits** | Last Write Wins | Timestamp-based, no merge needed |
| **Orders** | Server Wins for Status | Server handles approval workflow |
| **Photos** | Merge | All photos should be kept |

```kotlin
// Conflict resolution example
sealed class ConflictResolution {
    object ServerWins : ConflictResolution()
    object ClientWins : ConflictResolution()
    object Merge : ConflictResolution()
    data class Manual(val reason: String) : ConflictResolution()
}

fun resolveConflict(local: Order, server: Order): Order {
    return when {
        // Server status takes precedence (approval workflow)
        server.status != local.status -> server.copy(items = local.items)
        // Client changes to items preserved
        local.updatedAt > server.updatedAt -> local.copy(status = server.status)
        else -> server
    }
}
```

## WorkManager Configuration

```kotlin
// Periodic sync worker
class SyncWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        return try {
            syncRepository.syncDownload()
            syncRepository.syncUpload()
            Result.success()
        } catch (e: Exception) {
            if (runAttemptCount < 3) Result.retry()
            else Result.failure()
        }
    }
}

// Schedule periodic sync
val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(
    repeatInterval = 15,
    repeatIntervalTimeUnit = TimeUnit.MINUTES
)
    .setConstraints(
        Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .setRequiresBatteryNotLow(true)
            .build()
    )
    .setBackoffCriteria(
        BackoffPolicy.EXPONENTIAL,
        WorkRequest.MIN_BACKOFF_MILLIS,
        TimeUnit.MILLISECONDS
    )
    .build()

WorkManager.getInstance(context).enqueueUniquePeriodicWork(
    "sync",
    ExistingPeriodicWorkPolicy.KEEP,
    syncRequest
)
```

## Local Database Schema

```kotlin
@Entity(tableName = "orders")
data class OrderEntity(
    @PrimaryKey
    val localId: String = UUID.randomUUID().toString(),
    val serverId: String? = null,
    val customerId: String,
    val orderDate: Long,
    val status: String,
    val totalAmount: Double,
    val syncStatus: SyncStatus = SyncStatus.PENDING,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)

enum class SyncStatus {
    PENDING,      // Created offline, not yet synced
    SYNCING,      // Currently being uploaded
    SYNCED,       // Successfully synced with server
    CONFLICT,     // Conflict detected, needs resolution
    FAILED        // Sync failed after retries
}
```

## Consequences

### Positive

- Full app functionality offline
- No data loss during connectivity gaps
- Smooth user experience
- Battery-efficient sync
- Clear conflict resolution

### Negative

- Increased app complexity
- Larger app storage footprint
- Sync bugs can be hard to debug
- Eventual consistency model

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Sync conflicts | Medium | Medium | Clear resolution rules, user notification |
| Data inconsistency | Low | High | Validation, periodic full sync |
| Storage full | Low | Medium | Data expiration, cleanup job |
| Sync queue backup | Medium | Low | Priority ordering, manual trigger |

## References

- [Android Offline-First Documentation](https://developer.android.com/topic/architecture/data-layer/offline-first)
- [WorkManager Guide](https://developer.android.com/topic/libraries/architecture/workmanager)
- [08-MOBILE-ARCHITECTURE.md](../08-MOBILE-ARCHITECTURE.md)
