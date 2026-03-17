package com.creapolis.solennix.core.data.repository

import com.creapolis.solennix.core.database.dao.ProductDao
import com.creapolis.solennix.core.database.entity.asEntity
import com.creapolis.solennix.core.database.entity.asExternalModel
import com.creapolis.solennix.core.model.Product
import com.creapolis.solennix.core.network.ApiService
import com.creapolis.solennix.core.network.Endpoints
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

interface ProductRepository {
    fun getProducts(): Flow<List<Product>>
    suspend fun getProduct(id: String): Product?
    suspend fun syncProducts()
}

@Singleton
class OfflineFirstProductRepository @Inject constructor(
    private val productDao: ProductDao,
    private val apiService: ApiService
) : ProductRepository {

    override fun getProducts(): Flow<List<Product>> =
        productDao.getProducts().map { it.map { entity -> entity.asExternalModel() } }

    override suspend fun getProduct(id: String): Product? =
        productDao.getProduct(id)?.asExternalModel()

    override suspend fun syncProducts() {
        val networkProducts: List<Product> = apiService.get(Endpoints.PRODUCTS)
        productDao.insertProducts(networkProducts.map { it.asEntity() })
    }
}
