import 'package:eventosapp/features/search/data/data_sources/search_remote_data_source.dart';

class SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;

  SearchRepository({required SearchRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<Map<String, dynamic>> search(String query) async {
    return _remoteDataSource.search(query);
  }
}
