import '../data_sources/inventory_remote_data_source.dart';
import '../models/inventory_model.dart';
import '../../domain/entities/inventory_entity.dart';

class InventoryRepository {
  final InventoryRemoteDataSource _remoteDataSource;

  InventoryRepository({
    required InventoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  Future<List<InventoryItemEntity>> getInventories({String? type, bool? lowStock}) async {
    try {
      final data = await _remoteDataSource.getInventories(type: type, lowStock: lowStock);
      return data
          .map((json) => InventoryItemModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryItemEntity> getInventoryById(String id) async {
    try {
      final data = await _remoteDataSource.getInventoryById(id);
      return InventoryItemModel.fromJson(data).toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryItemEntity> createInventory(Map<String, dynamic> data) async {
    try {
      final createdData = await _remoteDataSource.createInventory(data);
      return InventoryItemModel.fromJson(createdData).toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryItemEntity> updateInventory(String id, Map<String, dynamic> data) async {
    try {
      final updatedData = await _remoteDataSource.updateInventory(id, data);
      return InventoryItemModel.fromJson(updatedData).toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteInventory(String id) async {
    try {
      await _remoteDataSource.deleteInventory(id);
    } catch (e) {
      rethrow;
    }
  }
}
