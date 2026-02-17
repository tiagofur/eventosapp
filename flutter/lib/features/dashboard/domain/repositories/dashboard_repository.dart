import 'package:eventosapp/features/dashboard/data/data_sources/dashboard_remote_data_source.dart';
import 'package:eventosapp/features/dashboard/data/models/dashboard_metrics_model.dart';

class DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepository({
    required DashboardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  Future<DashboardMetricsModel> getDashboardMetrics() async {
    try {
      final data = await _remoteDataSource.getDashboardMetrics();
      return DashboardMetricsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
