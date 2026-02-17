import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/products_provider.dart';
import '../../presentation/providers/products_state.dart';
import '../../domain/entities/product_entity.dart';
import 'package:eventosapp/shared/widgets/custom_app_bar.dart';
import 'package:eventosapp/shared/widgets/loading_widget.dart';
import 'package:eventosapp/shared/widgets/error_widget.dart' as app_widgets;
import 'package:eventosapp/shared/widgets/status_badge.dart';
import 'package:eventosapp/core/utils/num_extensions.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(productsProvider.notifier).loadProductDetail(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Detalle de Producto',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/products/${widget.productId}/edit');
            },
            tooltip: 'Editar',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const LoadingWidget(message: 'Cargando producto...'),
        error: (error, stack) => app_widgets.ErrorWidget(
          message: error.toString(),
          onRetry: () => ref.read(productsProvider.notifier).loadProductDetail(widget.productId),
        ),
        data: (state) {
          final product = state.selectedProduct;
          if (product == null) {
            return const Center(child: Text('Producto no encontrado'));
          }
          return _buildProductContent(context, product);
        },
      ),
    );
  }

  Widget _buildProductContent(BuildContext context, ProductEntity product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductHeader(context, product),
          _buildInfoSection(product),
          if (product.hasRecipe) _buildRecipeSection(product),
          _buildStatusSection(product),
        ],
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context, ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                child: Text(
                  product.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: product.statusLabel,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            product.formattedPrice,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ProductEntity product) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Información del Producto'),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.description, 'Descripción', product.description ?? 'Sin descripción'),
          _buildInfoItem(Icons.category_outlined, 'Categoría', product.category),
          _buildInfoItem(Icons.attach_money, 'Precio base', product.formattedPrice),
          const SizedBox(height: 24),
          _buildSectionTitle('Estado'),
          const SizedBox(height: 16),
          _buildStatusRow(product),
        ],
      ),
    );
  }

  Widget _buildRecipeSection(ProductEntity product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Receta'),
          const SizedBox(height: 16),
          Text(
            'Costo de receta: ${product.recipeCost.toCurrency()}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Margen de ganancia: ${product.profitMargin.toCurrency()}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Porcentaje de ganancia: ${product.profitPercentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...product.recipe!.map((ingredient) => _buildIngredientCard(ingredient)),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(RecipeIngredient ingredient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.ingredientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(ingredient.formattedQuantity),
                  Text(
                    'Inventario: ${ingredient.inventoryId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ingredient.formattedCost,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  ingredient.formattedCostPerUnit,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(ProductEntity product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Estado del producto'),
          const SizedBox(height: 16),
          StatusBadge(
            label: product.statusLabel,
            color: product.statusColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(ProductEntity product) {
    return Row(
      children: [
        _buildStatusChip('Activo', product.isActive, Colors.green),
        const SizedBox(width: 8),
        _buildStatusChip('Inactivo', !product.isActive, Colors.grey),
      ],
    );
  }

  Widget _buildStatusChip(String label, bool isSelected, Color color) {
    return Chip(
      label: Text(label),
      backgroundColor: isSelected ? color.withOpacity(0.2) : null,
      labelStyle: TextStyle(color: isSelected ? color : null),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: const Text('¿Estás seguro de que deseas eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(productsProvider.notifier).deleteProduct(widget.productId);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
