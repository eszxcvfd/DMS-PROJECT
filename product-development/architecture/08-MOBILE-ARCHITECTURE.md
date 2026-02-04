# DILIGO DMS - Mobile Architecture

## Android Application Architecture

**Version:** 2.0
**Last Updated:** 2026-02-04
**PRD Reference:** PRD-v2.md (v2.3)
**Platform:** Android 8.0+ (API 26+)

---

## 1. Overview

This document describes the architecture of the DILIGO DMS Android application, designed for field sales representatives (NVBH) to perform daily operations including customer visits, order creation, and photo capture.

### Technology Stack

| Component | Technology |
|-----------|------------|
| **Language** | Kotlin 1.9+ |
| **UI Framework** | Jetpack Compose |
| **Architecture** | MVVM + Clean Architecture |
| **Dependency Injection** | Hilt (Dagger) |
| **Local Database** | Room (SQLite) |
| **Networking** | Retrofit + OkHttp |
| **Async** | Kotlin Coroutines + Flow |
| **GPS** | Google Play Location Services |
| **Camera** | CameraX |
| **Background** | WorkManager |
| **Min SDK** | 26 (Android 8.0) |
| **Target SDK** | 34 (Android 14) |

---

## 2. Project Structure

```
app/
├── src/main/
│   ├── java/com/diligo/dms/
│   │   ├── DiligoDmsApp.kt              # Application class
│   │   │
│   │   ├── di/                          # Dependency Injection
│   │   │   ├── AppModule.kt
│   │   │   ├── NetworkModule.kt
│   │   │   ├── DatabaseModule.kt
│   │   │   └── RepositoryModule.kt
│   │   │
│   │   ├── domain/                      # Domain Layer
│   │   │   ├── model/                   # Domain models
│   │   │   │   ├── Customer.kt
│   │   │   │   ├── Product.kt
│   │   │   │   ├── Order.kt
│   │   │   │   ├── Visit.kt
│   │   │   │   └── ...
│   │   │   ├── repository/              # Repository interfaces
│   │   │   │   ├── CustomerRepository.kt
│   │   │   │   ├── OrderRepository.kt
│   │   │   │   └── ...
│   │   │   └── usecase/                 # Use cases
│   │   │       ├── auth/
│   │   │       ├── customer/
│   │   │       ├── order/
│   │   │       ├── visit/
│   │   │       └── sync/
│   │   │
│   │   ├── data/                        # Data Layer
│   │   │   ├── local/                   # Local data sources
│   │   │   │   ├── database/
│   │   │   │   │   ├── AppDatabase.kt
│   │   │   │   │   ├── dao/
│   │   │   │   │   └── entity/
│   │   │   │   └── preferences/
│   │   │   │       └── SecurePreferences.kt
│   │   │   ├── remote/                  # Remote data sources
│   │   │   │   ├── api/
│   │   │   │   │   ├── AuthApi.kt
│   │   │   │   │   ├── CustomerApi.kt
│   │   │   │   │   └── ...
│   │   │   │   ├── dto/
│   │   │   │   └── interceptor/
│   │   │   │       ├── AuthInterceptor.kt
│   │   │   │       └── LoggingInterceptor.kt
│   │   │   └── repository/              # Repository implementations
│   │   │       ├── CustomerRepositoryImpl.kt
│   │   │       └── ...
│   │   │
│   │   ├── presentation/                # Presentation Layer
│   │   │   ├── navigation/
│   │   │   │   └── NavGraph.kt
│   │   │   ├── theme/
│   │   │   │   ├── Color.kt
│   │   │   │   ├── Theme.kt
│   │   │   │   └── Type.kt
│   │   │   ├── components/              # Reusable UI components
│   │   │   │   ├── TopBar.kt
│   │   │   │   ├── BottomNavBar.kt
│   │   │   │   ├── LoadingIndicator.kt
│   │   │   │   └── ...
│   │   │   └── screens/                 # Feature screens
│   │   │       ├── login/
│   │   │       ├── home/
│   │   │       ├── route/
│   │   │       ├── customer/
│   │   │       ├── visit/
│   │   │       ├── order/
│   │   │       └── settings/
│   │   │
│   │   ├── core/                        # Core utilities
│   │   │   ├── location/
│   │   │   │   └── LocationManager.kt
│   │   │   ├── camera/
│   │   │   │   └── CameraManager.kt
│   │   │   ├── sync/
│   │   │   │   ├── SyncWorker.kt
│   │   │   │   └── SyncManager.kt
│   │   │   ├── network/
│   │   │   │   └── NetworkMonitor.kt
│   │   │   └── util/
│   │   │       ├── Extensions.kt
│   │   │       └── DateUtils.kt
│   │   │
│   │   └── service/                     # Android Services
│   │       ├── LocationTrackingService.kt
│   │       └── FirebaseMessagingService.kt
│   │
│   └── res/
│       ├── values/
│       ├── drawable/
│       └── ...
│
├── build.gradle.kts
└── proguard-rules.pro
```

