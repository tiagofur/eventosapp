import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventosapp/shared/widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Configuración'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'Cuenta',
            children: [
              _SettingsTile(
                title: 'Perfil',
                subtitle: 'Datos personales y contacto',
                icon: Icons.person_outline,
                onTap: () => context.push('/settings/profile'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Negocio',
            children: [
              _SettingsTile(
                title: 'Contrato',
                subtitle: 'Depósito y cancelaciones',
                icon: Icons.description_outlined,
                onTap: () => context.push('/settings/contract'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Aplicación',
            children: [
              _SettingsTile(
                title: 'Preferencias',
                subtitle: 'Notificaciones y calendario',
                icon: Icons.tune,
                onTap: () => context.push('/settings/app'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Perfil'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _businessController,
              decoration: const InputDecoration(labelText: 'Empresa'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado')),
    );
  }
}

class ContractSettingsPage extends StatefulWidget {
  const ContractSettingsPage({super.key});

  @override
  State<ContractSettingsPage> createState() => _ContractSettingsPageState();
}

class _ContractSettingsPageState extends State<ContractSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _depositController = TextEditingController(text: '50');
  final _cancellationDaysController = TextEditingController(text: '7');
  final _refundController = TextEditingController(text: '50');

  @override
  void dispose() {
    _depositController.dispose();
    _cancellationDaysController.dispose();
    _refundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Configuración de Contrato'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _depositController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Depósito (%)'),
              validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cancellationDaysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Días de cancelación'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _refundController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Reembolso (%)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveContractSettings,
              child: const Text('Guardar configuración'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveContractSettings() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración de contrato guardada')),
    );
  }
}

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _notificationsEnabled = true;
  bool _calendarSyncEnabled = false;
  bool _compactMode = false;

  String _currency = 'MXN';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Configuración de App'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            title: const Text('Notificaciones'),
            subtitle: const Text('Recibir alertas de eventos y pagos'),
          ),
          SwitchListTile(
            value: _calendarSyncEnabled,
            onChanged: (value) => setState(() => _calendarSyncEnabled = value),
            title: const Text('Sincronizar calendario'),
            subtitle: const Text('Integrar con calendario del dispositivo'),
          ),
          SwitchListTile(
            value: _compactMode,
            onChanged: (value) => setState(() => _compactMode = value),
            title: const Text('Vista compacta'),
            subtitle: const Text('Mostrar listas con menos espacio'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _currency,
            decoration: const InputDecoration(labelText: 'Moneda'),
            items: const [
              DropdownMenuItem(value: 'MXN', child: Text('MXN - Peso mexicano')),
              DropdownMenuItem(value: 'USD', child: Text('USD - Dólar')),
            ],
            onChanged: (value) => setState(() => _currency = value ?? 'MXN'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preferencias guardadas')),
              );
            },
            child: const Text('Guardar preferencias'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
