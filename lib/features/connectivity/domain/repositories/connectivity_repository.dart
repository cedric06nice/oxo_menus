import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';

abstract class ConnectivityRepository {
  Stream<ConnectivityStatus> watchConnectivity();
  Future<ConnectivityStatus> checkConnectivity();
}
