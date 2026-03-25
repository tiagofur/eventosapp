package com.creapolis.solennix.core.data.repository

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import com.creapolis.solennix.core.model.ThemeConfig
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SettingsRepositoryImpl @Inject constructor(
    private val dataStore: DataStore<Preferences>
) : SettingsRepository {

    private val THEME_CONFIG_KEY = stringPreferencesKey("theme_config")

    override val themeConfig: Flow<ThemeConfig> = dataStore.data.map { preferences ->
        val themeString = preferences[THEME_CONFIG_KEY] ?: ThemeConfig.SYSTEM_DEFAULT.name
        try {
            ThemeConfig.valueOf(themeString)
        } catch (e: IllegalArgumentException) {
            ThemeConfig.SYSTEM_DEFAULT
        }
    }

    override suspend fun setThemeConfig(config: ThemeConfig) {
        dataStore.edit { preferences ->
            preferences[THEME_CONFIG_KEY] = config.name
        }
    }
}
