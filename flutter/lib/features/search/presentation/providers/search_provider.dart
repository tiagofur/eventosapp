import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventosapp/core/api/api_client_provider.dart';
import 'package:eventosapp/features/search/data/data_sources/search_remote_data_source.dart';
import 'package:eventosapp/features/search/domain/repositories/search_repository.dart';

class SearchState {
  final List<SearchResultItem> results;
  final bool isLoading;
  final String? errorMessage;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SearchState copyWith({
    List<SearchResultItem>? results,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final String type;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
  });
}

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SearchRemoteDataSource(apiClient: apiClient);
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final remoteDataSource = ref.watch(searchRemoteDataSourceProvider);
  return SearchRepository(remoteDataSource: remoteDataSource);
});

final searchProvider = AsyncNotifierProvider<SearchNotifier, SearchState>(
  () => SearchNotifier(),
);

class SearchNotifier extends AsyncNotifier<SearchState> {
  late final SearchRepository _repository;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = AsyncData(const SearchState());
      return;
    }

    state = const AsyncLoading();
    try {
      final results = await _repository.search(query.trim());
      final mapped = _mapResults(results);
      state = AsyncData(SearchState(results: mapped));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  @override
  SearchState build() {
    _repository = ref.watch(searchRepositoryProvider);
    return const SearchState();
  }

  List<SearchResultItem> _mapResults(Map<String, dynamic> data) {
    final items = <SearchResultItem>[];

    final clients = data['clients'] as List<dynamic>? ?? const [];
    final events = data['events'] as List<dynamic>? ?? const [];
    final products = data['products'] as List<dynamic>? ?? const [];

    for (final client in clients) {
      final json = client as Map<String, dynamic>;
      items.add(
        SearchResultItem(
          id: json['id'] as String,
          title: json['name'] as String? ?? 'Cliente',
          subtitle: json['email'] as String? ?? json['phone'] as String? ?? 'Cliente',
          type: 'client',
        ),
      );
    }

    for (final event in events) {
      final json = event as Map<String, dynamic>;
      final clientName = (json['clients'] as Map<String, dynamic>?)?['name'] as String?;
      final date = json['event_date'] as String? ?? '';
      final subtitleParts = <String>[];
      if (clientName != null && clientName.isNotEmpty) {
        subtitleParts.add(clientName);
      }
      if (date.isNotEmpty) {
        subtitleParts.add(date);
      }
      items.add(
        SearchResultItem(
          id: json['id'] as String,
          title: json['service_type'] as String? ?? 'Evento',
          subtitle: subtitleParts.isNotEmpty ? subtitleParts.join(' • ') : 'Evento',
          type: 'event',
        ),
      );
    }

    for (final product in products) {
      final json = product as Map<String, dynamic>;
      final price = json['base_price'] as num?;
      final priceLabel = price != null ? '\$${price.toStringAsFixed(2)}' : null;
      items.add(
        SearchResultItem(
          id: json['id'] as String,
          title: json['name'] as String? ?? 'Producto',
          subtitle: priceLabel ?? 'Producto',
          type: 'product',
        ),
      );
    }

    return items;
  }
}
