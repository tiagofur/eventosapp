package com.creapolis.solennix.core.designsystem.theme

import androidx.compose.runtime.compositionLocalOf

/**
 * CompositionLocal that indicates whether the current layout is wide (tablet/desktop).
 * Set to true in AdaptiveNavigationRailLayout, false in CompactBottomNavLayout.
 * Screens can read this to adapt their layout for wider screens.
 */
val LocalIsWideScreen = compositionLocalOf { false }
