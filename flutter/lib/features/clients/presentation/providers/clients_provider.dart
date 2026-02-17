import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'clients_state.dart';
import '../../data/repositories/clients_repository.dart';
import '../../data/data_sources/clients_remote_data_source.dart';
import 'package:eventosapp/core/api/api_client_provider.dart';

final clientsProvider = AsyncNotifierProvider<ClientsNotifier, ClientsState>(
  () => ClientsNotifier(),
);

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  final remoteDataSource = ref.watch(clientsRemoteDataSourceProvider);
  return ClientsRepository(remoteDataSource: remoteDataSource);
});

final clientsRemoteDataSourceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ClientsRemoteDataSource(apiClient: apiClient);
});

class ClientsNotifier extends AsyncNotifier<ClientsState> {
  late final ClientsRepository _repository;

  Future<void> loadClients({String? search}) async {
    state = const AsyncLoading();
    try {
      final clients = await _repository.getClients(search: search);
      state = AsyncData(ClientsState().loaded(clients));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> searchClients(String query) async {
    final current = state.valueOrNull ?? const ClientsState();
    state = AsyncData(current.copyWith(searchQuery: query));
    await loadClients(search: query);
  }

  Future<void> filterByStatus(String? status) async {
    final current = state.valueOrNull ?? const ClientsState();
    state = AsyncData(current.copyWith(statusFilter: status));
    await loadClients(search: current.searchQuery);
  }

  Future<void> loadClientDetail(String id) async {
    try {
      final client = await _repository.getClientById(id);
      final current = state.valueOrNull ?? const ClientsState();
      state = AsyncData(current.copyWith(selectedClient: client));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> loadClientPayments(String clientId) async {
    try {
      final payments = await _repository.getClientPayments(clientId);
      final current = state.valueOrNull ?? const ClientsState();
      state = AsyncData(current.copyWith(payments: payments));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> createClient(Map<String, dynamic> data) async {
    final current = state.valueOrNull ?? const ClientsState();
    state = AsyncData(current.creating());
    try {
      final newClient = await _repository.createClient(data);
      final updatedClients = [...current.clients, newClient];
      state = AsyncData(ClientsState().loaded(updatedClients));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateClient(String id, Map<String, dynamic> data) async {
    final current = state.valueOrNull ?? const ClientsState();
    state = AsyncData(current.updating());
    try {
      final updatedClient = await _repository.updateClient(id, data);
      final updatedClients = current.clients.map((c) {
        return c.id == id ? updatedClient : c;
      }).toList();

      state = AsyncData(ClientsState().loaded(updatedClients));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deleteClient(String id) async {
    final current = state.valueOrNull ?? const ClientsState();
    state = AsyncData(current.deleting());
    try {
      await _repository.deleteClient(id);
      final updatedClients = current.clients.where((c) => c.id != id).toList();
      state = AsyncData(ClientsState().loaded(updatedClients));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    final current = state.valueOrNull ?? const ClientsState();
    await loadClients(search: current.searchQuery);
  }

  void clearSelectedClient() {
    final current = state.valueOrNull ?? const ClientsState();
    state = AsyncData(current.copyWith(selectedClient: null, payments: const []));
  }

  @override
  ClientsState build() {
    _repository = ref.watch(clientsRepositoryProvider);
    loadClients();
    return const ClientsState(isLoading: true);
  }
}
