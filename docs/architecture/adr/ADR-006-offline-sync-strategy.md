# ADR-006: Offline Sync Strategy

## Status
**Accepted** - 2026-02-02

## Context

Field sales representatives (NVBH) often work in areas with poor or no network connectivity. The mobile application must:
- Allow creating orders offline
- Support check-in/check-out without network
- Capture and store photos locally
- Sync data when connectivity is restored
- Handle conflicts between offline and server data
- Maintain data integrity across sync cycles

Key challenges:
- Network unpredictability in rural areas
- Large photo files for upload
- Conflict resolution for concurrent edits
- Battery efficiency for background sync

## Decision

We will implement an **Offline-First Architecture** with:
- **Room Database** for local storage
- **WorkManager** for reliable background sync
- **Optimistic sync** with server-wins conflict resolution
- **Queue-based uploads** for photos and orders

### Sync Strategy:
- **Master data** (products, customers): Server → Device (read-only locally)
- **Transactional data** (orders, visits): Device → Server (write locally, sync up)
- **Photos**: Queue for upload, compress before sync

## Consequences

### Positive
- **Works offline**: Full functionality without network
- **Responsive**: No network latency for local operations
- **Reliable**: WorkManager ensures eventual sync
- **Battery efficient**: Batched sync, respects battery state
- **Data integrity**: Local database as source of truth

### Negative
- **Complexity**: Sync logic adds development overhead
- **Storage**: Local data requires device storage
- **Conflicts**: Some scenarios require careful handling
- **Stale data**: Master data may be outdated until sync

### Risks
- **Data loss**: Device failure before sync
- **Mitigation**: Frequent sync attempts, cloud backup prompts

## Sync Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Mobile App                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │  UI Layer    │───►│  Use Cases   │───►│  Repository  │      │
│  │  (Compose)   │    │              │    │  Interface   │      │
│  └──────────────┘    └──────────────┘    └──────┬───────┘      │
│                                                  │               │
│                            ┌─────────────────────┴────────┐     │
│                            │                              │     │
│                            ▼                              ▼     │
│                   ┌──────────────┐              ┌──────────────┐│
│                   │ Local Data   │              │ Remote Data  ││
│                   │   Source     │              │   Source     ││
│                   │   (Room)     │              │  (Retrofit)  ││
│                   └──────┬───────┘              └──────────────┘│
│                          │                              ▲       │
│                          ▼                              │       │
│                   ┌──────────────┐              ┌───────┴──────┐│
│                   │ Sync Queue   │─────────────►│ Sync Manager ││
│                   │   Tables     │              │ (WorkManager)││
│                   └──────────────┘              └──────────────┘│
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Implementation

### Database Schema (Room)
```kotlin
// Sync status for local entities
enum class SyncStatus {
    SYNCED,           // Synced with server
    PENDING_CREATE,   // Created locally, pending upload
    PENDING_UPDATE,   // Modified locally, pending upload
    PENDING_DELETE,   // Deleted locally, pending sync
    SYNC_FAILED       // Sync attempted but failed
}

@Entity(tableName = "orders")
data class OrderEntity(
    @PrimaryKey
    val id: String,
    val localId: String = UUID.randomUUID().toString(),
    val customerId: String,
    val orderDate: Long,
    val totalAmount: Double,
    val status: String,
    val notes: String?,

    // Sync metadata
    val syncStatus: SyncStatus = SyncStatus.PENDING_CREATE,
    val syncAttempts: Int = 0,
    val lastSyncAttempt: Long? = null,
    val serverVersion: Long = 0,
    val createdAt: Long = System.currentTimeMillis(),
    val modifiedAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "sync_queue")
data class SyncQueueItem(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val entityType: String,  // "order", "visit", "photo"
    val entityId: String,
    val operation: String,   // "create", "update", "delete"
    val payload: String,     // JSON payload
    val priority: Int = 0,   // Higher = process first
    val attempts: Int = 0,
    val createdAt: Long = System.currentTimeMillis(),
    val scheduledAt: Long = System.currentTimeMillis()
)
```

