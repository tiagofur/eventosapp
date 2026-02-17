import 'package:eventosapp/config/api_config.dart';
import 'package:eventosapp/core/api/api_client.dart';
import '../models/inventory_model.dart';

class InventoryRemoteDataSource {
  final ApiClient _apiClient;

  InventoryRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<dynamic>> getInventories({String? type, bool? lowStock}) async {
    final queryParameters = <String, dynamic>{};
    if (type != null && type.isNotEmpty) {
      queryParameters['type'] = type;
    }
    if (lowStock != null) {
      queryParameters['low_stock'] = lowStock;
    }

    final response = await _apiClient.get(
      ApiConfig.inventory,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getInventoryById(String id) async {
    final response = await _apiClient.get('${ApiConfig.inventory}/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createInventory(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConfig.inventory, data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateInventory(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('${ApiConfig.inventory}/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteInventory(String id) async {
    await _apiClient.delete('${ApiConfig.inventory}/$id');
  }
}
