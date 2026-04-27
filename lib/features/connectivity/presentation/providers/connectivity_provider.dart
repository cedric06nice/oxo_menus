import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

/// Streams real-time connectivity status changes
final connectivityProvider = StreamProvider<ConnectivityStatus>((ref) {
  final repo = ref.watch(connectivityRepositoryProvider);
  return repo.watchConnectivity();
});
