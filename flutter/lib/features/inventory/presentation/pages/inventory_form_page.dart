import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventosapp/shared/widgets/custom_app_bar.dart';
import 'package:eventosapp/features/inventory/presentation/providers/inventory_provider.dart';

class InventoryFormPage extends ConsumerStatefulWidget {
  const InventoryFormPage({super.key});

  @override
  ConsumerState<InventoryFormPage> createState() => _InventoryFormPageState();
}

class _InventoryFormPageState extends ConsumerState<InventoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _unitController = TextEditingController();
  final _unitCostController = TextEditingController();
  String _type = 'ingredient';

  @override
  void dispose() {
    _nameController.dispose();
    _currentStockController.dispose();
    _minimumStockController.dispose();
    _unitController.dispose();
    _unitCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Nuevo item de inventario'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Ingrediente o equipo'),
              validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _currentStockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock actual'),
              validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _minimumStockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock minimo'),
              validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(labelText: 'Unidad (kg, lt, pza)'),
              validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitCostController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Costo unitario'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'ingredient', child: Text('Ingrediente')),
                DropdownMenuItem(value: 'equipment', child: Text('Equipo')),
              ],
              onChanged: (value) => setState(() => _type = value ?? 'ingredient'),
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Guardar item'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentStock = double.tryParse(_currentStockController.text.trim()) ?? 0;
    final minimumStock = double.tryParse(_minimumStockController.text.trim()) ?? 0;
    final unitCost = double.tryParse(_unitCostController.text.trim()) ?? 0;

    await ref.read(inventoryProvider.notifier).createInventory({
      'ingredient_name': _nameController.text.trim(),
      'current_stock': currentStock,
      'minimum_stock': minimumStock,
      'unit': _unitController.text.trim(),
      'unit_cost': unitCost,
      'type': _type,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item creado')),
      );
      context.pop();
    }
  }
}
