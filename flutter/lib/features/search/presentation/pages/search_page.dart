import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventosapp/shared/widgets/custom_app_bar.dart';
import 'package:eventosapp/shared/widgets/status_badge.dart';
import 'package:eventosapp/shared/widgets/loading_widget.dart';
import 'package:eventosapp/shared/widgets/error_widget.dart' as app_widgets;
import 'package:eventosapp/features/search/presentation/providers/search_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Buscar'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Buscar clientes, eventos o productos',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        ref.read(searchProvider.notifier).search('');
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onSubmitted: (value) => ref.read(searchProvider.notifier).search(value),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16),
          searchAsync.when(
            loading: () => const LoadingWidget(message: 'Buscando...'),
            error: (error, stack) => app_widgets.ErrorWidget(
              message: error.toString(),
              onRetry: () => ref.read(searchProvider.notifier).search(_controller.text),
            ),
            data: (state) {
              if (_controller.text.trim().isEmpty) {
                return const Text('Escribe para buscar');
              }

              if (state.results.isEmpty) {
                return const Text('Sin resultados');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resultados',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...state.results.map((result) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(result.title),
                      subtitle: Text(result.subtitle),
                      leading: Icon(_iconForType(result.type), color: Colors.blueGrey),
                      trailing: StatusBadge(
                        label: _labelForType(result.type),
                        color: _colorForType(result.type),
                      ),
                      onTap: () => _handleResultTap(context, result),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleResultTap(BuildContext context, SearchResultItem result) {
    switch (result.type) {
      case 'event':
        context.push('/events/${result.id}');
        break;
      case 'client':
        context.push('/clients/${result.id}');
        break;
      case 'product':
        context.push('/products/${result.id}');
        break;
      default:
        break;
    }
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'event':
        return Icons.event;
      case 'client':
        return Icons.person_outline;
      case 'product':
        return Icons.inventory_2_outlined;
      default:
        return Icons.search;
    }
  }

  static String _labelForType(String type) {
    switch (type) {
      case 'event':
        return 'Evento';
      case 'client':
        return 'Cliente';
      case 'product':
        return 'Producto';
      default:
        return 'Otro';
    }
  }

  static Color _colorForType(String type) {
    switch (type) {
      case 'event':
        return Colors.blue;
      case 'client':
        return Colors.green;
      case 'product':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
