import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/data/repositories/connectivity_repository_impl.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/repositories/connectivity_repository.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityRepositoryImpl repository;

  setUp(() {
    mockConnectivity = MockConnectivity();
    repository = ConnectivityRepositoryImpl(connectivity: mockConnectivity);
  });

  group('ConnectivityRepositoryImpl', () {
    test('implements ConnectivityRepository', () {
      expect(repository, isA<ConnectivityRepository>());
    });

    group('checkConnectivity', () {
      test('returns online when wifi is available', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);

        final result = await repository.checkConnectivity();

        expect(result, ConnectivityStatus.online);
      });

      test('returns online when mobile is available', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.mobile]);

        final result = await repository.checkConnectivity();

        expect(result, ConnectivityStatus.online);
      });

      test('returns online when ethernet is available', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.ethernet]);

        final result = await repository.checkConnectivity();

        expect(result, ConnectivityStatus.online);
      });

      test('returns offline when none', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);

        final result = await repository.checkConnectivity();

        expect(result, ConnectivityStatus.offline);
      });

      test('returns offline when results list is empty', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => []);

        final result = await repository.checkConnectivity();

        expect(result, ConnectivityStatus.offline);
      });
    });

    group('watchConnectivity', () {
      test('emits online when connectivity changes to wifi', () async {
        final controller = StreamController<List<ConnectivityResult>>();
        when(
          () => mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => controller.stream);

        final stream = repository.watchConnectivity();
        final future = stream.first;

        controller.add([ConnectivityResult.wifi]);

        expect(await future, ConnectivityStatus.online);

        await controller.close();
      });

      test('emits offline when connectivity changes to none', () async {
        final controller = StreamController<List<ConnectivityResult>>();
        when(
          () => mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => controller.stream);

        final stream = repository.watchConnectivity();
        final future = stream.first;

        controller.add([ConnectivityResult.none]);

        expect(await future, ConnectivityStatus.offline);

        await controller.close();
      });

      test('applies distinct to avoid duplicate emissions', () async {
        final controller = StreamController<List<ConnectivityResult>>();
        when(
          () => mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => controller.stream);

        final results = <ConnectivityStatus>[];
        final subscription = repository.watchConnectivity().listen(results.add);

        controller.add([ConnectivityResult.wifi]);
        controller.add([
          ConnectivityResult.mobile,
        ]); // still online, should be deduped
        controller.add([ConnectivityResult.none]);

        // Give time for stream events to propagate
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(results, [
          ConnectivityStatus.online,
          ConnectivityStatus.offline,
        ]);

        await subscription.cancel();
        await controller.close();
      });
    });
  });
}
