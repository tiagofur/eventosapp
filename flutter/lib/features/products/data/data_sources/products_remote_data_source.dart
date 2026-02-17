import 'package:eventosapp/config/api_config.dart';
import 'package:eventosapp/core/api/api_client.dart';

class ProductsRemoteDataSource {
  final ApiClient _apiClient;

  ProductsRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getProducts({
    String? search,
    String? category,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    if (category != null && category.isNotEmpty) {
      queryParameters['category'] = category;
    }
    if (status != null && status.isNotEmpty) {
      queryParameters['is_active'] = status == 'active';
    }

    final response = await _apiClient.get(
      ApiConfig.products,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    return {
      'products': response.data as List<dynamic>,
    };
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    final response = await _apiClient.get('${ApiConfig.products}/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConfig.products, data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('${ApiConfig.products}/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteProduct(String id) async {
    await _apiClient.delete('${ApiConfig.products}/$id');
  }

}