### Repository Pattern
```kotlin
class OrderRepositoryImpl @Inject constructor(
    private val localDataSource: OrderLocalDataSource,
    private val remoteDataSource: OrderRemoteDataSource,
    private val syncQueue: SyncQueueDao,
    private val networkMonitor: NetworkMonitor
) : OrderRepository {

    override suspend fun createOrder(request: CreateOrderRequest): Result<Order> {
        // 1. Save locally first
        val localOrder = request.toEntity().copy(
            syncStatus = SyncStatus.PENDING_CREATE
        )
        localDataSource.insert(localOrder)

        // 2. Queue for sync
        syncQueue.insert(SyncQueueItem(
            entityType = "order",
            entityId = localOrder.id,
            operation = "create",
            payload = Json.encodeToString(request),
            priority = 10  // Orders are high priority
        ))

        // 3. Trigger immediate sync if online
        if (networkMonitor.isOnline()) {
            SyncWorker.enqueueImmediate(workManager)
        }

        return Result.success(localOrder.toDomain())
    }

    override suspend fun getOrders(): Flow<List<Order>> {
        return localDataSource.getAllOrders()
            .map { entities -> entities.map { it.toDomain() } }
    }
}
```

### Sync Worker
```kotlin
@HiltWorker
class SyncWorker @AssistedInject constructor(
    @Assisted context: Context,
    @Assisted params: WorkerParameters,
    private val syncQueue: SyncQueueDao,
    private val orderRemoteDataSource: OrderRemoteDataSource,
    private val visitRemoteDataSource: VisitRemoteDataSource,
    private val photoUploader: PhotoUploader,
    private val orderLocalDataSource: OrderLocalDataSource,
    private val analytics: Analytics
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        try {
            // 1. Upload pending items (oldest first, respect priority)
            val pendingItems = syncQueue.getPendingItems()

            for (item in pendingItems) {
                try {
                    when (item.entityType) {
                        "order" -> syncOrder(item)
                        "visit" -> syncVisit(item)
                        "photo" -> syncPhoto(item)
                    }
                    syncQueue.delete(item)
                } catch (e: Exception) {
                    handleSyncError(item, e)
                }
            }

            // 2. Download updated master data
            downloadMasterData()

            return Result.success()
        } catch (e: Exception) {
            analytics.logSyncError(e)
            return if (runAttemptCount < 3) Result.retry() else Result.failure()
        }
    }

    private suspend fun syncOrder(item: SyncQueueItem) {
        val request = Json.decodeFromString<CreateOrderRequest>(item.payload)
        val response = orderRemoteDataSource.createOrder(request)

        // Update local with server ID and status
        orderLocalDataSource.updateAfterSync(
            localId = item.entityId,
            serverId = response.id,
            syncStatus = SyncStatus.SYNCED
        )
    }

    private suspend fun syncPhoto(item: SyncQueueItem) {
        val photoPath = item.payload
        val file = File(photoPath)

        if (!file.exists()) {
            syncQueue.delete(item)
            return
        }

        // Compress before upload
        val compressed = imageCompressor.compress(file, maxSizeMb = 1)

        // Upload with retry
        photoUploader.upload(compressed, item.entityId)
    }

    private suspend fun downloadMasterData() {
        val lastSyncTime = preferences.getLastMasterDataSync()

        // Incremental sync - only get changes since last sync
        val changes = masterDataRemoteSource.getChanges(since = lastSyncTime)

        // Update local database
        productDao.upsertAll(changes.products)
        customerDao.upsertAll(changes.customers)
        promotionDao.upsertAll(changes.promotions)

        preferences.setLastMasterDataSync(System.currentTimeMillis())
    }

    private suspend fun handleSyncError(item: SyncQueueItem, error: Exception) {
        val newAttempts = item.attempts + 1

        if (newAttempts >= MAX_ATTEMPTS) {
            // Mark as failed, notify user
            syncQueue.update(item.copy(
                attempts = newAttempts,
                scheduledAt = Long.MAX_VALUE  // Don't retry automatically
            ))
            notifyUser("Sync failed for ${item.entityType}")
        } else {
            // Exponential backoff
            val backoff = (2.0.pow(newAttempts) * 60 * 1000).toLong()
            syncQueue.update(item.copy(
                attempts = newAttempts,
                scheduledAt = System.currentTimeMillis() + backoff
            ))
        }
    }

    companion object {
        private const val MAX_ATTEMPTS = 5

        fun enqueueImmediate(workManager: WorkManager) {
            val request = OneTimeWorkRequestBuilder<SyncWorker>()
                .setConstraints(
                    Constraints.Builder()
                        .setRequiredNetworkType(NetworkType.CONNECTED)
                        .build()
                )
                .build()

            workManager.enqueueUniqueWork(
                "immediate_sync",
                ExistingWorkPolicy.KEEP,
                request
            )
        }

        fun enqueuePeriodic(workManager: WorkManager) {
            val request = PeriodicWorkRequestBuilder<SyncWorker>(
                15, TimeUnit.MINUTES
            )
                .setConstraints(
                    Constraints.Builder()
                        .setRequiredNetworkType(NetworkType.CONNECTED)
                        .setRequiresBatteryNotLow(true)
                        .build()
                )
                .build()

            workManager.enqueueUniquePeriodicWork(
                "periodic_sync",
                ExistingPeriodicWorkPolicy.KEEP,
                request
            )
        }
    }
}
```

