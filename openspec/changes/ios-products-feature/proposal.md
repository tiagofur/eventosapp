# Proposal: iOS Products Feature

## Intent

Implement the complete Products feature module for the native iOS app, enabling users to manage their product catalog. This is part of Phase 4 of the iOS native app development, following the established MVVM + Repository pattern.

Event organizers need to:
- Browse and search their product catalog
- Filter products by category
- Create new products with pricing and images
- Define product recipes (ingredients, equipment, supplies)
- View product details including demand forecast from upcoming events
- Edit and delete existing products

The React Native app has this feature fully implemented; the iOS native version must achieve feature parity while leveraging SwiftUI-native patterns for better performance and UX.

## Scope

### In Scope
- **ProductListView** — List/grid display with search, category filter chips, sort menu, swipe actions (edit/delete), FAB, skeleton loading, empty states
- **ProductFormView** — Create/edit form with image picker, name, category (picker + custom), price, active toggle, recipe editor (3 sections: ingredients, equipment, supplies)
- **ProductDetailView** — Product info display, recipe list, demand forecast chart (Swift Charts), edit/delete actions
- **ProductListViewModel** — API integration, search/filter/sort state, delete confirmation
- **ProductFormViewModel** — Form state, validation, image upload, recipe management, save logic
- **Navigation integration** — Wire views to RouteDestination, SidebarSplitLayout, MoreMenuView
- **Plan limits** — Basic plan: 20 products max (display warning when approaching limit)

### Out of Scope
- Product import/export functionality
- Bulk product operations
- Product duplication feature
- Core Spotlight indexing (deferred to Phase 5)
- iPad-specific optimizations beyond basic NavigationSplitView support
- Unit tests (separate task)

## Approach

**Hybrid implementation**: Use React Native screens as the feature specification but implement with SwiftUI-native patterns:

1. **ProductListView**
   - `.searchable` modifier instead of custom TextInput
   - `.swipeActions` modifier instead of SwipeableRow component
   - `Menu` with `Picker` for sort options
   - Horizontal `ScrollView` for category chips
   - `.refreshable` for pull-to-refresh
   - `.redacted(reason: .placeholder)` for skeleton loading

2. **ProductFormView**
   - SwiftUI `Form` with grouped sections
   - `PhotosPicker` (PhotosUI) for image selection
   - Custom category sheet using `.sheet` + `.presentationDetents`
   - `Toggle` for active state
   - Reusable `RecipeSection` component for ingredient/equipment/supply rows

3. **ProductDetailView**
   - `Swift Charts` for demand forecast visualization
   - Grouped sections for info and recipe display
   - `.confirmationDialog` for delete confirmation

4. **State Management**
   - `@Observable` ViewModels (iOS 17+ Observation framework)
   - API calls via existing `APIClient` actor
   - Environment injection for dependencies

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/` | New | Entire Products feature module (~10 files) |
| `ios/Solennix/Navigation/RouteDestination.swift` | Modified | Replace product placeholders with real views |
| `ios/Solennix/Navigation/SidebarSplitLayout.swift` | Modified | Add ProductListView to `.products` section case |
| `ios/Solennix/Navigation/CompactTabLayout.swift` | Modified | Add Products navigation to MoreMenuView |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Swift syntax errors (no compiler on Windows) | Medium | Follow established patterns from Clients feature; user validates on Mac |
| PhotosPicker compatibility | Low | PhotosPicker available iOS 16+, app targets iOS 17+ |
| Recipe editor state complexity | Medium | Use separate `RecipeSection` component; clear state isolation per type |
| Category picker UX differences | Low | Custom sheet implementation following RN behavior closely |
| API response format mismatches | Low | Product model already tested; use same patterns as Clients |

## Rollback Plan

The entire Products feature is contained within:
```
ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Products/
```

To rollback:
1. Delete the `Products/` directory
2. Revert changes to `RouteDestination.swift` (restore placeholders)
3. Revert changes to `SidebarSplitLayout.swift`
4. Revert changes to `CompactTabLayout.swift`

No existing code is modified beyond navigation wiring. The app will continue to function with placeholder screens.

## Dependencies

- **SolennixCore** — Product, ProductIngredient, InventoryItem models (already exist)
- **SolennixNetwork** — APIClient, Endpoints (already exist)
- **SolennixDesign** — Colors, Typography, Spacing, Components (already exist)
- **Inventory feature** — ProductFormView needs InventoryItem list for recipe editor (can use API directly; full Inventory feature not required)

## Success Criteria

- [ ] ProductListView displays all products from API with image, name, category, price
- [ ] Search filters products by name and category in real-time
- [ ] Category chips filter products; selected chip is visually highlighted
- [ ] Sort menu works (Name A-Z, Price, Category)
- [ ] Swipe actions trigger edit navigation and delete confirmation
- [ ] FAB navigates to ProductFormView in create mode
- [ ] ProductFormView validates required fields (name, category)
- [ ] Image picker allows selecting photo from library
- [ ] Category picker shows existing categories + custom input option
- [ ] Recipe editor allows adding/removing ingredients, equipment, supplies
- [ ] Save creates new product or updates existing product via API
- [ ] ProductDetailView shows all product info including recipe
- [ ] Demand forecast chart displays upcoming events using this product
- [ ] Delete confirmation dialog works; successful delete removes from list
- [ ] Navigation works from both sidebar (iPad) and MoreMenu (iPhone)
- [ ] All views render correctly in light and dark mode
- [ ] Empty states display when no products or no search results
- [ ] Plan limit warning shows when approaching 20 products (basic plan)
