import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fake_async/fake_async.dart';
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
    repository = ConnectivityRepositoryImpl(
      connectivity: mockConnectivity,
      dnsProbe: () async => true,
    );
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

      test('returns offline when wifi available but DNS probe fails', () async {
        final repo = ConnectivityRepositoryImpl(
          connectivity: mockConnectivity,
          dnsProbe: () async => false,
        );
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);

        final result = await repo.checkConnectivity();

        expect(result, ConnectivityStatus.offline);
      });

      test(
        'returns online when wifi available and DNS probe succeeds',
        () async {
          final repo = ConnectivityRepositoryImpl(
            connectivity: mockConnectivity,
            dnsProbe: () async => true,
          );
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.wifi]);

          final result = await repo.checkConnectivity();

          expect(result, ConnectivityStatus.online);
        },
      );

      test(
        'skips DNS probe when no network interface (returns offline immediately)',
        () async {
          var dnsProbeCallCount = 0;
          final repo = ConnectivityRepositoryImpl(
            connectivity: mockConnectivity,
            dnsProbe: () async {
              dnsProbeCallCount++;
              return true;
            },
          );
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.none]);

          final result = await repo.checkConnectivity();

          expect(result, ConnectivityStatus.offline);
          expect(dnsProbeCallCount, 0);
        },
      );
    });

    group('DNS probe retries', () {
      test(
        'retries DNS probe up to 3 times before declaring offline',
        () async {
          var callCount = 0;
          final repo = ConnectivityRepositoryImpl(
            connectivity: mockConnectivity,
            dnsProbe: () async {
              callCount++;
              return false;
            },
          );
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.wifi]);

          final result = await repo.checkConnectivity();

          expect(result, ConnectivityStatus.offline);
          expect(callCount, 3); // 1 initial + 2 retries
        },
      );

      test('succeeds on second attempt', () async {
        var callCount = 0;
        final repo = ConnectivityRepositoryImpl(
          connectivity: mockConnectivity,
          dnsProbe: () async {
            callCount++;
            return callCount >= 2;
          },
        );
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);

        final result = await repo.checkConnectivity();

        expect(result, ConnectivityStatus.online);
        expect(callCount, 2);
      });
    });

    group('watchConnectivity', () {
      test('emits online when connectivity changes to wifi', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);
        final controller = StreamController<List<ConnectivityResult>>();
        when(
          () => mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => controller.stream);

        final results = <ConnectivityStatus>[];
        final sub = repository.watchConnectivity().listen(results.add);
        await Future<void>.delayed(Duration.zero);

        expect(results.first, ConnectivityStatus.online);

        await sub.cancel();
        await controller.close();
      });

      test('emits offline when connectivity changes to none', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);
        final controller = StreamController<List<ConnectivityResult>>();
        when(
          () => mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => controller.stream);

        final results = <ConnectivityStatus>[];
        final sub = repository.watchConnectivity().listen(results.add);
        await Future<void>.delayed(Duration.zero);

        expect(results.first, ConnectivityStatus.offline);

        await sub.cancel();
        await controller.close();
      });

      test('applies distinct to avoid duplicate emissions', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);
        final controller = StreamController<List<ConnectivityResult>>();
        when(
          () => mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => controller.stream);

        final results = <ConnectivityStatus>[];
        final subscription = repository.watchConnectivity().listen(results.add);

        // Wait for initial emission from checkConnectivity
        await Future<void>.delayed(Duration.zero);

        controller.add([ConnectivityResult.wifi]); // same as initial, deduped
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

      test(
        'emits initial state from checkConnectivity before change events',
        () async {
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.none]);
          final controller = StreamController<List<ConnectivityResult>>();
          when(
            () => mockConnectivity.onConnectivityChanged,
          ).thenAnswer((_) => controller.stream);

          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);

          // Wait for initial emission
          await Future<void>.delayed(Duration.zero);

          // Initial state should be offline (from checkConnectivity)
          expect(results, [ConnectivityStatus.offline]);

          // Then a change event
          controller.add([ConnectivityResult.wifi]);
          await Future<void>.delayed(Duration.zero);

          expect(results, [
            ConnectivityStatus.offline,
            ConnectivityStatus.online,
          ]);

          await sub.cancel();
          await controller.close();
        },
      );

      test(
        'deduplicates initial state if same as first change event',
        () async {
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.wifi]);
          final controller = StreamController<List<ConnectivityResult>>();
          when(
            () => mockConnectivity.onConnectivityChanged,
          ).thenAnswer((_) => controller.stream);

          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);

          await Future<void>.delayed(Duration.zero);

          // Emit same status — should be deduped
          controller.add([ConnectivityResult.wifi]);
          await Future<void>.delayed(Duration.zero);

          expect(results, [ConnectivityStatus.online]); // only one emission

          await sub.cancel();
          await controller.close();
        },
      );

      test(
        'emits online after offline when connectivity is restored',
        () async {
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.wifi]);
          final controller = StreamController<List<ConnectivityResult>>();
          when(
            () => mockConnectivity.onConnectivityChanged,
          ).thenAnswer((_) => controller.stream);

          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);
          await Future<void>.delayed(Duration.zero);

          // Go offline
          controller.add([ConnectivityResult.none]);
          await Future<void>.delayed(Duration.zero);

          // Come back online
          controller.add([ConnectivityResult.wifi]);
          await Future<void>.delayed(Duration.zero);

          expect(results, [
            ConnectivityStatus.online, // initial
            ConnectivityStatus.offline, // disconnected
            ConnectivityStatus.online, // reconnected
          ]);

          await sub.cancel();
          await controller.close();
        },
      );

      test(
        'falls back to online if initial checkConnectivity throws',
        () async {
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenThrow(Exception('fail'));
          final controller = StreamController<List<ConnectivityResult>>();
          when(
            () => mockConnectivity.onConnectivityChanged,
          ).thenAnswer((_) => controller.stream);

          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);
          await Future<void>.delayed(Duration.zero);

          expect(results, [ConnectivityStatus.online]);

          await sub.cancel();
          await controller.close();
        },
      );

      test('runs DNS probe when connectivity changes to connected', () async {
        var dnsCallCount = 0;
        final repo = ConnectivityRepositoryImpl(
          connectivity: mockConnectivity,
          dnsProbe: () async {
            dnsCallCount++;
            return true;
          },
        );
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);
        final controller = StreamController<List<ConnectivityResult>>();
        when(
          () => mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => controller.stream);

        final results = <ConnectivityStatus>[];
        final sub = repo.watchConnectivity().listen(results.add);
        await Future<void>.delayed(Duration.zero);

        // No DNS probe for initial offline (no network interface)
        expect(dnsCallCount, 0);

        // Change to wifi → should trigger DNS probe
        controller.add([ConnectivityResult.wifi]);
        await Future<void>.delayed(Duration.zero);

        expect(dnsCallCount, greaterThan(0));
        expect(results.last, ConnectivityStatus.online);

        await sub.cancel();
        await controller.close();
      });

      test('emits offline on connected event when DNS probe fails', () async {
        final repo = ConnectivityRepositoryImpl(
          connectivity: mockConnectivity,
          dnsProbe: () async => false,
        );
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);
        final controller = StreamController<List<ConnectivityResult>>();
        when(
          () => mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => controller.stream);

        final results = <ConnectivityStatus>[];
        final sub = repo.watchConnectivity().listen(results.add);
        await Future<void>.delayed(Duration.zero);

        // Start offline
        expect(results, [ConnectivityStatus.offline]);

        // Change to wifi but DNS fails → still offline (deduped by distinct)
        controller.add([ConnectivityResult.wifi]);
        await Future<void>.delayed(Duration.zero);

        // Should remain offline (distinct deduplicates)
        expect(results, [ConnectivityStatus.offline]);

        await sub.cancel();
        await controller.close();
      });

      test('skips DNS probe when connectivity changes to none', () async {
        var dnsCallCount = 0;
        final repo = ConnectivityRepositoryImpl(
          connectivity: mockConnectivity,
          dnsProbe: () async {
            dnsCallCount++;
            return true;
          },
        );
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);
        final controller = StreamController<List<ConnectivityResult>>();
        when(
          () => mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => controller.stream);

        final results = <ConnectivityStatus>[];
        final sub = repo.watchConnectivity().listen(results.add);
        await Future<void>.delayed(Duration.zero);

        final dnsCountAfterInit = dnsCallCount;

        // Change to none → should NOT trigger DNS probe
        controller.add([ConnectivityResult.none]);
        await Future<void>.delayed(Duration.zero);

        expect(dnsCallCount, dnsCountAfterInit);
        expect(results.last, ConnectivityStatus.offline);

        await sub.cancel();
        await controller.close();
      });

      group('periodic probing', () {
        test('cancels periodic probe on stream cancel', () async {
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.wifi]);
          final controller = StreamController<List<ConnectivityResult>>();
          when(
            () => mockConnectivity.onConnectivityChanged,
          ).thenAnswer((_) => controller.stream);

          final sub = repository.watchConnectivity().listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Cancelling should not throw or leak timers
          await sub.cancel();
          await controller.close();
        });
      });

      group('recovery probing', () {
        test(
          'emits online after recovery probe succeeds when DNS was failing',
          () {
            fakeAsync((async) {
              var dnsSucceeds = false;
              final repo = ConnectivityRepositoryImpl(
                connectivity: mockConnectivity,
                dnsProbe: () async => dnsSucceeds,
              );
              when(
                () => mockConnectivity.checkConnectivity(),
              ).thenAnswer((_) async => [ConnectivityResult.none]);
              final controller = StreamController<List<ConnectivityResult>>();
              when(
                () => mockConnectivity.onConnectivityChanged,
              ).thenAnswer((_) => controller.stream);

              final results = <ConnectivityStatus>[];
              final sub = repo.watchConnectivity().listen(results.add);
              async.flushMicrotasks();

              // Initial: offline (no interface)
              expect(results, [ConnectivityStatus.offline]);

              // WiFi connects but DNS fails → offline, recovery probe starts
              controller.add([ConnectivityResult.wifi]);
              async.flushMicrotasks();
              expect(results, [ConnectivityStatus.offline]);

              // DNS starts succeeding, advance 5s for recovery probe
              dnsSucceeds = true;
              async.elapse(const Duration(seconds: 5));

              expect(results.last, ConnectivityStatus.online);

              sub.cancel();
              controller.close();
            });
          },
        );

        test(
          'replaces previous recovery probes with new ones when interface is lost',
          () {
            fakeAsync((async) {
              var dnsSucceeds = false;
              final repo = ConnectivityRepositoryImpl(
                connectivity: mockConnectivity,
                dnsProbe: () async => dnsSucceeds,
              );
              when(
                () => mockConnectivity.checkConnectivity(),
              ).thenAnswer((_) async => [ConnectivityResult.none]);
              final controller = StreamController<List<ConnectivityResult>>();
              when(
                () => mockConnectivity.onConnectivityChanged,
              ).thenAnswer((_) => controller.stream);

              final results = <ConnectivityStatus>[];
              final sub = repo.watchConnectivity().listen(results.add);
              async.flushMicrotasks();

              // WiFi connects but DNS fails → recovery starts
              controller.add([ConnectivityResult.wifi]);
              async.flushMicrotasks();
              // Interface lost → previous recovery replaced by new recovery
              controller.add([ConnectivityResult.none]);
              async.flushMicrotasks();

              // DNS starts succeeding — new recovery probes should detect it
              dnsSucceeds = true;
              async.elapse(const Duration(seconds: 5));

              expect(
                results.last,
                ConnectivityStatus.online,
                reason:
                    'new recovery probes should fire after no-interface offline and detect recovery',
              );

              sub.cancel();
              controller.close();
            });
          },
        );

        test('recovery probe switches to periodic probe on success', () {
          fakeAsync((async) {
            var dnsSucceeds = false;
            var dnsCallCount = 0;
            final repo = ConnectivityRepositoryImpl(
              connectivity: mockConnectivity,
              dnsProbe: () async {
                dnsCallCount++;
                return dnsSucceeds;
              },
            );
            when(
              () => mockConnectivity.checkConnectivity(),
            ).thenAnswer((_) async => [ConnectivityResult.none]);
            final controller = StreamController<List<ConnectivityResult>>();
            when(
              () => mockConnectivity.onConnectivityChanged,
            ).thenAnswer((_) => controller.stream);

            final results = <ConnectivityStatus>[];
            final sub = repo.watchConnectivity().listen(results.add);
            async.flushMicrotasks();

            // WiFi connects, DNS fails → recovery mode
            controller.add([ConnectivityResult.wifi]);
            async.flushMicrotasks();

            // DNS succeeds on recovery probe
            dnsSucceeds = true;
            async.elapse(const Duration(seconds: 5));
            expect(results.last, ConnectivityStatus.online);

            final dnsCountAfterRecovery = dnsCallCount;

            // Should now be in 30s periodic mode, not 5s
            // Advance 10s — no new probe (5s recovery would have fired)
            async.elapse(const Duration(seconds: 10));
            expect(dnsCallCount, dnsCountAfterRecovery);

            // Advance to 30s mark — periodic probe fires
            async.elapse(const Duration(seconds: 20));
            expect(dnsCallCount, greaterThan(dnsCountAfterRecovery));

            sub.cancel();
            controller.close();
          });
        });
      });

      group('initial offline with network interface', () {
        test(
          'starts recovery probe when initial state is offline with network interface',
          () {
            fakeAsync((async) {
              var dnsSucceeds = false;
              final repo = ConnectivityRepositoryImpl(
                connectivity: mockConnectivity,
                dnsProbe: () async => dnsSucceeds,
              );
              // WiFi present but DNS fails (captive portal scenario)
              when(
                () => mockConnectivity.checkConnectivity(),
              ).thenAnswer((_) async => [ConnectivityResult.wifi]);
              final controller = StreamController<List<ConnectivityResult>>();
              when(
                () => mockConnectivity.onConnectivityChanged,
              ).thenAnswer((_) => controller.stream);

              final results = <ConnectivityStatus>[];
              final sub = repo.watchConnectivity().listen(results.add);
              async.flushMicrotasks();

              // Initial: offline (WiFi present but DNS fails)
              expect(results, [ConnectivityStatus.offline]);

              // DNS recovers, advance 5s for recovery probe to fire
              dnsSucceeds = true;
              async.elapse(const Duration(seconds: 5));

              expect(
                results.last,
                ConnectivityStatus.online,
                reason:
                    'recovery probe should detect DNS recovery and emit online',
              );

              sub.cancel();
              controller.close();
            });
          },
        );
      });

      group('periodic probe failure recovery', () {
        test('periodic probe switches to recovery mode when DNS fails', () {
          fakeAsync((async) {
            var dnsSucceeds = true;
            var dnsCallCount = 0;
            final repo = ConnectivityRepositoryImpl(
              connectivity: mockConnectivity,
              dnsProbe: () async {
                dnsCallCount++;
                return dnsSucceeds;
              },
            );
            when(
              () => mockConnectivity.checkConnectivity(),
            ).thenAnswer((_) async => [ConnectivityResult.wifi]);
            final controller = StreamController<List<ConnectivityResult>>();
            when(
              () => mockConnectivity.onConnectivityChanged,
            ).thenAnswer((_) => controller.stream);

            final results = <ConnectivityStatus>[];
            final sub = repo.watchConnectivity().listen(results.add);
            async.flushMicrotasks();

            // Initial: online, periodic probe starts
            expect(results.last, ConnectivityStatus.online);
            // DNS starts failing
            dnsSucceeds = false;

            // Advance 30s — periodic probe fires, detects failure
            async.elapse(const Duration(seconds: 30));
            expect(results.last, ConnectivityStatus.offline);
            final dnsCountAfterPeriodicFail = dnsCallCount;

            // Now it should be in recovery mode (5s interval), not dead
            // DNS starts succeeding again
            dnsSucceeds = true;
            async.elapse(const Duration(seconds: 5));
            expect(
              dnsCallCount,
              greaterThan(dnsCountAfterPeriodicFail),
              reason: 'recovery probe should fire at 5s',
            );
            expect(results.last, ConnectivityStatus.online);

            sub.cancel();
            controller.close();
          });
        });
      });

      group('connectivity change probe guard', () {
        test(
          'stops existing probes and starts fresh DNS check on connectivity change',
          () {
            fakeAsync((async) {
              var dnsCallCount = 0;
              var dnsCompleter = Completer<bool>();
              final repo = ConnectivityRepositoryImpl(
                connectivity: mockConnectivity,
                dnsProbe: () {
                  dnsCallCount++;
                  return dnsCompleter.future;
                },
              );
              when(
                () => mockConnectivity.checkConnectivity(),
              ).thenAnswer((_) async => [ConnectivityResult.wifi]);
              final controller = StreamController<List<ConnectivityResult>>();
              when(
                () => mockConnectivity.onConnectivityChanged,
              ).thenAnswer((_) => controller.stream);

              final results = <ConnectivityStatus>[];
              final sub = repo.watchConnectivity().listen(results.add);

              // Complete initial checkConnectivity DNS probes
              dnsCompleter.complete(true);
              async.flushMicrotasks();
              expect(results, [ConnectivityStatus.online]);

              // Now a periodic probe is running at 30s intervals.
              // Trigger periodic probe at 30s with a slow completer
              dnsCompleter = Completer<bool>();
              async.elapse(const Duration(seconds: 30));
              final dnsCountAfterPeriodicStart = dnsCallCount;
              expect(
                dnsCountAfterPeriodicStart,
                greaterThan(1),
                reason: 'periodic probe should have started a DNS check',
              );

              // While periodic probe is in-flight, trigger a connectivity change
              // This should stop probes, invalidate in-flight probe, and start fresh DNS
              dnsCompleter = Completer<bool>();
              controller.add([ConnectivityResult.mobile]);
              async.flushMicrotasks();

              expect(
                dnsCallCount,
                greaterThan(dnsCountAfterPeriodicStart),
                reason:
                    'connectivity change should start fresh DNS check, not be blocked by stale probe',
              );

              // Complete the fresh probe
              dnsCompleter.complete(true);
              async.flushMicrotasks();

              expect(results.last, ConnectivityStatus.online);

              sub.cancel();
              controller.close();
            });
          },
        );
      });

      group('stale probe invalidation', () {
        test('connectivity change proceeds even when stale probe is in-flight', () {
          fakeAsync((async) {
            var dnsCompleter = Completer<bool>();
            final repo = ConnectivityRepositoryImpl(
              connectivity: mockConnectivity,
              dnsProbe: () => dnsCompleter.future,
            );
            when(
              () => mockConnectivity.checkConnectivity(),
            ).thenAnswer((_) async => [ConnectivityResult.wifi]);
            final controller = StreamController<List<ConnectivityResult>>();
            when(
              () => mockConnectivity.onConnectivityChanged,
            ).thenAnswer((_) => controller.stream);

            final results = <ConnectivityStatus>[];
            final sub = repo.watchConnectivity().listen(results.add);

            // Complete initial check → online
            dnsCompleter.complete(true);
            async.flushMicrotasks();
            expect(results, [ConnectivityStatus.online]);

            // Periodic probe fires at 30s with a slow completer (stays in-flight)
            dnsCompleter = Completer<bool>();
            async.elapse(const Duration(seconds: 30));

            // WiFi OFF while probe is in-flight
            controller.add([ConnectivityResult.none]);
            async.flushMicrotasks();
            expect(results.last, ConnectivityStatus.offline);

            // WiFi ON — should start fresh DNS check despite stale probe
            dnsCompleter = Completer<bool>();
            controller.add([ConnectivityResult.wifi]);
            async.flushMicrotasks();

            // Complete the fresh DNS check
            dnsCompleter.complete(true);
            async.flushMicrotasks();

            expect(
              results.last,
              ConnectivityStatus.online,
              reason:
                  'handler should proceed with fresh DNS check, not be blocked by stale isProbing flag',
            );

            sub.cancel();
            controller.close();
          });
        });

        test('stale in-flight probe result is discarded after epoch change', () {
          fakeAsync((async) {
            var dnsCompleter = Completer<bool>();
            final repo = ConnectivityRepositoryImpl(
              connectivity: mockConnectivity,
              dnsProbe: () => dnsCompleter.future,
            );
            when(
              () => mockConnectivity.checkConnectivity(),
            ).thenAnswer((_) async => [ConnectivityResult.wifi]);
            final controller = StreamController<List<ConnectivityResult>>();
            when(
              () => mockConnectivity.onConnectivityChanged,
            ).thenAnswer((_) => controller.stream);

            final results = <ConnectivityStatus>[];
            final sub = repo.watchConnectivity().listen(results.add);

            // Complete initial check → online
            dnsCompleter.complete(true);
            async.flushMicrotasks();
            expect(results, [ConnectivityStatus.online]);

            // Periodic probe fires at 30s with a slow completer
            final staleCompleter = Completer<bool>();
            dnsCompleter = staleCompleter;
            async.elapse(const Duration(seconds: 30));

            // WiFi OFF while periodic probe in-flight
            controller.add([ConnectivityResult.none]);
            async.flushMicrotasks();
            expect(results.last, ConnectivityStatus.offline);

            // WiFi ON → fresh DNS check → online
            dnsCompleter = Completer<bool>();
            controller.add([ConnectivityResult.wifi]);
            async.flushMicrotasks();
            dnsCompleter.complete(true);
            async.flushMicrotasks();
            expect(results.last, ConnectivityStatus.online);

            // Now complete the STALE probe with false
            staleCompleter.complete(false);
            async.flushMicrotasks();

            // Should NOT emit offline from stale result
            expect(
              results.last,
              ConnectivityStatus.online,
              reason:
                  'stale probe result should be discarded, not emit outdated offline status',
            );

            sub.cancel();
            controller.close();
          });
        });
      });

      group('recovery probe on no-interface offline', () {
        test('starts recovery probes when connectivity changes to none', () {
          fakeAsync((async) {
            var dnsSucceeds = false;
            final repo = ConnectivityRepositoryImpl(
              connectivity: mockConnectivity,
              dnsProbe: () async => dnsSucceeds,
            );
            when(
              () => mockConnectivity.checkConnectivity(),
            ).thenAnswer((_) async => [ConnectivityResult.wifi]);
            final controller = StreamController<List<ConnectivityResult>>();
            when(
              () => mockConnectivity.onConnectivityChanged,
            ).thenAnswer((_) => controller.stream);

            final results = <ConnectivityStatus>[];
            final sub = repo.watchConnectivity().listen(results.add);
            async.flushMicrotasks();

            // Initial: offline (WiFi but DNS fails)
            expect(results, [ConnectivityStatus.offline]);

            // WiFi OFF → no interface → offline (deduped by distinct)
            controller.add([ConnectivityResult.none]);
            async.flushMicrotasks();

            // DNS starts succeeding, advance 5s for recovery probe
            dnsSucceeds = true;
            async.elapse(const Duration(seconds: 5));

            expect(
              results.last,
              ConnectivityStatus.online,
              reason:
                  'recovery probe should fire after no-interface offline and detect DNS recovery',
            );

            sub.cancel();
            controller.close();
          });
        });
      });

      group('probing overlap guard', () {
        test(
          'skips recovery probe tick when previous probe is still in progress',
          () {
            fakeAsync((async) {
              final probeCalls = <int>[];
              var probeCompleter = Completer<bool>();
              final repo = ConnectivityRepositoryImpl(
                connectivity: mockConnectivity,
                dnsProbe: () {
                  probeCalls.add(probeCalls.length);
                  return probeCompleter.future;
                },
              );
              when(
                () => mockConnectivity.checkConnectivity(),
              ).thenAnswer((_) async => [ConnectivityResult.none]);
              final controller = StreamController<List<ConnectivityResult>>();
              when(
                () => mockConnectivity.onConnectivityChanged,
              ).thenAnswer((_) => controller.stream);

              final results = <ConnectivityStatus>[];
              final sub = repo.watchConnectivity().listen(results.add);
              async.flushMicrotasks();

              // WiFi connects, DNS fails → recovery mode starts
              probeCompleter = Completer<bool>();
              controller.add([ConnectivityResult.wifi]);
              async.flushMicrotasks();
              // First DNS probe started (from change event), complete it as fail
              probeCompleter.complete(false);
              async.flushMicrotasks();
              // Second retry
              probeCompleter = Completer<bool>();
              probeCompleter.complete(false);
              async.flushMicrotasks();
              // Third retry
              probeCompleter = Completer<bool>();
              probeCompleter.complete(false);
              async.flushMicrotasks();

              // Now in recovery mode. Clear probe call tracking.
              probeCalls.clear();

              // First recovery tick at 5s — start a slow probe
              probeCompleter = Completer<bool>();
              async.elapse(const Duration(seconds: 5));
              expect(probeCalls.length, 1, reason: 'first recovery tick fires');

              // Second recovery tick at 10s — probe still running
              async.elapse(const Duration(seconds: 5));
              expect(
                probeCalls.length,
                1,
                reason: 'second tick skipped because first probe still running',
              );

              // Complete the slow probe
              probeCompleter.complete(true);
              async.flushMicrotasks();

              sub.cancel();
              controller.close();
            });
          },
        );
      });
    });
  });
}