### Conflict Resolution
```kotlin
sealed class ConflictResolution {
    object ServerWins : ConflictResolution()
    object ClientWins : ConflictResolution()
    data class Merge(val mergedData: Any) : ConflictResolution()
}

class ConflictResolver {
    fun resolveOrderConflict(
        localOrder: OrderEntity,
        serverOrder: OrderDto
    ): ConflictResolution {
        // For orders: If already approved on server, server wins
        if (serverOrder.status == OrderStatus.APPROVED) {
            return ConflictResolution.ServerWins
        }

        // If local has newer modifications, client wins
        if (localOrder.modifiedAt > serverOrder.updatedAt.toEpochMilli()) {
            return ConflictResolution.ClientWins
        }

        // Default: Server wins
        return ConflictResolution.ServerWins
    }

    fun resolveCustomerConflict(
        localCustomer: CustomerEntity,
        serverCustomer: CustomerDto
    ): ConflictResolution {
        // Master data: Server always wins
        return ConflictResolution.ServerWins
    }
}
```

## Sync Status UI
```kotlin
@Composable
fun SyncStatusIndicator(
    syncState: SyncState,
    onSyncClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .clickable(enabled = syncState != SyncState.Syncing) { onSyncClick() }
            .padding(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        when (syncState) {
            SyncState.Synced -> {
                Icon(Icons.Default.CloudDone, "Synced", tint = Color.Green)
                Text("Synced", color = Color.Green)
            }
            SyncState.Syncing -> {
                CircularProgressIndicator(modifier = Modifier.size(16.dp))
                Text("Syncing...", color = Color.Gray)
            }
            is SyncState.PendingSync -> {
                Icon(Icons.Default.CloudUpload, "Pending", tint = Color.Orange)
                Text("${syncState.pendingCount} pending", color = Color.Orange)
            }
            SyncState.Offline -> {
                Icon(Icons.Default.CloudOff, "Offline", tint = Color.Red)
                Text("Offline", color = Color.Red)
            }
            is SyncState.Error -> {
                Icon(Icons.Default.Error, "Error", tint = Color.Red)
                Text("Sync error", color = Color.Red)
            }
        }
    }
}
```

## Data Freshness Policy

| Data Type | Sync Direction | Freshness | Cache Duration |
|-----------|----------------|-----------|----------------|
| Products | Server → Client | Hourly | 24 hours |
| Customers | Server → Client | Hourly | 24 hours |
| Promotions | Server → Client | Daily | 24 hours |
| Routes | Server → Client | Daily | 24 hours |
| Orders | Client → Server | Immediate | Until synced |
| Visits | Client → Server | Immediate | Until synced |
| Photos | Client → Server | Background | Until synced |
| Locations | Client → Server | Every 5 min | 1 hour |

## References

- [Room Persistence Library](https://developer.android.com/training/data-storage/room)
- [WorkManager for Background Work](https://developer.android.com/topic/libraries/architecture/workmanager)
- [Offline-First Mobile Apps](https://developer.android.com/topic/architecture/data-layer/offline-first)
