# Exploration: iOS Products Feature

## Current State

### Existing Infrastructure
The iOS app has a complete foundation (Phase 1-3) with:
- **Product Model**: `ios/Packages/SolennixCore/Sources/SolennixCore/Models/Product.swift` - Complete Codable struct with all fields
- **ProductIngredient Model**: `ios/Packages/SolennixCore/Sources/SolennixCore/Models/ProductIngredient.swift` - Recipe/ingredient junction
- **API Endpoints**: Defined in `Endpoints.swift`:
  - `GET/POST /products` - List/Create
  - `GET/PUT/DELETE /products/{id}` - CRUD
  - `GET/PUT /products/{id}/ingredients` - Recipe management
  - `POST /products/ingredients/batch` - Batch ingredient updates
- **Navigation Routes**: Already defined in `Route.swift`:
  - `.productDetail(id: String)`
  - `.productForm(id: String? = nil)`
- **Sidebar Section**: `.products` already in `SidebarSection` enum

### What's Missing
- **ProductListView** - Grid/list with categories, search, sort
- **ProductFormView** - Name, category, price, image, recipe editor
- **ProductDetailView** - Info, demand forecast chart, recipe display
- **ProductListViewModel** - API integration, filtering, sorting
- **ProductFormViewModel** - Form state, validation, save logic
- **UI Components** - ProductCard, CategoryChips, RecipeEditor, DemandForecastChart

### React Native Reference Implementation
Located in `mobile/src/screens/catalog/`:
- `ProductListScreen.tsx` (475 lines) - Full implementation with:
  - Search bar with clear button
  - Category filter chips (horizontal scroll)
  - Sort selector (Name, Price, Category)
  - SwipeableRow with Edit/Delete actions
  - FAB for new product
  - Skeleton loading state
  - Empty states (no products, no results)

- `ProductFormScreen.tsx` (1077 lines) - Complex form with:
  - Image picker (gallery + camera)
  - Name, Category (picker with custom input), Base Price
  - Active toggle
  - Recipe sections by type:
    - Composición/Insumos (ingredients)
    - Equipo Necesario (equipment)
    - Insumos por Evento (supplies)
  - Each recipe item: inventory selector + quantity + unit display
  - Bottom sheet for category selection

## Affected Areas

### Files to Create
| File | Purpose |
|------|---------|
| `Products/Views/ProductListView.swift` | Main list view with search, filter, sort |
| `Products/Views/ProductFormView.swift` | Create/edit form with recipe editor |
| `Products/Views/ProductDetailView.swift` | Detail view with demand forecast |
| `Products/ViewModels/ProductListViewModel.swift` | List state, API calls, filtering |
| `Products/ViewModels/ProductFormViewModel.swift` | Form state, validation, save |
| `Products/Components/ProductCard.swift` | List item card component |
| `Products/Components/CategoryChips.swift` | Horizontal category filter |
| `Products/Components/RecipeEditor.swift` | Recipe section component |
| `Products/Components/DemandForecastChart.swift` | Swift Charts demand visualization |

### Files to Modify
| File | Change |
|------|--------|
| `RouteDestination.swift` | Replace placeholders with real views |
| `SidebarSplitLayout.swift` | Add ProductListView to `.products` section |
| `CompactTabLayout.swift` | Add Products to MoreMenuView |

## Approaches

### 1. **Direct Port from RN** — Mirror React Native implementation closely
- Pros: Feature parity guaranteed, familiar UX for users
- Cons: May not leverage native patterns optimally
- Effort: Medium

### 2. **SwiftUI-First Design** — Redesign using native patterns
- Pros: Better native feel, cleaner code, uses `.searchable`, `Menu`, `Picker`
- Cons: May diverge from RN app UX
- Effort: Medium-High

### 3. **Hybrid** (Recommended) — Use RN as spec, implement with native patterns
- Pros: Same features but using SwiftUI idioms (`.searchable`, `.swipeActions`, `Menu`)
- Cons: None significant
- Effort: Medium

## Recommendation

**Approach 3 (Hybrid)** - Use React Native implementation as the feature specification but implement using native SwiftUI patterns:

1. **ProductListView**: Use `.searchable` modifier instead of custom TextInput, `.swipeActions` instead of SwipeableRow, native `Picker` for sort
2. **ProductFormView**: Use SwiftUI `Form` with sections, `PhotosPicker` for images, `Toggle` for active state
3. **ProductDetailView**: Use `Swift Charts` for demand forecast (new feature not in RN)
4. **CategoryChips**: Use horizontal `ScrollView` with `Button` chips (similar to RN)

This preserves the established UX while leveraging SwiftUI's strengths.

## Risks

1. **No Swift compiler on Windows** - Code must be syntactically valid; user validates on Mac
2. **PhotosPicker API differences** - iOS 16+ only, need to handle properly
3. **Recipe editor complexity** - Dynamic form with 3 sections needs careful state management
4. **Category picker** - Need custom sheet similar to RN but using SwiftUI idioms

## Ready for Proposal

**Yes** — The exploration is complete. Key findings:
- All infrastructure exists (models, endpoints, routes, navigation)
- Clear reference implementation in React Native
- Recommended approach: SwiftUI-native implementation following RN feature spec
- Estimated ~10-12 new Swift files

Next step: Create proposal defining scope, success criteria, and task breakdown.
