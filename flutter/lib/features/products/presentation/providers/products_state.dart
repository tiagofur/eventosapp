import '../../domain/entities/product_entity.dart';

class ProductsState {
  final List<ProductEntity> products;
  final ProductEntity? selectedProduct;
  final String searchQuery;
  final String? categoryFilter;
  final String? statusFilter;
  final List<String> categories;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;

  const ProductsState({
    this.products = const [],
    this.selectedProduct,
    this.searchQuery = '',
    this.categoryFilter,
    this.statusFilter,
    this.categories = const ['Boda', 'XV', 'Cumpleanos', 'Corporate'],
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
  });

  ProductsState copyWith({
    List<ProductEntity>? products,
    ProductEntity? selectedProduct,
    String? searchQuery,
    String? categoryFilter,
    String? statusFilter,
    List<String>? categories,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
  }) {
    return ProductsState(
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage,
    );
  }

  ProductsState loading() => copyWith(isLoading: true, errorMessage: null);
  ProductsState error(String message) => copyWith(errorMessage: message, isLoading: false);
  ProductsState loaded(List<ProductEntity> productsList) => copyWith(
    products: productsList,
    isLoading: false,
    errorMessage: null,
  );
  ProductsState creating() => copyWith(isCreating: true, errorMessage: null);
  ProductsState updating() => copyWith(isUpdating: true, errorMessage: null);
  ProductsState deleting() => copyWith(isDeleting: true, errorMessage: null);
}
