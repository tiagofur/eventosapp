package com.creapolis.solennix.baselineprofile

import androidx.benchmark.macro.BaselineProfileMode
import androidx.benchmark.macro.CompilationMode
import androidx.benchmark.macro.StartupMode
import androidx.benchmark.macro.junit4.BaselineProfileRule
import androidx.benchmark.macro.junit4.MacrobenchmarkRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.Until
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class BaselineProfileGenerator {

    @get:Rule
    val baselineProfileRule = BaselineProfileRule()

    @get:Rule
    val macrobenchmarkRule = MacrobenchmarkRule()

    private val packageName = "com.solennix.app"

    @Test
    fun generateBaselineProfile() {
        val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
        baselineProfileRule.collect(
            packageName = packageName,
            includeInStartupProfile = true
        ) {
            pressHome()
            startActivityAndWait()

            // Keep startup and top-level navigation paths warm for release.
            device.wait(Until.hasObject(By.pkg(packageName).depth(0)), 5_000)
            pressHome()
            startActivityAndWait()
        }
    }

    @Test
    fun measureColdStartup() {
        val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
        macrobenchmarkRule.measureRepeated(
            packageName = packageName,
            metrics = listOf(androidx.benchmark.macro.StartupTimingMetric()),
            compilationMode = CompilationMode.Partial(
                baselineProfileMode = BaselineProfileMode.Require
            ),
            startupMode = StartupMode.COLD,
            iterations = 5
        ) {
            pressHome()
            startActivityAndWait()
            device.wait(Until.hasObject(By.pkg(packageName).depth(0)), 5_000)
        }
    }
}
