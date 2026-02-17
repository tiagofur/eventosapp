import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventosapp/features/events/presentation/providers/events_state.dart';
import 'package:eventosapp/features/events/domain/repositories/event_repository.dart';
import 'package:eventosapp/features/events/data/data_sources/event_remote_data_source.dart';
import 'package:eventosapp/core/api/api_client_provider.dart';
import 'package:eventosapp/features/events/domain/entities/event_entity.dart';

final eventsProvider = AsyncNotifierProvider<EventsNotifier, EventsState>(
  () => EventsNotifier(),
);

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final remoteDataSource = ref.watch(eventRemoteDataSourceProvider);
  return EventRepository(remoteDataSource: remoteDataSource);
});

final eventRemoteDataSourceProvider = Provider<EventRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventRemoteDataSource(apiClient: apiClient);
});

final eventDetailProvider = AsyncNotifierProvider<EventDetailNotifier, EventDetailState>(
  () => EventDetailNotifier(),
);

class EventsNotifier extends AsyncNotifier<EventsState> {
  late final EventRepository _repository;

  Future<void> loadEvents({
    int page = 1,
    String? status,
    String? clientId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.getEvents(
        page: page,
        status: status,
        clientId: clientId,
        startDate: startDate,
        endDate: endDate,
      );

      final events = response.events.map(EventEntity.fromModel).toList();
      state = AsyncData(
        EventsState().copyWith(
          events: events,
          currentPage: page,
          totalPages: page,
          currentFilter: status,
          isLoading: false,
        ),
      );
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    await loadEvents(
      status: state.valueOrNull?.currentFilter,
      page: state.valueOrNull?.currentPage ?? 1,
    );
  }

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    try {
      await _repository.createEvent(eventData);
      await refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _repository.deleteEvent(id);
      await refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateEventStatus(String id, String status) async {
    try {
      await _repository.updateEventStatus(id, status);
      await refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> filterByStatus(String status) async {
    state = AsyncData(EventsState().withFilter(status));
    await loadEvents(status: status, page: 1);
  }

  Future<void> selectEvent(EventEntity event) async {
    state = AsyncData(EventsState().withEvent(event));
  }

  void clearSelection() {
    state = AsyncData((state.valueOrNull ?? const EventsState()).copyWith(selectedEvent: null));
  }

  @override
  EventsState build() {
    _repository = ref.watch(eventRepositoryProvider);
    loadEvents();
    return const EventsState(isLoading: true);
  }
}

class EventDetailNotifier extends AsyncNotifier<EventDetailState> {
  late final EventRepository _repository;

  Future<void> loadEventDetail(String id) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.getEvent(id);
      state = AsyncData(EventDetailState().loaded(EventEntity.fromModel(response.event)));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> eventData) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.updateEvent(id, eventData);
      state = AsyncData(EventDetailState().loaded(EventEntity.fromModel(response.event)));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> addPayment(String eventId, Map<String, dynamic> paymentData) async {
    try {
      await _repository.addPayment(eventId, paymentData);
      await loadEventDetail(eventId);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deletePayment(String eventId, String paymentId) async {
    try {
      await _repository.deletePayment(eventId, paymentId);
      await loadEventDetail(eventId);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  @override
  EventDetailState build() {
    _repository = ref.watch(eventRepositoryProvider);
    return const EventDetailState();
  }
}
