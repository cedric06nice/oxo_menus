import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockConnectivityRepository extends Mock
    implements ConnectivityRepository {}

void main() {
  late MockConnectivityRepository mockRepo;

  setUp(() {
    mockRepo = MockConnectivityRepository();
  });

  group('connectivityProvider', () {
    test('emits connectivity status from repository stream', () async {
      final controller = StreamController<ConnectivityStatus>.broadcast();
      when(
        () => mockRepo.watchConnectivity(),
      ).thenAnswer((_) => controller.stream);

      final container = ProviderContainer(
        overrides: [connectivityRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final values = <ConnectivityStatus?>[];
      container.listen(connectivityProvider, (_, next) {
        values.add(next.value);
      });

      controller.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(values, contains(ConnectivityStatus.online));

      controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(values, contains(ConnectivityStatus.offline));

      await controller.close();
    });

    test('is a StreamProvider of ConnectivityStatus', () {
      expect(connectivityProvider, isA<StreamProvider<ConnectivityStatus>>());
    });
  });
}
