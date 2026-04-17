package com.creapolis.solennix.feature.staff.di

import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

/**
 * Hilt module del feature `staff`.
 *
 * Hoy no aporta bindings: el único repositorio que necesita (`StaffRepository`)
 * se liga en `:core:data` → `DataModule`, y los ViewModels usan `@HiltViewModel`
 * que Hilt resuelve por reflexión.
 *
 * El módulo existe para dejar un punto de extensión claro cuando Phase 2 o 3
 * requieran helpers específicos del feature (ej. formatter de fees, mapper de
 * notificaciones) sin tener que inyectarlos a través de `:core:data`.
 */
@Module
@InstallIn(SingletonComponent::class)
object StaffModule
