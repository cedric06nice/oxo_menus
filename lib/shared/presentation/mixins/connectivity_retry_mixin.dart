import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';

/// Listens for offline → online transitions and calls [onRetry].
///
/// Works with [ProviderContainer] for unit tests.
void listenForConnectivityRestore(
  ProviderContainer container, {
  required void Function() onRetry,
}) {
  container.listen<AsyncValue<ConnectivityStatus>>(connectivityProvider, (
    prev,
    next,
  ) {
    final wasOffline = prev?.value == ConnectivityStatus.offline;
    final isOnline = next.value == ConnectivityStatus.online;

    if (wasOffline && isOnline) {
      onRetry();
    }
  });
}

/// Listens for offline → online transitions using a [Ref] (for use in widgets).
void listenForConnectivityRestoreWithRef(
  Ref ref, {
  required void Function() onRetry,
}) {
  ref.listen<AsyncValue<ConnectivityStatus>>(connectivityProvider, (
    prev,
    next,
  ) {
    final wasOffline = prev?.value == ConnectivityStatus.offline;
    final isOnline = next.value == ConnectivityStatus.online;

    if (wasOffline && isOnline) {
      onRetry();
    }
  });
}
