package com.creapolis.solennix.core.data.di

import com.creapolis.solennix.core.data.repository.*
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
interface DataModule {
    @Binds
    fun bindsClientRepository(
        repository: OfflineFirstClientRepository
    ): ClientRepository

    @Binds
    fun bindsEventRepository(
        repository: OfflineFirstEventRepository
    ): EventRepository

    @Binds
    fun bindsProductRepository(
        repository: OfflineFirstProductRepository
    ): ProductRepository

    @Binds
    fun bindsInventoryRepository(
        repository: OfflineFirstInventoryRepository
    ): InventoryRepository
}
