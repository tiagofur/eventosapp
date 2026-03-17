package com.creapolis.solennix.core.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.creapolis.solennix.core.database.converter.JsonConverters
import com.creapolis.solennix.core.database.dao.ClientDao
import com.creapolis.solennix.core.database.dao.EventDao
import com.creapolis.solennix.core.database.dao.InventoryDao
import com.creapolis.solennix.core.database.dao.ProductDao
import com.creapolis.solennix.core.database.entity.CachedClient
import com.creapolis.solennix.core.database.entity.CachedEvent
import com.creapolis.solennix.core.database.entity.CachedInventoryItem
import com.creapolis.solennix.core.database.entity.CachedProduct

@Database(
    entities = [
        CachedClient::class,
        CachedEvent::class,
        CachedProduct::class,
        CachedInventoryItem::class
    ],
    version = 1,
    exportSchema = false
)
@TypeConverters(JsonConverters::class)
abstract class SolennixDatabase : RoomDatabase() {
    abstract fun clientDao(): ClientDao
    abstract fun eventDao(): EventDao
    abstract fun productDao(): ProductDao
    abstract fun inventoryDao(): InventoryDao
}