---

## 3. Architecture Layers

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              CLEAN ARCHITECTURE LAYERS                                      │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                           PRESENTATION LAYER                                         │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐        │   │
│  │   │    Screens      │◄──────►│   ViewModels    │◄──────►│    UI State     │        │   │
│  │   │   (Compose)     │        │                 │        │                 │        │   │
│  │   └─────────────────┘        └────────┬────────┘        └─────────────────┘        │   │
│  │                                       │                                             │   │
│  │                                       │ Invoke                                      │   │
│  │                                       ▼                                             │   │
│  └───────────────────────────────────────────────────────────────────────────────────────┘ │
│                                          │                                                  │
│  ┌───────────────────────────────────────┼───────────────────────────────────────────────┐ │
│  │                           DOMAIN LAYER│                                               │ │
│  │                                       │                                               │ │
│  │   ┌─────────────────┐        ┌────────▼────────┐        ┌─────────────────┐          │ │
│  │   │  Domain Models  │◄───────│    Use Cases    │───────►│  Repository     │          │ │
│  │   │                 │        │                 │        │  Interfaces     │          │ │
│  │   └─────────────────┘        └─────────────────┘        └────────┬────────┘          │ │
│  │                                                                  │                    │ │
│  └──────────────────────────────────────────────────────────────────┼────────────────────┘ │
│                                                                     │                      │
│  ┌──────────────────────────────────────────────────────────────────┼────────────────────┐ │
│  │                           DATA LAYER                             │                    │ │
│  │                                                                  │                    │ │
│  │                              ┌───────────────────────────────────▼───────────────┐   │ │
│  │                              │           Repository Implementations              │   │ │
│  │                              │     (Coordinates Local & Remote Data Sources)     │   │ │
│  │                              └───────────────────────┬───────────────────────────┘   │ │
│  │                                          ┌───────────┴───────────┐                   │ │
│  │                                          │                       │                   │ │
│  │   ┌─────────────────────────────────────┐│┌─────────────────────────────────────┐   │ │
│  │   │          LOCAL DATA SOURCE          │││         REMOTE DATA SOURCE          │   │ │
│  │   │                                     │││                                     │   │ │
│  │   │   ┌─────────────┐ ┌─────────────┐  │││  ┌─────────────┐ ┌─────────────┐   │   │ │
│  │   │   │    Room     │ │  Encrypted  │  │││  │  Retrofit   │ │   OkHttp    │   │   │ │
│  │   │   │   Database  │ │   Prefs     │  │││  │    APIs     │ │   Client    │   │   │ │
│  │   │   └─────────────┘ └─────────────┘  │││  └─────────────┘ └─────────────┘   │   │ │
│  │   │                                     │││                                     │   │ │
│  │   └─────────────────────────────────────┘│└─────────────────────────────────────┘   │ │
│  │                                          │                                           │ │
│  └──────────────────────────────────────────┴───────────────────────────────────────────┘ │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Key Components

### 4.1 Dependency Injection (Hilt)

