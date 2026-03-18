package com.creapolis.solennix.feature.settings.viewmodel

import android.app.Activity
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.android.billingclient.api.ProductDetails
import com.creapolis.solennix.core.network.AuthManager
import com.creapolis.solennix.feature.settings.billing.BillingManager
import com.creapolis.solennix.feature.settings.billing.BillingState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

data class SubscriptionUiState(
    val billingState: BillingState = BillingState.NotReady,
    val proProducts: List<ProductDetails> = emptyList(),
    val premiumProducts: List<ProductDetails> = emptyList(),
    val currentPlanName: String = "Básico",
    val hasActiveSubscription: Boolean = false,
    val isLoading: Boolean = false
)

@HiltViewModel
class SubscriptionViewModel @Inject constructor(
    private val billingManager: BillingManager,
    private val authManager: AuthManager
) : ViewModel() {

    val uiState: StateFlow<SubscriptionUiState> = combine(
        billingManager.billingState,
        billingManager.products,
        billingManager.currentSubscription,
        authManager.currentUser
    ) { billingState, products, subscription, user ->
        val proProducts = products.filter {
            it.productId.contains("pro")
        }
        val premiumProducts = products.filter {
            it.productId.contains("premium")
        }

        val hasSubscription = subscription != null
        val currentPlan = when {
            subscription?.products?.any { it.contains("premium") } == true -> "Premium"
            subscription?.products?.any { it.contains("pro") } == true -> "Pro"
            else -> user?.plan?.name?.replaceFirstChar { it.uppercase() } ?: "Básico"
        }

        SubscriptionUiState(
            billingState = billingState,
            proProducts = proProducts,
            premiumProducts = premiumProducts,
            currentPlanName = currentPlan,
            hasActiveSubscription = hasSubscription
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = SubscriptionUiState()
    )

    fun initBilling() {
        billingManager.initialize()
    }

    fun launchPurchase(activity: Activity, productDetails: ProductDetails) {
        billingManager.launchPurchaseFlow(activity, productDetails)
    }

    fun getFormattedPrice(productDetails: ProductDetails): String {
        return billingManager.getFormattedPrice(productDetails)
    }

    fun hasActiveSubscription(productId: String): Boolean {
        return billingManager.hasActiveSubscription(productId)
    }

    override fun onCleared() {
        super.onCleared()
        billingManager.cleanup()
    }
}
