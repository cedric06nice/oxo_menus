import 'package:oxo_menus/domain/entities/connectivity_status.dart';

abstract class ConnectivityRepository {
  Stream<ConnectivityStatus> watchConnectivity();
  Future<ConnectivityStatus> checkConnectivity();
}
