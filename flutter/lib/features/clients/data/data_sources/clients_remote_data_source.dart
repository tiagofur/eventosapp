import 'package:eventosapp/config/api_config.dart';
import 'package:eventosapp/core/api/api_client.dart';

class ClientsRemoteDataSource {
  final ApiClient _apiClient;

  ClientsRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<dynamic>> getClients({String? search}) async {
    final queryParameters = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    final response = await _apiClient.get(
      ApiConfig.clients,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getClientById(String id) async {
    final response = await _apiClient.get('${ApiConfig.clients}/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createClient(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConfig.clients, data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateClient(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('${ApiConfig.clients}/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteClient(String id) async {
    await _apiClient.delete('${ApiConfig.clients}/$id');
  }

  Future<Map<String, dynamic>> getClientPayments(String clientId) async {
    final response = await _apiClient.get('${ApiConfig.clients}/$clientId/payments');
    return response.data as Map<String, dynamic>;
  }
}
