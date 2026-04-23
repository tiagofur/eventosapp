package com.creapolis.solennix.feature.settings.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.creapolis.solennix.core.designsystem.component.SolennixTopAppBar
import com.creapolis.solennix.core.designsystem.component.adaptive.AdaptiveCenteredContent
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PrivacyScreen(
    onNavigateBack: () -> Unit
) {
    val scrollState = rememberScrollState()
    val uriHandler = LocalUriHandler.current

    Scaffold(
        topBar = {
            SolennixTopAppBar(
                title = { Text("Política de Privacidad") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Volver")
                    }
                }
            )
        }
    ) { padding ->
        AdaptiveCenteredContent(maxWidth = 700.dp) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(scrollState)
                .padding(16.dp)
        ) {
            Text(
                text = "Última actualización: 23 de abril de 2026",
                style = MaterialTheme.typography.bodySmall,
                color = SolennixTheme.colors.secondaryText,
                modifier = Modifier.padding(bottom = 16.dp)
            )

            PolicySection(
                title = "1. Información que Recopilamos",
                content = "Recopilamos información que nos proporcionas directamente, como tu nombre, correo electrónico, información de tu negocio y datos de tus clientes y eventos. También recopilamos información automáticamente sobre cómo usas la aplicación para mejorar nuestros servicios y garantizar la seguridad."
            )

            PolicySection(
                title = "2. Uso de la Información",
                content = "Utilizamos la información recopilada para:\n• Proporcionar y mejorar nuestros servicios\n• Gestionar tu cuenta y suscripción\n• Enviar notificaciones importantes sobre eventos y pagos\n• Procesar pagos de forma segura\n• Cumplir con obligaciones legales y regulatorias"
            )

            PolicySection(
                title = "3. Almacenamiento de Datos",
                content = "Tus datos se almacenan de forma segura en servidores con cifrado de nivel industrial. Implementamos medidas de seguridad técnicas y organizativas para proteger tu información personal contra acceso no autorizado, pérdida o alteración."
            )

            PolicySection(
                title = "4. Compartir Información",
                content = "No vendemos ni compartimos tu información personal con terceros para fines publicitarios. Solo compartimos datos con proveedores de servicios esenciales (pagos, infraestructura) o cuando sea requerido por ley."
            )

            PolicySection(
                title = "5. Tus Derechos y Eliminación",
                content = "Tienes derecho a acceder, corregir y solicitar la eliminación de tus datos personales. Para ejercer tu derecho al borrado, puedes iniciar el proceso desde la configuración de la cuenta o visitar nuestra página web pública de eliminación:\nsolennix.creapolis.dev/eliminar-cuenta"
            )

            TextButton(
                onClick = { uriHandler.openUri("https://solennix.creapolis.dev/eliminar-cuenta") },
                modifier = Modifier.padding(bottom = 16.dp)
            ) {
                Text("Ir a página de eliminación de cuenta", color = SolennixTheme.colors.primary)
            }

            PolicySection(
                title = "6. Cookies y Tecnologías Similares",
                content = "Utilizamos almacenamiento local seguro para mantener tu sesión iniciada y tus preferencias. No utilizamos tecnologías de rastreo con fines comerciales ni compartimos hábitos de navegación."
            )

            PolicySection(
                title = "7. Cambios a esta Política",
                content = "Podemos actualizar esta política ocasionalmente para reflejar cambios en el servicio o requisitos legales. Te notificaremos sobre cambios significativos a través de la aplicación o por correo electrónico."
            )

            PolicySection(
                title = "8. Contacto",
                content = "Si tienes preguntas sobre esta política de privacidad o sobre el tratamiento de tus datos, contáctanos en:\nhola@creapolis.dev"
            )

            Spacer(modifier = Modifier.height(32.dp))
        }
        }
    }
}

@Composable
private fun PolicySection(title: String, content: String) {
    Column(modifier = Modifier.padding(bottom = 20.dp)) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
            color = SolennixTheme.colors.primaryText,
            modifier = Modifier.padding(bottom = 8.dp)
        )
        Text(
            text = content,
            style = MaterialTheme.typography.bodyMedium,
            color = SolennixTheme.colors.secondaryText,
            lineHeight = MaterialTheme.typography.bodyMedium.lineHeight * 1.4
        )
    }
}

