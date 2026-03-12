import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/repositories/connectivity_repository.dart';

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  final Connectivity connectivity;

  const ConnectivityRepositoryImpl({required this.connectivity});

  @override
  Stream<ConnectivityStatus> watchConnectivity() {
    return connectivity.onConnectivityChanged.map(_mapResults).distinct();
  }

  @override
  Future<ConnectivityStatus> checkConnectivity() async {
    final results = await connectivity.checkConnectivity();
    return _mapResults(results);
  }

  ConnectivityStatus _mapResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }
}
