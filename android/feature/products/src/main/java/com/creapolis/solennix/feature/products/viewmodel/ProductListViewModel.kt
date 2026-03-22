package com.creapolis.solennix.feature.products.viewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.plan.LimitCheckResult
import com.creapolis.solennix.core.data.plan.PlanLimitsManager
import com.creapolis.solennix.core.data.repository.ProductRepository
import com.creapolis.solennix.core.model.Plan
import com.creapolis.solennix.core.model.Product
import com.creapolis.solennix.core.network.AuthManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class ProductListUiState(
    val products: List<Product> = emptyList(),
    val allCategories: List<String> = emptyList(),
    val selectedCategory: String? = null,
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val searchQuery: String = ""
)

@HiltViewModel
class ProductListViewModel @Inject constructor(
    private val productRepository: ProductRepository,
    private val planLimitsManager: PlanLimitsManager,
    private val authManager: AuthManager
) : ViewModel() {

    // Plan limit check
    var limitCheckResult by mutableStateOf<LimitCheckResult?>(null)
        private set
    val isLimitReached: Boolean
        get() = limitCheckResult is LimitCheckResult.LimitReached
    val nearLimitMessage: String?
        get() = (limitCheckResult as? LimitCheckResult.NearLimit)?.let { result ->
            "Te quedan ${result.remaining} productos disponibles en tu plan actual."
        }
    val limitReachedMessage: String?
        get() = (limitCheckResult as? LimitCheckResult.LimitReached)?.message

    private val _searchQuery = MutableStateFlow("")
    private val _selectedCategory = MutableStateFlow<String?>(null)
    private val _isRefreshing = MutableStateFlow(false)

    val uiState: StateFlow<ProductListUiState> = combine(
        productRepository.getProducts(),
        _searchQuery,
        _selectedCategory,
        _isRefreshing
    ) { products, query, category, refreshing ->
        val allCategories = products.map { it.category }.distinct().sorted()
        var filtered = products
        if (query.isNotBlank()) {
            filtered = filtered.filter {
                it.name.contains(query, ignoreCase = true) || it.category.contains(query, ignoreCase = true)
            }
        }
        if (category != null) {
            filtered = filtered.filter { it.category == category }
        }
        ProductListUiState(
            products = filtered,
            allCategories = allCategories,
            selectedCategory = category,
            isRefreshing = refreshing,
            searchQuery = query
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = ProductListUiState(isLoading = true)
    )

    init {
        refresh()
        checkPlanLimits()
    }

    private fun checkPlanLimits() {
        viewModelScope.launch {
            val plan = authManager.currentUser.value?.plan ?: Plan.BASIC
            limitCheckResult = planLimitsManager.canCreateProduct(plan)
        }
    }

    fun onSearchQueryChange(query: String) {
        _searchQuery.value = query
    }

    fun onCategoryFilterChange(category: String?) {
        _selectedCategory.value = category
    }

    fun refresh() {
        viewModelScope.launch {
            _isRefreshing.value = true
            try {
                productRepository.syncProducts()
            } catch (e: Exception) {
                // Non-fatal, data will show from cache
            } finally {
                _isRefreshing.value = false
            }
        }
    }
}
