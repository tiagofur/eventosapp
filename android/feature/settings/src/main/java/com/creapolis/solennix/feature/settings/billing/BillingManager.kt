package com.creapolis.solennix.feature.settings.billing

import android.app.Activity
import android.content.Context
import com.android.billingclient.api.*
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Manages in-app purchases and subscriptions using Google Play Billing.
 */
@Singleton
class BillingManager @Inject constructor(
    @ApplicationContext private val context: Context
) : PurchasesUpdatedListener {

    companion object {
        // Product IDs - these should match the ones defined in Play Console
        const val PRODUCT_PRO_MONTHLY = "solennix_pro_monthly"
        const val PRODUCT_PRO_YEARLY = "solennix_pro_yearly"
        const val PRODUCT_PREMIUM_MONTHLY = "solennix_premium_monthly"
        const val PRODUCT_PREMIUM_YEARLY = "solennix_premium_yearly"

        val ALL_PRODUCTS = listOf(
            PRODUCT_PRO_MONTHLY,
            PRODUCT_PRO_YEARLY,
            PRODUCT_PREMIUM_MONTHLY,
            PRODUCT_PREMIUM_YEARLY
        )
    }

    private var billingClient: BillingClient? = null

    private val _billingState = MutableStateFlow<BillingState>(BillingState.NotReady)
    val billingState: StateFlow<BillingState> = _billingState.asStateFlow()

    private val _products = MutableStateFlow<List<ProductDetails>>(emptyList())
    val products: StateFlow<List<ProductDetails>> = _products.asStateFlow()

    private val _currentSubscription = MutableStateFlow<Purchase?>(null)
    val currentSubscription: StateFlow<Purchase?> = _currentSubscription.asStateFlow()

    /**
     * Initialize the billing client.
     */
    fun initialize() {
        billingClient = BillingClient.newBuilder(context)
            .setListener(this)
            .enablePendingPurchases()
            .build()

        billingClient?.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(result: BillingResult) {
                if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                    _billingState.value = BillingState.Ready
                    queryProducts()
                    queryPurchases()
                } else {
                    _billingState.value = BillingState.Error(
                        "Billing setup failed: ${result.debugMessage}"
                    )
                }
            }

            override fun onBillingServiceDisconnected() {
                _billingState.value = BillingState.NotReady
            }
        })
    }

    /**
     * Query available products/subscriptions.
     */
    private fun queryProducts() {
        val productList = ALL_PRODUCTS.map { productId ->
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(productId)
                .setProductType(BillingClient.ProductType.SUBS)
                .build()
        }

        val params = QueryProductDetailsParams.newBuilder()
            .setProductList(productList)
            .build()

        billingClient?.queryProductDetailsAsync(params) { result, productDetailsList ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                _products.value = productDetailsList
            }
        }
    }

    /**
     * Query existing purchases/subscriptions.
     */
    private fun queryPurchases() {
        val params = QueryPurchasesParams.newBuilder()
            .setProductType(BillingClient.ProductType.SUBS)
            .build()

        billingClient?.queryPurchasesAsync(params) { result, purchases ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                val activePurchase = purchases.firstOrNull { purchase ->
                    purchase.purchaseState == Purchase.PurchaseState.PURCHASED
                }
                _currentSubscription.value = activePurchase

                // Acknowledge any unacknowledged purchases
                purchases.filter { !it.isAcknowledged }.forEach { purchase ->
                    acknowledgePurchase(purchase)
                }
            }
        }
    }

    /**
     * Launch the purchase flow for a product.
     */
    fun launchPurchaseFlow(activity: Activity, productDetails: ProductDetails): BillingResult? {
        val offerToken = productDetails.subscriptionOfferDetails?.firstOrNull()?.offerToken
            ?: return null

        val productDetailsParamsList = listOf(
            BillingFlowParams.ProductDetailsParams.newBuilder()
                .setProductDetails(productDetails)
                .setOfferToken(offerToken)
                .build()
        )

        val billingFlowParams = BillingFlowParams.newBuilder()
            .setProductDetailsParamsList(productDetailsParamsList)
            .build()

        return billingClient?.launchBillingFlow(activity, billingFlowParams)
    }

    /**
     * Acknowledge a purchase.
     */
    private fun acknowledgePurchase(purchase: Purchase) {
        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED && !purchase.isAcknowledged) {
            val params = AcknowledgePurchaseParams.newBuilder()
                .setPurchaseToken(purchase.purchaseToken)
                .build()

            billingClient?.acknowledgePurchase(params) { result ->
                if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                    queryPurchases() // Refresh purchases
                }
            }
        }
    }

    /**
     * Called when a purchase is updated.
     */
    override fun onPurchasesUpdated(result: BillingResult, purchases: List<Purchase>?) {
        when (result.responseCode) {
            BillingClient.BillingResponseCode.OK -> {
                purchases?.forEach { purchase ->
                    if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
                        acknowledgePurchase(purchase)
                        _currentSubscription.value = purchase
                    }
                }
            }
            BillingClient.BillingResponseCode.USER_CANCELED -> {
                // User cancelled the purchase
            }
            else -> {
                _billingState.value = BillingState.Error(
                    "Purchase failed: ${result.debugMessage}"
                )
            }
        }
    }

    /**
     * Get the formatted price for a product.
     */
    fun getFormattedPrice(productDetails: ProductDetails): String {
        return productDetails.subscriptionOfferDetails
            ?.firstOrNull()
            ?.pricingPhases
            ?.pricingPhaseList
            ?.firstOrNull()
            ?.formattedPrice
            ?: ""
    }

    /**
     * Check if user has an active subscription for a specific plan.
     */
    fun hasActiveSubscription(productId: String): Boolean {
        val purchase = _currentSubscription.value ?: return false
        return purchase.products.contains(productId) &&
                purchase.purchaseState == Purchase.PurchaseState.PURCHASED
    }

    /**
     * Check if user has any active Pro or Premium subscription.
     */
    fun hasProOrPremium(): Boolean {
        return hasActiveSubscription(PRODUCT_PRO_MONTHLY) ||
                hasActiveSubscription(PRODUCT_PRO_YEARLY) ||
                hasActiveSubscription(PRODUCT_PREMIUM_MONTHLY) ||
                hasActiveSubscription(PRODUCT_PREMIUM_YEARLY)
    }

    /**
     * Clean up billing client.
     */
    fun cleanup() {
        billingClient?.endConnection()
        billingClient = null
    }
}

/**
 * State of the billing client.
 */
sealed class BillingState {
    data object NotReady : BillingState()
    data object Ready : BillingState()
    data class Error(val message: String) : BillingState()
}
