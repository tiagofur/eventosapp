import '../../domain/entities/client_entity.dart';

class ClientsState {
  final List<ClientEntity> clients;
  final ClientEntity? selectedClient;
  final List<ClientPayment> payments;
  final String searchQuery;
  final String? statusFilter;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;

  const ClientsState({
    this.clients = const [],
    this.selectedClient,
    this.payments = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
  });

  ClientsState copyWith({
    List<ClientEntity>? clients,
    ClientEntity? selectedClient,
    List<ClientPayment>? payments,
    String? searchQuery,
    String? statusFilter,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
  }) {
    return ClientsState(
      clients: clients ?? this.clients,
      selectedClient: selectedClient ?? this.selectedClient,
      payments: payments ?? this.payments,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage,
    );
  }

  ClientsState loading() => copyWith(isLoading: true, errorMessage: null);
  ClientsState error(String message) => copyWith(errorMessage: message, isLoading: false);
  ClientsState loaded(List<ClientEntity> clientsList) => copyWith(
    clients: clientsList,
    isLoading: false,
    errorMessage: null,
  );
  ClientsState creating() => copyWith(isCreating: true, errorMessage: null);
  ClientsState updating() => copyWith(isUpdating: true, errorMessage: null);
  ClientsState deleting() => copyWith(isDeleting: true, errorMessage: null);
}
