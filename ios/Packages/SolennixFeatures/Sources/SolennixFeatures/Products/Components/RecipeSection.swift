import SwiftUI
import SolennixCore
import SolennixDesign

// MARK: - Recipe Section

/// A collapsible section for managing recipe items (ingredients, equipment, or supplies)
public struct RecipeSection: View {

    let title: String
    let description: String
    let items: [RecipeItem]
    let inventoryItems: [InventoryItem]
    let onAdd: () -> Void
    let onRemove: (Int) -> Void
    let onSelectInventory: (Int, String) -> Void
    let onUpdateQuantity: (Int, Double) -> Void

    public init(
        title: String,
        description: String,
        items: [RecipeItem],
        inventoryItems: [InventoryItem],
        onAdd: @escaping () -> Void,
        onRemove: @escaping (Int) -> Void,
        onSelectInventory: @escaping (Int, String) -> Void,
        onUpdateQuantity: @escaping (Int, Double) -> Void
    ) {
        self.title = title
        self.description = description
        self.items = items
        self.inventoryItems = inventoryItems
        self.onAdd = onAdd
        self.onRemove = onRemove
        self.onSelectInventory = onSelectInventory
        self.onUpdateQuantity = onUpdateQuantity
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(SolennixColors.text)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textTertiary)
                }

                Spacer()

                Button(action: onAdd) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Agregar")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(SolennixColors.primary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(SolennixColors.primaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
                .buttonStyle(.plain)
            }

            // Items
            if items.isEmpty {
                Text("No hay elementos agregados")
                    .font(.body)
                    .foregroundStyle(SolennixColors.textTertiary)
                    .italic()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
            } else {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    RecipeItemRow(
                        item: item,
                        inventoryItems: inventoryItems,
                        onSelectInventory: { inventoryId in
                            onSelectInventory(index, inventoryId)
                        },
                        onUpdateQuantity: { quantity in
                            onUpdateQuantity(index, quantity)
                        },
                        onRemove: {
                            onRemove(index)
                        }
                    )

                    if index < items.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Recipe Item Row

struct RecipeItemRow: View {

    let item: RecipeItem
    let inventoryItems: [InventoryItem]
    let onSelectInventory: (String) -> Void
    let onUpdateQuantity: (Double) -> Void
    let onRemove: () -> Void

    @State private var quantityText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Inventory selector
            Text("Seleccionar")
                .font(.caption)
                .foregroundStyle(SolennixColors.textTertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(inventoryItems) { inv in
                        Button {
                            onSelectInventory(inv.id)
                        } label: {
                            Text(inv.ingredientName)
                                .font(.caption)
                                .lineLimit(1)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xs)
                                .background(
                                    item.inventoryId == inv.id
                                        ? SolennixColors.primary
                                        : SolennixColors.surface
                                )
                                .foregroundStyle(
                                    item.inventoryId == inv.id
                                        ? .white
                                        : SolennixColors.textSecondary
                                )
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.md)
                                        .stroke(
                                            item.inventoryId == inv.id
                                                ? SolennixColors.primary
                                                : SolennixColors.border,
                                            lineWidth: 1
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Quantity and remove
            HStack(spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cantidad")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textTertiary)

                    HStack(spacing: Spacing.xs) {
                        TextField("1", text: $quantityText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                            .onChange(of: quantityText) { _, newValue in
                                if let value = Double(newValue) {
                                    onUpdateQuantity(value)
                                }
                            }

                        if let unit = item.unit {
                            Text(unit)
                                .font(.caption)
                                .foregroundStyle(SolennixColors.textTertiary)
                        }
                    }
                }

                Spacer()

                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundStyle(SolennixColors.error)
                        .padding(Spacing.xs)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, Spacing.xs)
        .onAppear {
            quantityText = String(format: "%.0f", item.quantityRequired)
        }
    }
}

// MARK: - Preview

#Preview("Recipe Section") {
    RecipeSection(
        title: "Composicion / Insumos",
        description: "Solo insumos generan costo al producto.",
        items: [
            RecipeItem(inventoryId: "1", quantityRequired: 2, inventoryName: "Harina", unit: "kg", type: .ingredient),
            RecipeItem(inventoryId: "2", quantityRequired: 1, inventoryName: "Azucar", unit: "kg", type: .ingredient)
        ],
        inventoryItems: [
            InventoryItem(id: "1", userId: "", ingredientName: "Harina", currentStock: 10, minimumStock: 5, unit: "kg", unitCost: nil, lastUpdated: "", type: .ingredient),
            InventoryItem(id: "2", userId: "", ingredientName: "Azucar", currentStock: 8, minimumStock: 3, unit: "kg", unitCost: nil, lastUpdated: "", type: .ingredient),
            InventoryItem(id: "3", userId: "", ingredientName: "Sal", currentStock: 5, minimumStock: 2, unit: "kg", unitCost: nil, lastUpdated: "", type: .ingredient)
        ],
        onAdd: {},
        onRemove: { _ in },
        onSelectInventory: { _, _ in },
        onUpdateQuantity: { _, _ in }
    )
    .padding()
}
