import SwiftUI
import SolennixDesign

// MARK: - Terms View

public struct TermsView: View {

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Last updated
                Text("Ultima actualizacion: Enero 2025")
                    .font(.caption)
                    .foregroundStyle(SolennixColors.textTertiary)

                // Introduction
                termsSection(
                    title: "1. Aceptacion de Terminos",
                    content: """
                    Al acceder y utilizar Solennix, aceptas estos terminos de servicio. Si no estas de acuerdo con alguna parte de estos terminos, no debes usar la aplicacion.
                    """
                )

                // Service description
                termsSection(
                    title: "2. Descripcion del Servicio",
                    content: """
                    Solennix es una plataforma de gestion de eventos que permite:

                    • Gestionar clientes y contactos
                    • Crear y administrar productos y servicios
                    • Controlar inventario
                    • Generar contratos y cotizaciones
                    • Programar y dar seguimiento a eventos
                    """
                )

                // User responsibilities
                termsSection(
                    title: "3. Responsabilidades del Usuario",
                    content: """
                    Como usuario, te comprometes a:

                    • Proporcionar informacion veraz y actualizada
                    • Mantener la seguridad de tu cuenta
                    • No usar el servicio para actividades ilegales
                    • Respetar los derechos de propiedad intelectual
                    • No intentar acceder a cuentas de otros usuarios
                    """
                )

                // Subscription and payment
                termsSection(
                    title: "4. Suscripciones y Pagos",
                    content: """
                    • El plan basico es gratuito con funciones limitadas
                    • El plan premium requiere pago mensual o anual
                    • Los pagos se procesan a traves de proveedores seguros
                    • Puedes cancelar tu suscripcion en cualquier momento
                    • No hay reembolsos por periodos parciales
                    """
                )

                // Intellectual property
                termsSection(
                    title: "5. Propiedad Intelectual",
                    content: """
                    • Solennix y su contenido son propiedad de Creapolis
                    • Los datos que ingresas son de tu propiedad
                    • Nos otorgas licencia para usar tus datos para el servicio
                    • No puedes copiar o redistribuir la aplicacion
                    """
                )

                // Limitation of liability
                termsSection(
                    title: "6. Limitacion de Responsabilidad",
                    content: """
                    • El servicio se proporciona "tal cual"
                    • No garantizamos disponibilidad ininterrumpida
                    • No somos responsables de perdidas indirectas
                    • Nuestra responsabilidad esta limitada al monto pagado
                    """
                )

                // Termination
                termsSection(
                    title: "7. Terminacion",
                    content: """
                    Podemos suspender o terminar tu cuenta si:

                    • Violas estos terminos de servicio
                    • Usas el servicio de manera fraudulenta
                    • No pagas las tarifas aplicables

                    Puedes terminar tu cuenta en cualquier momento desde la configuracion.
                    """
                )

                // Changes to terms
                termsSection(
                    title: "8. Cambios a los Terminos",
                    content: """
                    Podemos modificar estos terminos en cualquier momento. Te notificaremos de cambios significativos por correo electronico o dentro de la aplicacion. El uso continuo despues de los cambios constituye aceptacion.
                    """
                )

                // Governing law
                termsSection(
                    title: "9. Ley Aplicable",
                    content: """
                    Estos terminos se rigen por las leyes de Mexico. Cualquier disputa se resolvera en los tribunales de la Ciudad de Mexico.
                    """
                )

                // Contact
                termsSection(
                    title: "10. Contacto",
                    content: """
                    Para preguntas sobre estos terminos:

                    legal@solennix.com
                    """
                )
            }
            .padding(Spacing.lg)
        }
        .background(SolennixColors.surfaceGrouped)
        .navigationTitle("Terminos de Servicio")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Terms Section

    private func termsSection(title: String, content: String) -> some View {
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

#Preview("Terms") {
    NavigationStack {
        TermsView()
    }
}
