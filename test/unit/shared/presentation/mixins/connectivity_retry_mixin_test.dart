import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/shared/presentation/mixins/connectivity_retry_mixin.dart';
import 'package:oxo_menus/features/connectivity/presentation/providers/connectivity_provider.dart';

void main() {
  group('ConnectivityRetryMixin', () {
    test('calls onRetry when transitioning from offline to online', () async {
      final connectivityController =
          StreamController<ConnectivityStatus>.broadcast();
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith(
            (_) => connectivityController.stream,
          ),
        ],
      );
      addTearDown(() {
        container.dispose();
        connectivityController.close();
      });

      int retryCount = 0;

      listenForConnectivityRestore(container, onRetry: () => retryCount++);

      // Go offline
      connectivityController.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(retryCount, 0);

      // Come back online
      connectivityController.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(retryCount, 1);
    });

    test('does not call onRetry on first online event', () async {
      final connectivityController =
          StreamController<ConnectivityStatus>.broadcast();
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith(
            (_) => connectivityController.stream,
          ),
        ],
      );
      addTearDown(() {
        container.dispose();
        connectivityController.close();
      });

      int retryCount = 0;

      listenForConnectivityRestore(container, onRetry: () => retryCount++);

      // First event is online — should not retry
      connectivityController.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(retryCount, 0);
    });
  });
}
