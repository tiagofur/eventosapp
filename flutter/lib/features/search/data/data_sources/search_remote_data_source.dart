import 'package:eventosapp/config/api_config.dart';
import 'package:eventosapp/core/api/api_client.dart';

class SearchRemoteDataSource {
  final ApiClient _apiClient;

  SearchRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> search(String query) async {
    final response = await _apiClient.get(
      ApiConfig.search,
      queryParameters: {'q': query},
    );
    return response.data as Map<String, dynamic>;
  }
}
