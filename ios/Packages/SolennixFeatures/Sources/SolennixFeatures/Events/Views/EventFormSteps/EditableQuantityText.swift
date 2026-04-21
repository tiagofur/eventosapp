import SwiftUI
import SolennixDesign

/// Número tappable dentro de los steppers +/-. Al tocarlo abre el teclado
/// numérico y permite tipear directamente — evita decenas de clicks cuando
/// la cantidad es alta (100 platos, 200 personas).
///
/// Binding<Int> es autoritativo al terminar la edición. Durante la edición
/// el @State local permite estados transitorios vacíos sin pisar al VM con
/// 0 (que algunas pantallas interpretan como remove).
///
/// - `id`: cualquier valor hashable que cambia cuando el binding apunta a
///   otro item (item.id / extra.id). Rehidrata el texto local.
/// - `minValue`: al blur, `quantity` se clamp-ea a este mínimo. 0 para
///   "Numero de Personas" (permite crear evento en estado temporal sin
///   contar), 1 para productos/equipamiento/insumos.
struct EditableQuantityText: View {

    @Binding var quantity: Int
    let minValue: Int
    let id: AnyHashable
    var font: Font = .body
    var width: CGFloat = 36
    /// Si true, pinta el número en gris cuando está al mínimo. Usado en
    /// Step 1 (personas en 0 → placeholder-like tertiary).
    var showTertiaryAtMin: Bool = false
    /// Override manual del color. Útil cuando el caller necesita señalar
    /// estado (overstock rojo en equipamiento).
    var colorOverride: Color? = nil

    @State private var text: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        TextField("\(minValue)", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(font)
            .fontWeight(.semibold)
            .monospacedDigit()
            .foregroundStyle(
                colorOverride
                    ?? (showTertiaryAtMin && quantity == minValue
                        ? SolennixColors.textTertiary
                        : SolennixColors.text)
            )
            .focused($focused)
            .frame(width: width)
            .onAppear { text = String(quantity) }
            .onChange(of: id) { _, _ in text = String(quantity) }
            .onChange(of: quantity) { _, newValue in
                // Sync desde afuera (stepper +/-, prefill, edit). Nunca
                // pisar lo que el usuario está tipiando.
                if !focused { text = String(newValue) }
            }
            .onChange(of: text) { _, newText in
                // Permitir vacío transitorio. Solo propagar si hay int
                // parseable — evita clamp/remove mientras se edita.
                if let parsed = Int(newText) {
                    quantity = parsed
                }
            }
            .onChange(of: focused) { _, isFocused in
                if !isFocused {
                    // Blur: clamp al min y rehidratar.
                    let clamped = max(minValue, Int(text) ?? minValue)
                    quantity = clamped
                    text = String(clamped)
                }
            }
    }
}
