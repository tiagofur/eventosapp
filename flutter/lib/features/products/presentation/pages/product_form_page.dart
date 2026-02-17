import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/products_provider.dart';

enum ProductFormStep { basic, pricing, status, review }

class ProductFormPage extends ConsumerStatefulWidget {
  final String? productId;

  const ProductFormPage({super.key, this.productId});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  bool _isActive = true;

  ProductFormStep _currentStep = ProductFormStep.basic;
  bool _isLoading = false;
  String _selectedCategory = 'Boda';

  final List<String> _categories = ['Boda', 'XV', 'Cumpleanos', 'Corporate'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Stepper(
                currentStep: _currentStep.index,
                onStepContinue: _handleStepContinue,
                onStepCancel: () => context.pop(),
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        if (_currentStep != ProductFormStep.review)
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: const Text('Siguiente'),
                          )
                        else
                          ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: const Text('Guardar'),
                          ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Cancelar'),
                        ),
                        if (_currentStep != ProductFormStep.basic) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => setState(() {
                              _currentStep = ProductFormStep.values[_currentStep.index - 1];
                            }),
                            child: const Text('Atrás'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    title: const Text('Información Básica'),
                    content: _buildBasicStep(),
                    isActive: _currentStep == ProductFormStep.basic,
                  ),
                  Step(
                    title: const Text('Precio'),
                    content: _buildPricingStep(),
                    isActive: _currentStep == ProductFormStep.pricing,
                  ),
                  Step(
                    title: const Text('Estado'),
                    content: _buildStatusStep(),
                    isActive: _currentStep == ProductFormStep.status,
                  ),
                  Step(
                    title: const Text('Revisar'),
                    content: _buildReviewStep(),
                    isActive: _currentStep == ProductFormStep.review,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBasicStep() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del producto',
            prefixIcon: Icon(Icons.inventory_2),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            prefixIcon: Icon(Icons.description),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Categoría',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPricingStep() {
    return Column(
      children: [
        TextFormField(
          controller: _basePriceController,
          decoration: const InputDecoration(
            labelText: 'Precio base',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
            prefixText: '\$',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El precio es requerido';
            }
            if (double.tryParse(value) == null) {
              return 'Precio inválido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusStep() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Producto activo'),
          subtitle: const Text('Controla si el producto aparece en cotizaciones.'),
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Producto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildReviewField('Nombre', _nameController.text),
            _buildReviewField('Descripción', _descriptionController.text),
            _buildReviewField('Categoría', _selectedCategory),
            _buildReviewField('Precio base', '\$${_basePriceController.text}'),
            _buildReviewField('Estado', _isActive ? 'Activo' : 'Inactivo'),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : 'No especificado'),
          ),
        ],
      ),
    );
  }

  void _handleStepContinue() {
    if (_currentStep == ProductFormStep.basic) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = ProductFormStep.pricing;
        });
      }
    } else if (_currentStep == ProductFormStep.pricing) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = ProductFormStep.status;
        });
      }
    } else if (_currentStep == ProductFormStep.status) {
      setState(() {
        _currentStep = ProductFormStep.review;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'category': _selectedCategory,
        'base_price': double.parse(_basePriceController.text),
        'is_active': _isActive,
      };

      if (widget.productId != null) {
        await ref.read(productsProvider.notifier).updateProduct(widget.productId!, data);
      } else {
        await ref.read(productsProvider.notifier).createProduct(data);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.productId != null
                ? 'Producto actualizado correctamente'
                : 'Producto creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
