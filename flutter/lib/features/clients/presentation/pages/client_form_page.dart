import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/clients_provider.dart';

enum ClientFormStep { personal, contact, review }

class ClientFormPage extends ConsumerStatefulWidget {
  final String? clientId;

  const ClientFormPage({super.key, this.clientId});

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  ClientFormStep _currentStep = ClientFormStep.personal;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientId != null ? 'Editar Cliente' : 'Nuevo Cliente'),
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
                        if (_currentStep != ClientFormStep.review)
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
                        if (_currentStep != ClientFormStep.personal) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => setState(() {
                              _currentStep = ClientFormStep.values[_currentStep.index - 1];
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
                    title: const Text('Información Personal'),
                    content: _buildPersonalStep(),
                    isActive: _currentStep == ClientFormStep.personal,
                  ),
                  Step(
                    title: const Text('Contacto'),
                    content: _buildContactStep(),
                    isActive: _currentStep == ClientFormStep.contact,
                  ),
                  Step(
                    title: const Text('Revisar'),
                    content: _buildReviewStep(),
                    isActive: _currentStep == ClientFormStep.review,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPersonalStep() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre completo',
            prefixIcon: Icon(Icons.person),
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
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El email es requerido';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: 'Ciudad (opcional)',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactStep() {
    return Column(
      children: [
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El teléfono es requerido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Dirección',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notas (opcional)',
            prefixIcon: Icon(Icons.note),
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
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
              'Resumen del Cliente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildReviewField('Nombre', _nameController.text),
            _buildReviewField('Email', _emailController.text),
            if (_cityController.text.isNotEmpty)
              _buildReviewField('Ciudad', _cityController.text),
            _buildReviewField('Teléfono', _phoneController.text),
            if (_addressController.text.isNotEmpty)
              _buildReviewField('Dirección', _addressController.text),
            if (_notesController.text.isNotEmpty)
              _buildReviewField('Notas', _notesController.text),
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
            width: 100,
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
    if (_currentStep == ClientFormStep.personal) {
      setState(() {
        _currentStep = ClientFormStep.contact;
      });
    } else if (_currentStep == ClientFormStep.contact) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = ClientFormStep.review;
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      };

      if (widget.clientId != null) {
        await ref.read(clientsProvider.notifier).updateClient(widget.clientId!, data);
      } else {
        await ref.read(clientsProvider.notifier).createClient(data);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.clientId != null
                ? 'Cliente actualizado correctamente'
                : 'Cliente creado correctamente'),
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
