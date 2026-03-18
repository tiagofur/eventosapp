package com.creapolis.solennix.sync

import android.content.Context
import androidx.hilt.work.HiltWorker
import androidx.work.*
import com.creapolis.solennix.core.data.repository.ClientRepository
import com.creapolis.solennix.core.data.repository.EventRepository
import com.creapolis.solennix.core.data.repository.InventoryRepository
import com.creapolis.solennix.core.data.repository.ProductRepository
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject
import java.util.concurrent.TimeUnit

/**
 * Background worker that periodically syncs data with the server.
 */
@HiltWorker
class SyncWorker @AssistedInject constructor(
    @Assisted context: Context,
    @Assisted workerParams: WorkerParameters,
    private val eventRepository: EventRepository,
    private val clientRepository: ClientRepository,
    private val productRepository: ProductRepository,
    private val inventoryRepository: InventoryRepository
) : CoroutineWorker(context, workerParams) {

    override suspend fun doWork(): Result {
        return try {
            // Sync all data in sequence
            syncEvents()
            syncClients()
            syncProducts()
            syncInventory()

            Result.success()
        } catch (e: Exception) {
            if (runAttemptCount < MAX_RETRY_COUNT) {
                Result.retry()
            } else {
                Result.failure()
            }
        }
    }

    private suspend fun syncEvents() {
        try {
            eventRepository.syncEvents()
        } catch (e: Exception) {
            // Log but don't fail the entire sync
        }
    }

    private suspend fun syncClients() {
        try {
            clientRepository.syncClients()
        } catch (e: Exception) {
            // Log but don't fail the entire sync
        }
    }

    private suspend fun syncProducts() {
        try {
            productRepository.syncProducts()
        } catch (e: Exception) {
            // Log but don't fail the entire sync
        }
    }

    private suspend fun syncInventory() {
        try {
            inventoryRepository.syncInventory()
        } catch (e: Exception) {
            // Log but don't fail the entire sync
        }
    }

    companion object {
        private const val MAX_RETRY_COUNT = 3
        const val SYNC_WORK_NAME = "solennix_sync_work"

        /**
         * Schedule periodic sync work.
         */
        fun schedulePeriodicSync(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .setRequiresBatteryNotLow(true)
                .build()

            val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(
                repeatInterval = 15,
                repeatIntervalTimeUnit = TimeUnit.MINUTES
            )
                .setConstraints(constraints)
                .setBackoffCriteria(
                    BackoffPolicy.EXPONENTIAL,
                    WorkRequest.MIN_BACKOFF_MILLIS,
                    TimeUnit.MILLISECONDS
                )
                .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                SYNC_WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                syncRequest
            )
        }

        /**
         * Request an immediate one-time sync.
         */
        fun requestImmediateSync(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()

            val syncRequest = OneTimeWorkRequestBuilder<SyncWorker>()
                .setConstraints(constraints)
                .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                .build()

            WorkManager.getInstance(context).enqueue(syncRequest)
        }

        /**
         * Cancel all sync work.
         */
        fun cancelSync(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(SYNC_WORK_NAME)
        }
    }
}