```kotlin
// AppModule.kt
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideSecurePreferences(
        @ApplicationContext context: Context
    ): SecurePreferences {
        return SecurePreferences(context)
    }
}

// NetworkModule.kt
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideOkHttpClient(
        authInterceptor: AuthInterceptor,
        loggingInterceptor: HttpLoggingInterceptor
    ): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .addInterceptor(loggingInterceptor)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .certificatePinner(
                CertificatePinner.Builder()
                    .add("diligo-dms-api.azurewebsites.net", "sha256/...")
                    .build()
            )
            .build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl(BuildConfig.API_BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }
}

// DatabaseModule.kt
@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideDatabase(
        @ApplicationContext context: Context
    ): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "diligo_dms.db"
        )
            .addMigrations(MIGRATION_1_2)
            .build()
    }

    @Provides
    fun provideCustomerDao(database: AppDatabase): CustomerDao {
        return database.customerDao()
    }
}
```

### 4.2 Room Database

```kotlin
// AppDatabase.kt
@Database(
    entities = [
        CustomerEntity::class,
        ProductEntity::class,
        OrderEntity::class,
        OrderDetailEntity::class,
        VisitEntity::class,
        VisitPhotoEntity::class,
        SyncMetadataEntity::class
    ],
    version = 1,
    exportSchema = true
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun customerDao(): CustomerDao
    abstract fun productDao(): ProductDao
    abstract fun orderDao(): OrderDao
    abstract fun visitDao(): VisitDao
    abstract fun syncMetadataDao(): SyncMetadataDao
}

// CustomerEntity.kt
@Entity(tableName = "customers")
data class CustomerEntity(
    @PrimaryKey
    val customerId: String,
    val customerCode: String,
    val name: String,
    val phone: String,
    val contactPerson: String?,
    val customerGroup: String,
    val customerType: String,
    val channel: String,
    val latitude: Double,
    val longitude: Double,
    val address: String,
    val creditLimit: Double?,
    val currentBalance: Double,
    val imageUrl: String?,
    val status: String,
    val routeId: String?,
    val syncStatus: String = SyncStatus.SYNCED.name,
    val lastModified: Long = System.currentTimeMillis()
)

// CustomerDao.kt
@Dao
interface CustomerDao {

    @Query("SELECT * FROM customers WHERE routeId = :routeId ORDER BY name")
    fun getCustomersByRoute(routeId: String): Flow<List<CustomerEntity>>

    @Query("SELECT * FROM customers WHERE customerId = :id")
    suspend fun getById(id: String): CustomerEntity?

    @Query("SELECT * FROM customers WHERE syncStatus = :status")
    suspend fun getPendingSync(status: String = SyncStatus.PENDING.name): List<CustomerEntity>

    @Upsert
    suspend fun upsert(customer: CustomerEntity)

    @Upsert
    suspend fun upsertAll(customers: List<CustomerEntity>)

    @Query("UPDATE customers SET syncStatus = :status WHERE customerId IN (:ids)")
    suspend fun updateSyncStatus(ids: List<String>, status: String)
}
```

### 4.3 Repository Pattern

