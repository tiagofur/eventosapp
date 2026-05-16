package com.creapolis.solennix.feature.auth.ui

import androidx.activity.ComponentActivity
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.creapolis.solennix.feature.auth.R
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.feature.auth.viewmodel.AuthViewModel
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.runs
import kotlinx.coroutines.flow.MutableSharedFlow
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class LoginScreenSmokeTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun loginScreen_rendersKeyElements() {
        val loginSuccessFlow = MutableSharedFlow<Unit>(replay = 0, extraBufferCapacity = 1)
        val viewModel = mockk<AuthViewModel>(relaxed = true)

        every { viewModel.loginSuccess } returns loginSuccessFlow
        every { viewModel.loginEmail } returns ""
        every { viewModel.loginEmail = any() } just runs
        every { viewModel.loginPassword } returns ""
        every { viewModel.loginPassword = any() } just runs
        every { viewModel.isLoading } returns false
        every { viewModel.isLoginValid } returns false
        every { viewModel.errorMessage } returns null
        every { viewModel.login() } just runs
        every { viewModel.loginWithGoogle(any(), any()) } just runs
        every { viewModel.loginWithApple(any(), any()) } just runs

        composeRule.setContent {
            SolennixTheme {
                LoginScreen(
                    viewModel = viewModel,
                    onNavigateToRegister = {},
                    onNavigateToForgot = {}
                )
            }
        }

        val submitText = composeRule.activity.getString(R.string.auth_login_submit)
        val forgotText = composeRule.activity.getString(R.string.auth_login_forgot_password)

        composeRule.onNodeWithText("SOLENNIX").assertIsDisplayed()
        composeRule.onNodeWithText(submitText).assertIsDisplayed()
        composeRule.onNodeWithText(forgotText).assertIsDisplayed()
    }
}
