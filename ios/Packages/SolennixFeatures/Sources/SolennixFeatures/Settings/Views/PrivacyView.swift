import SwiftUI
import SolennixDesign

// MARK: - Privacy View

public struct PrivacyView: View {

    public init() {}

    public var body: some View {
        ScrollView {
            AdaptiveCenteredContent(maxWidth: 680) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Last updated
                Text("Ultima actualizacion: Enero 2025")
                    .font(.caption)
                    .foregroundStyle(SolennixColors.textTertiary)

                // Introduction
                policySection(
                    title: "Introduccion",
                    content: """
                    En Solennix, nos tomamos muy en serio la privacidad de nuestros usuarios. Esta politica describe como recopilamos, usamos y protegemos tu informacion personal cuando utilizas nuestra aplicacion.
                    """
                )

                // Data collection
                policySection(
                    title: "Informacion que Recopilamos",
                    content: """
                    Recopilamos la siguiente informacion:

                    • Informacion de la cuenta: nombre, correo electronico, contrasena encriptada.
                    • Informacion del negocio: nombre comercial, logo, colores de marca.
                    • Datos de eventos: informacion de clientes, productos, inventario y pagos.
                    • Datos de uso: como interactuas con la aplicacion para mejorar la experiencia.
                    """
                )

                // Data usage
                policySection(
                    title: "Como Usamos tu Informacion",
                    content: """
                    Utilizamos tu informacion para:

                    • Proporcionar y mantener nuestros servicios
                    • Generar documentos PDF personalizados
                    • Sincronizar datos entre dispositivos
                    • Enviar notificaciones importantes sobre tus eventos
                    • Mejorar y personalizar la experiencia de usuario
                    """
                )

                // Data sharing
                policySection(
                    title: "Compartir Informacion",
                    content: """
                    No vendemos tu informacion personal. Podemos compartir datos con:

                    • Proveedores de servicios (hosting, procesamiento de pagos)
                    • Autoridades legales cuando sea requerido por ley
                    • Con tu consentimiento explicito
                    """
                )

                // Data security
                policySection(
                    title: "Seguridad de Datos",
                    content: """
                    Implementamos medidas de seguridad incluyendo:

                    • Encriptacion de datos en transito y en reposo
                    • Autenticacion segura
                    • Copias de seguridad regulares
                    • Acceso restringido a datos personales
                    """
                )

                // User rights
                policySection(
                    title: "Tus Derechos",
                    content: """
                    Tienes derecho a:

                    • Acceder a tus datos personales
                    • Corregir informacion inexacta
                    • Eliminar tu cuenta y datos
                    • Exportar tus datos
                    • Retirar tu consentimiento
                    """
                )

                // Contact
                policySection(
                    title: "Contacto",
                    content: """
                    Si tienes preguntas sobre esta politica de privacidad, contactanos en:

                    privacidad@solennix.com
                    """
                )
            }
            .padding(Spacing.lg)
            }
        }
        .background(SolennixColors.surfaceGrouped)
        .navigationTitle("Privacidad")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Policy Section

    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.headline)
                .foregroundStyle(SolennixColors.text)

            Text(content)
                .font(.subheadline)
                .foregroundStyle(SolennixColors.textSecondary)
                .lineSpacing(4)
        }
    }
}

// MARK: - Preview

#Preview("Privacy") {
    NavigationStack {
        PrivacyView()
    }
}