```kotlin
// CustomerRepository.kt (Domain layer - interface)
interface CustomerRepository {
    fun getCustomersByRoute(routeId: String): Flow<List<Customer>>
    suspend fun getCustomerById(id: String): Customer?
    suspend fun updateCustomer(customer: Customer): Result<Customer>
    suspend fun syncCustomers(): Result<Unit>
}

// CustomerRepositoryImpl.kt (Data layer - implementation)
@Singleton
class CustomerRepositoryImpl @Inject constructor(
    private val customerDao: CustomerDao,
    private val customerApi: CustomerApi,
    private val networkMonitor: NetworkMonitor
) : CustomerRepository {

    override fun getCustomersByRoute(routeId: String): Flow<List<Customer>> {
        return customerDao.getCustomersByRoute(routeId)
            .map { entities -> entities.map { it.toDomain() } }
    }

    override suspend fun getCustomerById(id: String): Customer? {
        return customerDao.getById(id)?.toDomain()
    }

    override suspend fun updateCustomer(customer: Customer): Result<Customer> {
        return try {
            // Save locally first
            customerDao.upsert(customer.toEntity().copy(
                syncStatus = SyncStatus.PENDING.name
            ))

            // Try to sync if online
            if (networkMonitor.isOnline()) {
                val response = customerApi.updateCustomer(customer.customerId, customer.toDto())
                customerDao.upsert(response.toEntity().copy(
                    syncStatus = SyncStatus.SYNCED.name
                ))
                Result.success(response.toDomain())
            } else {
                Result.success(customer)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

### 4.4 Use Cases

```kotlin
// GetTodayRouteUseCase.kt
class GetTodayRouteUseCase @Inject constructor(
    private val routeRepository: RouteRepository,
    private val customerRepository: CustomerRepository
) {
    suspend operator fun invoke(): Result<TodayRoute> {
        return try {
            val route = routeRepository.getTodayRoute()
                ?: return Result.failure(NoRouteAssignedException())

            val customers = customerRepository.getCustomersByRoute(route.routeId).first()

            Result.success(TodayRoute(
                route = route,
                customers = customers,
                summary = RouteSummary(
                    totalCustomers = customers.size,
                    visitedToday = 0, // Calculate from visits
                    ordersToday = 0
                )
            ))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

// CheckInUseCase.kt
class CheckInUseCase @Inject constructor(
    private val visitRepository: VisitRepository,
    private val locationManager: LocationManager
) {
    suspend operator fun invoke(
        customerId: String,
        visitType: VisitType
    ): Result<Visit> {
        return try {
            // Get current location
            val location = locationManager.getCurrentLocation()
                ?: return Result.failure(LocationNotAvailableException())

            // Create visit
            val visit = Visit(
                visitId = UUID.randomUUID().toString(),
                customerId = customerId,
                checkInTime = Instant.now(),
                checkInLatitude = location.latitude,
                checkInLongitude = location.longitude,
                visitType = visitType,
                syncStatus = SyncStatus.PENDING
            )

            visitRepository.createVisit(visit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

### 4.5 ViewModel

```kotlin
// VisitViewModel.kt
@HiltViewModel
class VisitViewModel @Inject constructor(
    private val checkInUseCase: CheckInUseCase,
    private val checkOutUseCase: CheckOutUseCase,
    private val uploadPhotoUseCase: UploadPhotoUseCase,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val customerId: String = savedStateHandle.get<String>("customerId")!!

    private val _uiState = MutableStateFlow(VisitUiState())
    val uiState: StateFlow<VisitUiState> = _uiState.asStateFlow()

    fun checkIn() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }

            checkInUseCase(customerId, VisitType.InRoute)
                .onSuccess { visit ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            currentVisit = visit,
                            isCheckedIn = true
                        )
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            error = error.message
                        )
                    }
                }
        }
    }

    fun capturePhoto(imageUri: Uri, albumType: AlbumType) {
        viewModelScope.launch {
            val visit = _uiState.value.currentVisit ?: return@launch

            uploadPhotoUseCase(visit.visitId, imageUri, albumType)
                .onSuccess { photo ->
                    _uiState.update {
                        it.copy(photos = it.photos + photo)
                    }
                }
        }
    }

    fun checkOut(result: VisitResult, notes: String?) {
        viewModelScope.launch {
            val visit = _uiState.value.currentVisit ?: return@launch
            _uiState.update { it.copy(isLoading = true) }

            checkOutUseCase(visit.visitId, result, notes)
                .onSuccess {
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isCheckedOut = true
                        )
                    }
                }
        }
    }
}

data class VisitUiState(
    val isLoading: Boolean = false,
    val currentVisit: Visit? = null,
    val isCheckedIn: Boolean = false,
    val isCheckedOut: Boolean = false,
    val photos: List<VisitPhoto> = emptyList(),
    val error: String? = null
)
```

### 4.6 Compose UI

```kotlin
// VisitScreen.kt
@Composable
fun VisitScreen(
    customerId: String,
    onNavigateBack: () -> Unit,
    onNavigateToOrder: (String) -> Unit,
    viewModel: VisitViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val context = LocalContext.current

    var showCameraDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Viếng thăm") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
        ) {
            // Customer info card
            CustomerInfoCard(customer = uiState.customer)

            Spacer(modifier = Modifier.height(16.dp))

            // Check-in/Check-out buttons
            if (!uiState.isCheckedIn) {
                Button(
                    onClick = { viewModel.checkIn() },
                    modifier = Modifier.fillMaxWidth(),
                    enabled = !uiState.isLoading
                ) {
                    if (uiState.isLoading) {
                        CircularProgressIndicator(modifier = Modifier.size(24.dp))
                    } else {
                        Text("Check-in")
                    }
                }
            } else if (!uiState.isCheckedOut) {
                // Photo capture section
                PhotoGallery(
                    photos = uiState.photos,
                    onAddPhoto = { showCameraDialog = true }
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Create order button
                OutlinedButton(
                    onClick = { onNavigateToOrder(customerId) },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Tạo đơn hàng")
                }

                Spacer(modifier = Modifier.weight(1f))

                // Check-out button
                Button(
                    onClick = { viewModel.checkOut(VisitResult.HasOrder, null) },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Check-out")
                }
            }
        }
    }

    // Camera dialog
    if (showCameraDialog) {
        CameraDialog(
            onPhotoTaken = { uri, albumType ->
                viewModel.capturePhoto(uri, albumType)
                showCameraDialog = false
            },
            onDismiss = { showCameraDialog = false }
        )
    }
}
```

---

## 5. Background Services

### 5.1 Sync Worker

```kotlin
@HiltWorker
class SyncWorker @AssistedInject constructor(
    @Assisted context: Context,
    @Assisted params: WorkerParameters,
    private val syncManager: SyncManager
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        return try {
            // Download updates from server
            syncManager.downloadDelta()

            // Upload pending changes
            syncManager.uploadPending()

            Result.success()
        } catch (e: Exception) {
            if (runAttemptCount < 3) {
                Result.retry()
            } else {
                Result.failure()
            }
        }
    }

    companion object {
        fun schedule(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .setRequiresBatteryNotLow(true)
                .build()

            val request = PeriodicWorkRequestBuilder<SyncWorker>(
                15, TimeUnit.MINUTES
            )
                .setConstraints(constraints)
                .setBackoffCriteria(
                    BackoffPolicy.EXPONENTIAL,
                    WorkRequest.MIN_BACKOFF_MILLIS,
                    TimeUnit.MILLISECONDS
                )
                .build()

            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(
                    "sync",
                    ExistingPeriodicWorkPolicy.KEEP,
                    request
                )
        }
    }
}
```

### 5.2 Location Tracking Service

```kotlin
@AndroidEntryPoint
class LocationTrackingService : Service() {

    @Inject lateinit var locationRepository: LocationRepository

    private val fusedLocationClient by lazy {
        LocationServices.getFusedLocationProviderClient(this)
    }

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            result.lastLocation?.let { location ->
                CoroutineScope(Dispatchers.IO).launch {
                    locationRepository.saveLocation(
                        LocationRecord(
                            latitude = location.latitude,
                            longitude = location.longitude,
                            accuracy = location.accuracy,
                            timestamp = Instant.now()
                        )
                    )
                }
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, createNotification())
        startLocationUpdates()
        return START_STICKY
    }

    private fun startLocationUpdates() {
        val request = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            5 * 60 * 1000 // 5 minutes
        ).build()

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
            == PackageManager.PERMISSION_GRANTED
        ) {
            fusedLocationClient.requestLocationUpdates(
                request,
                locationCallback,
                Looper.getMainLooper()
            )
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        private const val NOTIFICATION_ID = 1001
    }
}
```

---

## 6. Security

### 6.1 Token Storage

```kotlin
class SecurePreferences @Inject constructor(
    @ApplicationContext context: Context
) {
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val prefs = EncryptedSharedPreferences.create(
        context,
        "secure_prefs",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    var accessToken: String?
        get() = prefs.getString(KEY_ACCESS_TOKEN, null)
        set(value) = prefs.edit { putString(KEY_ACCESS_TOKEN, value) }

    var refreshToken: String?
        get() = prefs.getString(KEY_REFRESH_TOKEN, null)
        set(value) = prefs.edit { putString(KEY_REFRESH_TOKEN, value) }

    fun clear() {
        prefs.edit { clear() }
    }

    companion object {
        private const val KEY_ACCESS_TOKEN = "access_token"
        private const val KEY_REFRESH_TOKEN = "refresh_token"
    }
}
```

### 6.2 Certificate Pinning

```kotlin
// In NetworkModule
val certificatePinner = CertificatePinner.Builder()
    .add("diligo-dms-api.azurewebsites.net", "sha256/XXXXX...")
    .build()

val client = OkHttpClient.Builder()
    .certificatePinner(certificatePinner)
    .build()
```

---

## 7. Build Configuration

```kotlin
// build.gradle.kts (app)
android {
    namespace = "com.diligo.dms"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.diligo.dms"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            buildConfigField("String", "API_BASE_URL", "\"https://diligo-dms-api.azurewebsites.net/api/\"")
        }
        debug {
            buildConfigField("String", "API_BASE_URL", "\"http://10.0.2.2:5000/api/\"")
        }
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }
}

dependencies {
    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.01.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")

    // Hilt
    implementation("com.google.dagger:hilt-android:2.50")
    kapt("com.google.dagger:hilt-compiler:2.50")

    // Room
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")

    // Retrofit
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")

    // WorkManager
    implementation("androidx.work:work-runtime-ktx:2.9.0")
    implementation("androidx.hilt:hilt-work:1.1.0")

    // Location
    implementation("com.google.android.gms:play-services-location:21.1.0")

    // CameraX
    implementation("androidx.camera:camera-camera2:1.3.1")
    implementation("androidx.camera:camera-lifecycle:1.3.1")
    implementation("androidx.camera:camera-view:1.3.1")

    // Security
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
}
```

---

## 8. GSBH Mobile Features [v2.0]

> Các tính năng dành riêng cho Giám sát bán hàng (GSBH/SS) trên mobile

### 8.1 Project Structure Addition

```text
app/src/main/java/com/diligo/dms/
├── presentation/screens/
│   ├── gsbh/                          # GSBH-specific screens
│   │   ├── npp/                       # NPP Management (Mở mới NPP)
│   │   │   ├── NPPOnboardingScreen.kt
│   │   │   ├── NPPOnboardingViewModel.kt
│   │   │   └── components/
│   │   │       ├── NPPInfoForm.kt
│   │   │       └── NPPPhotoCapture.kt
│   │   ├── route/                     # Route Management
│   │   │   ├── RouteManagementScreen.kt
│   │   │   ├── RouteManagementViewModel.kt
│   │   │   ├── RouteEditorScreen.kt
│   │   │   └── components/
│   │   │       ├── RouteList.kt
│   │   │       ├── CustomerSelector.kt
│   │   │       └── ExcelImportDialog.kt
│   │   ├── kpi/                       # KPI Assignment
│   │   │   ├── KPIAssignmentScreen.kt
│   │   │   ├── KPIAssignmentViewModel.kt
│   │   │   └── components/
│   │   │       ├── EmployeeSelector.kt
│   │   │       ├── KPITargetForm.kt
│   │   │       └── ProductTargetList.kt
│   │   └── monitor/                   # Employee Monitoring
│   │       ├── EmployeeMonitorScreen.kt
│   │       ├── EmployeeMonitorViewModel.kt
│   │       └── components/
│   │           ├── EmployeeLocationMap.kt
│   │           ├── VisitTimeline.kt
│   │           └── PhotoGallery.kt
│   └── vansales/                      # Van-sales specific
│       ├── VanSalesOrderScreen.kt
│       ├── VanSalesViewModel.kt
│       └── components/
│           ├── VanStockList.kt
│           └── PaymentForm.kt
```

### 8.2 NPP Onboarding Screen (Mở mới NPP)

```kotlin
// NPPOnboardingViewModel.kt
@HiltViewModel
class NPPOnboardingViewModel @Inject constructor(
    private val createNPPUseCase: CreateNPPUseCase,
    private val uploadPhotoUseCase: UploadNPPPhotoUseCase,
    private val locationManager: LocationManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(NPPOnboardingUiState())
    val uiState: StateFlow<NPPOnboardingUiState> = _uiState.asStateFlow()

    fun updateNPPInfo(info: NPPInfo) {
        _uiState.update { it.copy(nppInfo = info) }
    }

    fun captureLocation() {
        viewModelScope.launch {
            locationManager.getCurrentLocation()?.let { location ->
                _uiState.update {
                    it.copy(
                        nppInfo = it.nppInfo.copy(
                            latitude = location.latitude,
                            longitude = location.longitude
                        )
                    )
                }
            }
        }
    }

    fun addPhoto(uri: Uri, photoType: NPPPhotoType) {
        _uiState.update {
            it.copy(photos = it.photos + PendingPhoto(uri, photoType))
        }
    }

    fun submitNPP() {
        viewModelScope.launch {
            _uiState.update { it.copy(isSubmitting = true) }

            createNPPUseCase(uiState.value.nppInfo)
                .onSuccess { npp ->
                    uiState.value.photos.forEach { photo ->
                        uploadPhotoUseCase(npp.distributorId, photo.uri, photo.type)
                    }
                    _uiState.update {
                        it.copy(isSubmitting = false, isSuccess = true)
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(isSubmitting = false, error = error.message)
                    }
                }
        }
    }
}

data class NPPOnboardingUiState(
    val nppInfo: NPPInfo = NPPInfo(),
    val photos: List<PendingPhoto> = emptyList(),
    val isSubmitting: Boolean = false,
    val isSuccess: Boolean = false,
    val error: String? = null
)

enum class NPPPhotoType {
    StoreFront, OwnerPhoto, MeetingPhoto, BusinessLicense, TaxCertificate, Contract
}
```

### 8.3 Route Management Screen (Quản lý tuyến)

```kotlin
// RouteManagementViewModel.kt
@HiltViewModel
class RouteManagementViewModel @Inject constructor(
    private val routeRepository: RouteRepository,
    private val importRouteUseCase: ImportRouteFromExcelUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(RouteManagementUiState())
    val uiState: StateFlow<RouteManagementUiState> = _uiState.asStateFlow()

    init { loadRoutes() }

    private fun loadRoutes() {
        viewModelScope.launch {
            routeRepository.getAllRoutes()
                .collect { routes ->
                    _uiState.update { it.copy(routes = routes, isLoading = false) }
                }
        }
    }

    fun createRoute(route: RouteInfo) {
        viewModelScope.launch {
            routeRepository.createRoute(route)
                .onSuccess { loadRoutes() }
        }
    }

    fun addCustomersToRoute(routeId: String, customers: List<CustomerAssignment>) {
        viewModelScope.launch {
            routeRepository.addCustomers(routeId, customers)
        }
    }

    fun importFromExcel(uri: Uri) {
        viewModelScope.launch {
            _uiState.update { it.copy(isImporting = true) }
            importRouteUseCase(uri)
                .onSuccess { result ->
                    _uiState.update { it.copy(isImporting = false, importResult = result) }
                    loadRoutes()
                }
        }
    }
}

data class CustomerAssignment(val customerId: String, val visitOrder: Int)
```

### 8.4 KPI Assignment Screen (Chia KPI)

```kotlin
// KPIAssignmentViewModel.kt
@HiltViewModel
class KPIAssignmentViewModel @Inject constructor(
    private val kpiRepository: KPIRepository,
    private val userRepository: UserRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(KPIAssignmentUiState())
    val uiState: StateFlow<KPIAssignmentUiState> = _uiState.asStateFlow()

    init { loadEmployees() }

    private fun loadEmployees() {
        viewModelScope.launch {
            userRepository.getSubordinates()
                .collect { employees ->
                    _uiState.update { it.copy(employees = employees, isLoading = false) }
                }
        }
    }

    fun selectEmployee(userId: String) {
        viewModelScope.launch {
            val existing = kpiRepository.getKPITarget(userId, uiState.value.targetMonth)
            _uiState.update { it.copy(selectedUserId = userId, kpiTarget = existing ?: KPITarget()) }
        }
    }

    fun updateKPITarget(target: KPITarget) {
        _uiState.update { it.copy(kpiTarget = target) }
    }

    fun addProductTarget(productId: String, quantityTarget: Int, revenueTarget: Long?) {
        _uiState.update {
            it.copy(productTargets = it.productTargets + ProductTarget(productId, quantityTarget, revenueTarget))
        }
    }

    fun saveKPI() {
        viewModelScope.launch {
            val userId = uiState.value.selectedUserId ?: return@launch
            _uiState.update { it.copy(isSaving = true) }

            kpiRepository.assignKPI(userId, uiState.value.targetMonth, uiState.value.kpiTarget, uiState.value.productTargets)
                .onSuccess { _uiState.update { it.copy(isSaving = false, saveSuccess = true) } }
                .onFailure { error -> _uiState.update { it.copy(isSaving = false, error = error.message) } }
        }
    }
}

data class KPITarget(
    val visitTarget: Int? = null,
    val newCustomerTarget: Int? = null,
    val orderTarget: Int? = null,
    val revenueTarget: Long? = null,
    val netRevenueTarget: Long? = null,
    val volumeTarget: Int? = null,
    val skuTarget: Int? = null,
    val workingHoursTarget: Float? = null
)
```

### 8.5 Van-sales Order Flow

```kotlin
// VanSalesViewModel.kt
@HiltViewModel
class VanSalesViewModel @Inject constructor(
    private val orderRepository: OrderRepository,
    private val stockRepository: VanStockRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val customerId: String = savedStateHandle.get<String>("customerId")!!
    private val _uiState = MutableStateFlow(VanSalesUiState())
    val uiState: StateFlow<VanSalesUiState> = _uiState.asStateFlow()

    init { loadVanStock() }

    private fun loadVanStock() {
        viewModelScope.launch {
            stockRepository.getMyVanStock()
                .collect { stock ->
                    _uiState.update { it.copy(vanStock = stock, warehouseId = stock.warehouseId, isLoading = false) }
                }
        }
    }

    fun addItem(productId: String, quantity: Int) {
        val stock = uiState.value.vanStock.products.find { it.productId == productId }
        if (stock == null || stock.availableQuantity < quantity) {
            _uiState.update { it.copy(error = "Không đủ hàng trong kho xe") }
            return
        }
        _uiState.update {
            val newItems = it.orderItems + OrderItem(productId, stock.productName, quantity, stock.sellingPrice)
            it.copy(orderItems = newItems)
        }
    }

    fun updatePayment(method: PaymentMethod, amountPaid: Long) {
        _uiState.update { it.copy(paymentMethod = method, amountPaid = amountPaid) }
    }

    fun submitOrder() {
        viewModelScope.launch {
            _uiState.update { it.copy(isSubmitting = true) }

            val order = VanSalesOrder(
                customerId = customerId,
                orderType = OrderType.VanSales,
                warehouseId = uiState.value.warehouseId,
                items = uiState.value.orderItems,
                paymentMethod = uiState.value.paymentMethod,
                amountPaid = uiState.value.amountPaid
            )

            orderRepository.createVanSalesOrder(order)
                .onSuccess { createdOrder ->
                    stockRepository.deductStock(uiState.value.warehouseId, uiState.value.orderItems)
                    _uiState.update { it.copy(isSubmitting = false, orderSuccess = true, createdOrder = createdOrder) }
                }
                .onFailure { error ->
                    _uiState.update { it.copy(isSubmitting = false, error = error.message) }
                }
        }
    }
}

data class VanSalesUiState(
    val vanStock: VanStock = VanStock(),
    val warehouseId: String = "",
    val orderItems: List<OrderItem> = emptyList(),
    val paymentMethod: PaymentMethod = PaymentMethod.Cash,
    val amountPaid: Long = 0,
    val isLoading: Boolean = true,
    val isSubmitting: Boolean = false,
    val orderSuccess: Boolean = false,
    val createdOrder: Order? = null,
    val error: String? = null
) {
    val totalAmount: Long get() = orderItems.sumOf { it.quantity * it.unitPrice }
    val remainingBalance: Long get() = totalAmount - amountPaid
}

enum class PaymentMethod { Cash, Credit, Transfer }
```

---

## 9. Related Documents

- [02-CONTAINER-ARCHITECTURE.md](02-CONTAINER-ARCHITECTURE.md) - System overview
- [05-API-DESIGN.md](05-API-DESIGN.md) - API specifications
- [adr/ADR-001-android-only.md](adr/ADR-001-android-only.md) - Platform decision
- [adr/ADR-006-offline-first-mobile.md](adr/ADR-006-offline-first-mobile.md) - Offline architecture
