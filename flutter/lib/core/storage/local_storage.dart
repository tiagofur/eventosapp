import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const _eventsKey = 'events';
  static const _clientsKey = 'clients';
  static const _productsKey = 'products';
  static const _inventoryKey = 'inventory';
  static const _settingsKey = 'settings';
  static const _dashboardKey = 'dashboard';

  late final Box<dynamic> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('localStorage');
  }

  Future<void> put(String key, dynamic value) async {
    await _box.put(key, value);
  }

  T? get<T>(String key) {
    return _box.get(key) as T?;
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  Future<void> close() async {
    await _box.close();
  }

  Future<void> putEvents(List<dynamic> events) async {
    await put(_eventsKey, events);
  }

  List<dynamic>? getEvents() {
    return get<List<dynamic>>(_eventsKey);
  }

  Future<void> putClients(List<dynamic> clients) async {
    await put(_clientsKey, clients);
  }

  List<dynamic>? getClients() {
    return get<List<dynamic>>(_clientsKey);
  }

  Future<void> putProducts(List<dynamic> products) async {
    await put(_productsKey, products);
  }

  List<dynamic>? getProducts() {
    return get<List<dynamic>>(_productsKey);
  }

  Future<void> putInventory(List<dynamic> inventory) async {
    await put(_inventoryKey, inventory);
  }

  List<dynamic>? getInventory() {
    return get<List<dynamic>>(_inventoryKey);
  }

  Future<void> putSettings(Map<String, dynamic> settings) async {
    await put(_settingsKey, settings);
  }

  Map<String, dynamic>? getSettings() {
    return get<Map<String, dynamic>>(_settingsKey);
  }

  Future<void> putDashboardData(Map<String, dynamic> data) async {
    await put(_dashboardKey, data);
  }

  Map<String, dynamic>? getDashboardData() {
    return get<Map<String, dynamic>>(_dashboardKey);
  }
}
