import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/repositories/connectivity_repository_impl.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/repositories/connectivity_repository.dart';

// ---------------------------------------------------------------------------
// Manual fake for Connectivity (connectivity_plus)
// ---------------------------------------------------------------------------

/// Fake implementation of [Connectivity] that avoids real platform channels.
///
/// Tests drive connectivity change events by calling [emitChange] or by
/// directly using the [changeController] stream.
class FakeConnectivity implements Connectivity {
  final StreamController<List<ConnectivityResult>> changeController =
      StreamController<List<ConnectivityResult>>.broadcast();

  List<ConnectivityResult> _nextResult = [ConnectivityResult.wifi];
  Object? _nextError;

  /// Configures the result returned by [checkConnectivity].
  void setCheckResult(List<ConnectivityResult> result) {
    _nextResult = result;
    _nextError = null;
  }

  /// Configures [checkConnectivity] to throw [error] on the next call.
  void setCheckError(Object error) {
    _nextError = error;
    _nextResult = [];
  }

  /// Pushes a connectivity-change event to [onConnectivityChanged].
  void emitChange(List<ConnectivityResult> results) {
    changeController.add(results);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    if (_nextError != null) throw _nextError!;
    return _nextResult;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      changeController.stream;
}

// ---------------------------------------------------------------------------
// Builder shorthand
// ---------------------------------------------------------------------------

/// Creates a [ConnectivityRepositoryImpl] with a synchronous fake probe and
/// the given [fake] connectivity source.
ConnectivityRepositoryImpl _repo(
  FakeConnectivity fake, {
  Future<bool> Function()? probe,
}) {
  return ConnectivityRepositoryImpl(
    connectivity: fake,
    dnsProbe: probe ?? () async => true,
  );
}

void main() {
  late FakeConnectivity fakeConnectivity;

  setUp(() {
    fakeConnectivity = FakeConnectivity();
  });

  tearDown(() async {
    await fakeConnectivity.changeController.close();
  });

  group('ConnectivityRepositoryImpl', () {
    // ========================================================================
    // implements ConnectivityRepository
    // ========================================================================

    test('should implement ConnectivityRepository', () {
      final repository = _repo(fakeConnectivity);
      expect(repository, isA<ConnectivityRepository>());
    });

    // ========================================================================
    // checkConnectivity
    // ========================================================================

    group('checkConnectivity', () {
      test(
        'should return online when wifi interface is available and DNS probe succeeds',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(fakeConnectivity, probe: () async => true);

          // Act
          final status = await repository.checkConnectivity();

          // Assert
          expect(status, equals(ConnectivityStatus.online));
        },
      );

      test(
        'should return online when mobile interface is available and DNS probe succeeds',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([ConnectivityResult.mobile]);
          final repository = _repo(fakeConnectivity, probe: () async => true);

          // Act
          final status = await repository.checkConnectivity();

          // Assert
          expect(status, equals(ConnectivityStatus.online));
        },
      );

      test(
        'should return online when ethernet interface is available and DNS probe succeeds',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([ConnectivityResult.ethernet]);
          final repository = _repo(fakeConnectivity, probe: () async => true);

          // Act
          final status = await repository.checkConnectivity();

          // Assert
          expect(status, equals(ConnectivityStatus.online));
        },
      );

      test(
        'should return offline immediately when results list contains only none',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([ConnectivityResult.none]);
          final repository = _repo(fakeConnectivity);

          // Act
          final status = await repository.checkConnectivity();

          // Assert
          expect(status, equals(ConnectivityStatus.offline));
        },
      );

      test(
        'should return offline immediately when results list is empty',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([]);
          final repository = _repo(fakeConnectivity);

          // Act
          final status = await repository.checkConnectivity();

          // Assert
          expect(status, equals(ConnectivityStatus.offline));
        },
      );

      test(
        'should return offline when interface is available but DNS probe fails',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(fakeConnectivity, probe: () async => false);

          // Act
          final status = await repository.checkConnectivity();

          // Assert
          expect(status, equals(ConnectivityStatus.offline));
        },
      );

      test(
        'should not invoke DNS probe when no network interface is available',
        () async {
          // Arrange
          var probeCallCount = 0;
          fakeConnectivity.setCheckResult([ConnectivityResult.none]);
          final repository = _repo(
            fakeConnectivity,
            probe: () async {
              probeCallCount++;
              return true;
            },
          );

          // Act
          await repository.checkConnectivity();

          // Assert — probe is short-circuited by the interface check
          expect(probeCallCount, equals(0));
        },
      );
    });

    // ========================================================================
    // DNS probe retry behaviour
    // ========================================================================

    group('DNS probe retry behaviour', () {
      test(
        'should attempt the DNS probe 3 times before declaring offline (1 initial + 2 retries)',
        () async {
          // Arrange
          var callCount = 0;
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(
            fakeConnectivity,
            probe: () async {
              callCount++;
              return false;
            },
          );

          // Act
          final status = await repository.checkConnectivity();

          // Assert
          expect(status, equals(ConnectivityStatus.offline));
          expect(callCount, equals(3));
        },
      );

      test(
        'should return online and stop retrying as soon as the first probe succeeds',
        () async {
          // Arrange — succeeds on the first attempt
          var callCount = 0;
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(
            fakeConnectivity,
            probe: () async {
              callCount++;
              return true;
            },
          );

          // Act
          final status = await repository.checkConnectivity();

          // Assert
          expect(status, equals(ConnectivityStatus.online));
          expect(callCount, equals(1));
        },
      );

      test(
        'should return online when probe succeeds on the second attempt',
        () async {
          // Arrange
          var callCount = 0;
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(
            fakeConnectivity,
            probe: () async {
              callCount++;
              return callCount >= 2;
            },
          );

          // Act
          final status = await repository.checkConnectivity();

          // Assert
          expect(status, equals(ConnectivityStatus.online));
          expect(callCount, equals(2));
        },
      );

      test(
        'should return online when probe succeeds on the third attempt',
        () async {
          // Arrange
          var callCount = 0;
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(
            fakeConnectivity,
            probe: () async {
              callCount++;
              return callCount >= 3;
            },
          );

          // Act
          final status = await repository.checkConnectivity();

          // Assert
          expect(status, equals(ConnectivityStatus.online));
          expect(callCount, equals(3));
        },
      );
    });

    // ========================================================================
    // watchConnectivity — initial state emission
    // ========================================================================

    group('watchConnectivity — initial state', () {
      test(
        'should emit online as the first event when interface and DNS are available',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(fakeConnectivity, probe: () async => true);

          // Act
          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(results.first, equals(ConnectivityStatus.online));

          await sub.cancel();
        },
      );

      test(
        'should emit offline as the first event when no interface is available',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([ConnectivityResult.none]);
          final repository = _repo(fakeConnectivity);

          // Act
          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(results.first, equals(ConnectivityStatus.offline));

          await sub.cancel();
        },
      );

      test(
        'should emit offline as the first event when interface is present but DNS probe fails',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(fakeConnectivity, probe: () async => false);

          // Act
          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(results.first, equals(ConnectivityStatus.offline));

          await sub.cancel();
        },
      );

      test(
        'should emit online as fallback when initial checkConnectivity throws',
        () async {
          // Arrange
          fakeConnectivity.setCheckError(Exception('platform channel error'));
          final repository = _repo(fakeConnectivity);

          // Act
          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(results.first, equals(ConnectivityStatus.online));

          await sub.cancel();
        },
      );
    });

    // ========================================================================
    // watchConnectivity — connectivity change events
    // ========================================================================

    group('watchConnectivity — connectivity change events', () {
      test(
        'should emit online when a connectivity-change event shows a wifi interface and DNS succeeds',
        () async {
          // Arrange — start offline so the change is from none → wifi
          fakeConnectivity.setCheckResult([ConnectivityResult.none]);
          final repository = _repo(fakeConnectivity, probe: () async => true);
          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);
          await Future<void>.delayed(Duration.zero);

          // Act
          fakeConnectivity.emitChange([ConnectivityResult.wifi]);
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(results.last, equals(ConnectivityStatus.online));

          await sub.cancel();
        },
      );

      test(
        'should emit offline immediately when a connectivity-change event shows no interface',
        () async {
          // Arrange — start online
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(fakeConnectivity, probe: () async => true);
          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);
          await Future<void>.delayed(Duration.zero);

          // Act
          fakeConnectivity.emitChange([ConnectivityResult.none]);
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(results.last, equals(ConnectivityStatus.offline));

          await sub.cancel();
        },
      );

      test(
        'should emit offline when a connectivity-change event shows interface but DNS fails',
        () async {
          // Arrange — start offline so the change produces a meaningful probe
          fakeConnectivity.setCheckResult([ConnectivityResult.none]);
          final repository = _repo(fakeConnectivity, probe: () async => false);
          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);
          await Future<void>.delayed(Duration.zero);

          // Act — interface present but DNS still fails
          fakeConnectivity.emitChange([ConnectivityResult.wifi]);
          await Future<void>.delayed(Duration.zero);

          // Assert — no new emission (distinct deduplicates offline → offline)
          expect(results, [ConnectivityStatus.offline]);

          await sub.cancel();
        },
      );

      test(
        'should not invoke DNS probe when connectivity-change event shows no interface',
        () async {
          // Arrange
          var probeCallCount = 0;
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(
            fakeConnectivity,
            probe: () async {
              probeCallCount++;
              return true;
            },
          );
          final sub = repository.watchConnectivity().listen((_) {});
          await Future<void>.delayed(Duration.zero);
          final probeCountAfterInit = probeCallCount;

          // Act — disconnect (no interface)
          fakeConnectivity.emitChange([ConnectivityResult.none]);
          await Future<void>.delayed(Duration.zero);

          // Assert — no additional probe
          expect(probeCallCount, equals(probeCountAfterInit));

          await sub.cancel();
        },
      );

      test(
        'should invoke DNS probe when connectivity-change event shows an interface',
        () async {
          // Arrange
          var probeCallCount = 0;
          fakeConnectivity.setCheckResult([ConnectivityResult.none]);
          final repository = _repo(
            fakeConnectivity,
            probe: () async {
              probeCallCount++;
              return true;
            },
          );
          final sub = repository.watchConnectivity().listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Act — interface appears
          fakeConnectivity.emitChange([ConnectivityResult.wifi]);
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(probeCallCount, greaterThan(0));

          await sub.cancel();
        },
      );
    });

    // ========================================================================
    // watchConnectivity — distinct deduplication
    // ========================================================================

    group('watchConnectivity — distinct deduplication', () {
      test('should deduplicate consecutive identical status emissions', () async {
        // Arrange
        fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
        final repository = _repo(fakeConnectivity, probe: () async => true);
        final results = <ConnectivityStatus>[];
        final sub = repository.watchConnectivity().listen(results.add);
        await Future<void>.delayed(Duration.zero);

        // Act — emit the same state twice in a row
        fakeConnectivity.emitChange([ConnectivityResult.wifi]);
        await Future<void>.delayed(Duration.zero);
        fakeConnectivity.emitChange([ConnectivityResult.mobile]);
        await Future<void>.delayed(Duration.zero);

        // Assert — still online after both changes, deduped to one total emission
        expect(results, [ConnectivityStatus.online]);

        await sub.cancel();
      });

      test(
        'should emit both online and offline when status genuinely transitions',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(fakeConnectivity, probe: () async => true);
          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);
          await Future<void>.delayed(Duration.zero);

          // Act — go offline then back online
          fakeConnectivity.emitChange([ConnectivityResult.none]);
          await Future<void>.delayed(Duration.zero);
          fakeConnectivity.emitChange([ConnectivityResult.wifi]);
          await Future<void>.delayed(Duration.zero);

          // Assert
          expect(results, [
            ConnectivityStatus.online,
            ConnectivityStatus.offline,
            ConnectivityStatus.online,
          ]);

          await sub.cancel();
        },
      );
    });

    // ========================================================================
    // watchConnectivity — stream lifecycle
    // ========================================================================

    group('watchConnectivity — stream lifecycle', () {
      test(
        'should cancel successfully without errors when the stream is cancelled',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(fakeConnectivity);
          final sub = repository.watchConnectivity().listen((_) {});
          await Future<void>.delayed(Duration.zero);

          // Act & Assert — should not throw
          await expectLater(sub.cancel(), completes);
        },
      );

      test(
        'should stop emitting events after the stream is cancelled',
        () async {
          // Arrange
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(fakeConnectivity, probe: () async => true);
          final results = <ConnectivityStatus>[];
          final sub = repository.watchConnectivity().listen(results.add);
          await Future<void>.delayed(Duration.zero);
          await sub.cancel();

          // Act — emit a change after cancel
          fakeConnectivity.emitChange([ConnectivityResult.none]);
          await Future<void>.delayed(Duration.zero);

          // Assert — only the initial online emission exists
          expect(results, [ConnectivityStatus.online]);
        },
      );
    });

    // ========================================================================
    // watchConnectivity — periodic probing (fake_async)
    // ========================================================================

    group('watchConnectivity — periodic probing', () {
      test(
        'should fire a periodic probe after 30 seconds when online and emit offline on DNS failure',
        () {
          fakeAsync((async) {
            var dnsSucceeds = true;
            fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
            final repository = _repo(
              fakeConnectivity,
              probe: () async => dnsSucceeds,
            );

            final results = <ConnectivityStatus>[];
            final sub = repository.watchConnectivity().listen(results.add);
            async.flushMicrotasks();
            expect(results.last, equals(ConnectivityStatus.online));

            // DNS starts failing
            dnsSucceeds = false;

            // Advance 30 seconds — periodic probe fires
            async.elapse(const Duration(seconds: 30));
            expect(results.last, equals(ConnectivityStatus.offline));

            sub.cancel();
          });
        },
      );

      test(
        'should not fire a periodic probe before 30 seconds have elapsed',
        () {
          fakeAsync((async) {
            var probeCallCount = 0;
            fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
            final repository = _repo(
              fakeConnectivity,
              probe: () async {
                probeCallCount++;
                return true;
              },
            );

            final sub = repository.watchConnectivity().listen((_) {});
            async.flushMicrotasks();
            final callsAfterInit = probeCallCount;

            // Advance only 29 seconds — probe must NOT fire yet
            async.elapse(const Duration(seconds: 29));
            expect(probeCallCount, equals(callsAfterInit));

            sub.cancel();
          });
        },
      );

      test(
        'should fire periodic probes at 30-second intervals when staying online',
        () {
          fakeAsync((async) {
            var probeCallCount = 0;
            fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
            final repository = _repo(
              fakeConnectivity,
              probe: () async {
                probeCallCount++;
                return true;
              },
            );

            final sub = repository.watchConnectivity().listen((_) {});
            async.flushMicrotasks();
            final callsAfterInit = probeCallCount;

            // First 30-second interval
            async.elapse(const Duration(seconds: 30));
            expect(probeCallCount, equals(callsAfterInit + 1));

            // Second 30-second interval
            async.elapse(const Duration(seconds: 30));
            expect(probeCallCount, equals(callsAfterInit + 2));

            sub.cancel();
          });
        },
      );

      test('should stop periodic probing when stream is cancelled', () {
        fakeAsync((async) {
          var probeCallCount = 0;
          fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
          final repository = _repo(
            fakeConnectivity,
            probe: () async {
              probeCallCount++;
              return true;
            },
          );

          final sub = repository.watchConnectivity().listen((_) {});
          async.flushMicrotasks();
          sub.cancel();
          async.flushMicrotasks();
          final callsAtCancel = probeCallCount;

          // Advance well past a probe interval — no new probes
          async.elapse(const Duration(seconds: 60));
          expect(probeCallCount, equals(callsAtCancel));
        });
      });
    });

    // ========================================================================
    // watchConnectivity — recovery probing (fake_async)
    // ========================================================================

    group('watchConnectivity — recovery probing', () {
      test(
        'should start 5-second recovery probes when initial state is offline',
        () {
          fakeAsync((async) {
            var dnsSucceeds = false;
            fakeConnectivity.setCheckResult([ConnectivityResult.none]);
            final repository = _repo(
              fakeConnectivity,
              probe: () async => dnsSucceeds,
            );

            final results = <ConnectivityStatus>[];
            final sub = repository.watchConnectivity().listen(results.add);
            async.flushMicrotasks();
            expect(results.last, equals(ConnectivityStatus.offline));

            // DNS recovers; advance 5 seconds for recovery probe
            dnsSucceeds = true;
            async.elapse(const Duration(seconds: 5));
            expect(results.last, equals(ConnectivityStatus.online));

            sub.cancel();
          });
        },
      );

      test(
        'should start 5-second recovery probes when interface present but DNS fails initially',
        () {
          fakeAsync((async) {
            var dnsSucceeds = false;
            fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
            final repository = _repo(
              fakeConnectivity,
              probe: () async => dnsSucceeds,
            );

            final results = <ConnectivityStatus>[];
            final sub = repository.watchConnectivity().listen(results.add);
            async.flushMicrotasks();
            expect(results.last, equals(ConnectivityStatus.offline));

            // DNS recovers; advance 5 seconds
            dnsSucceeds = true;
            async.elapse(const Duration(seconds: 5));
            expect(results.last, equals(ConnectivityStatus.online));

            sub.cancel();
          });
        },
      );

      test(
        'should not fire a recovery probe before 5 seconds have elapsed',
        () {
          fakeAsync((async) {
            var probeCallCount = 0;
            fakeConnectivity.setCheckResult([ConnectivityResult.none]);
            final repository = _repo(
              fakeConnectivity,
              probe: () async {
                probeCallCount++;
                return false;
              },
            );

            final sub = repository.watchConnectivity().listen((_) {});
            async.flushMicrotasks();
            final callsAfterInit = probeCallCount;

            // Advance only 4 seconds — no recovery probe yet
            async.elapse(const Duration(seconds: 4));
            expect(probeCallCount, equals(callsAfterInit));

            sub.cancel();
          });
        },
      );

      test(
        'should switch from recovery (5s) to periodic (30s) probing after recovery succeeds',
        () {
          fakeAsync((async) {
            var dnsSucceeds = false;
            var probeCallCount = 0;
            fakeConnectivity.setCheckResult([ConnectivityResult.none]);
            final repository = _repo(
              fakeConnectivity,
              probe: () async {
                probeCallCount++;
                return dnsSucceeds;
              },
            );

            final results = <ConnectivityStatus>[];
            final sub = repository.watchConnectivity().listen(results.add);
            async.flushMicrotasks();

            // DNS recovers at the 5-second mark
            dnsSucceeds = true;
            async.elapse(const Duration(seconds: 5));
            expect(results.last, equals(ConnectivityStatus.online));
            final callsAfterRecovery = probeCallCount;

            // Advance 10 seconds — still in 30s periodic mode, probe should NOT fire
            async.elapse(const Duration(seconds: 10));
            expect(probeCallCount, equals(callsAfterRecovery));

            // Advance to 30s mark — periodic probe fires
            async.elapse(const Duration(seconds: 20));
            expect(probeCallCount, greaterThan(callsAfterRecovery));

            sub.cancel();
          });
        },
      );

      test(
        'should switch from periodic (30s) to recovery (5s) probing when DNS fails mid-session',
        () {
          fakeAsync((async) {
            var dnsSucceeds = true;
            var probeCallCount = 0;
            fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
            final repository = _repo(
              fakeConnectivity,
              probe: () async {
                probeCallCount++;
                return dnsSucceeds;
              },
            );

            final results = <ConnectivityStatus>[];
            final sub = repository.watchConnectivity().listen(results.add);
            async.flushMicrotasks();
            expect(results.last, equals(ConnectivityStatus.online));

            // DNS starts failing
            dnsSucceeds = false;

            // Periodic probe fires at 30s → switches to recovery mode
            async.elapse(const Duration(seconds: 30));
            expect(results.last, equals(ConnectivityStatus.offline));
            final callsAfterSwitch = probeCallCount;

            // DNS recovers; recovery probe fires at 5s
            dnsSucceeds = true;
            async.elapse(const Duration(seconds: 5));
            expect(probeCallCount, greaterThan(callsAfterSwitch));
            expect(results.last, equals(ConnectivityStatus.online));

            sub.cancel();
          });
        },
      );

      test(
        'should replace a previous recovery probe with a fresh one when interface is lost',
        () {
          fakeAsync((async) {
            var dnsSucceeds = false;
            fakeConnectivity.setCheckResult([ConnectivityResult.none]);
            final repository = _repo(
              fakeConnectivity,
              probe: () async => dnsSucceeds,
            );

            final results = <ConnectivityStatus>[];
            final sub = repository.watchConnectivity().listen(results.add);
            async.flushMicrotasks();

            // WiFi connects but DNS still fails → recovery starts
            fakeConnectivity.emitChange([ConnectivityResult.wifi]);
            async.flushMicrotasks();

            // Interface lost → previous recovery replaced by new one
            fakeConnectivity.emitChange([ConnectivityResult.none]);
            async.flushMicrotasks();

            // DNS recovers; new recovery probe should detect it
            dnsSucceeds = true;
            async.elapse(const Duration(seconds: 5));
            expect(results.last, equals(ConnectivityStatus.online));

            sub.cancel();
          });
        },
      );

      test(
        'should skip a recovery probe tick when a previous probe is still in flight',
        () {
          fakeAsync((async) {
            final probeCalls = <int>[];
            var probeCompleter = Completer<bool>();
            fakeConnectivity.setCheckResult([ConnectivityResult.none]);
            final repository = _repo(
              fakeConnectivity,
              probe: () {
                probeCalls.add(probeCalls.length);
                return probeCompleter.future;
              },
            );

            final sub = repository.watchConnectivity().listen((_) {});
            async.flushMicrotasks();

            // WiFi connects — completes the initial DNS checks to enter recovery mode
            probeCompleter.complete(false);
            async.flushMicrotasks();
            probeCompleter = Completer<bool>()..complete(false);
            async.flushMicrotasks();
            probeCompleter = Completer<bool>()..complete(false);
            async.flushMicrotasks();

            fakeConnectivity.emitChange([ConnectivityResult.wifi]);
            async.flushMicrotasks();
            // The connectivity-change DNS probes complete as false → recovery mode
            probeCompleter = Completer<bool>()..complete(false);
            async.flushMicrotasks();
            probeCompleter = Completer<bool>()..complete(false);
            async.flushMicrotasks();
            probeCompleter = Completer<bool>()..complete(false);
            async.flushMicrotasks();

            // Clear tracking and enter the recovery-probe guard test
            probeCalls.clear();

            // First recovery tick at 5s — start a slow probe
            probeCompleter = Completer<bool>();
            async.elapse(const Duration(seconds: 5));
            expect(probeCalls.length, equals(1));

            // Second recovery tick at 10s — probe still in flight → tick skipped
            async.elapse(const Duration(seconds: 5));
            expect(probeCalls.length, equals(1));

            // Complete the slow probe
            probeCompleter.complete(true);
            async.flushMicrotasks();

            sub.cancel();
          });
        },
      );
    });

    // ========================================================================
    // watchConnectivity — stale probe invalidation via epoch (fake_async)
    // ========================================================================

    group('watchConnectivity — stale probe invalidation', () {
      test(
        'should discard the result of a stale in-flight probe after an epoch change',
        () {
          fakeAsync((async) {
            var dnsCompleter = Completer<bool>();
            fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
            final repository = _repo(
              fakeConnectivity,
              probe: () => dnsCompleter.future,
            );

            final results = <ConnectivityStatus>[];
            final sub = repository.watchConnectivity().listen(results.add);

            // Complete initial check → online
            dnsCompleter.complete(true);
            async.flushMicrotasks();
            expect(results, [ConnectivityStatus.online]);

            // Periodic probe at 30s — keep it in flight
            final staleCompleter = Completer<bool>();
            dnsCompleter = staleCompleter;
            async.elapse(const Duration(seconds: 30));

            // WiFi OFF → offline
            fakeConnectivity.emitChange([ConnectivityResult.none]);
            async.flushMicrotasks();
            expect(results.last, equals(ConnectivityStatus.offline));

            // WiFi ON → fresh probe → online
            dnsCompleter = Completer<bool>();
            fakeConnectivity.emitChange([ConnectivityResult.wifi]);
            async.flushMicrotasks();
            dnsCompleter.complete(true);
            async.flushMicrotasks();
            expect(results.last, equals(ConnectivityStatus.online));

            // Complete the stale probe with false — must NOT emit offline
            staleCompleter.complete(false);
            async.flushMicrotasks();

            expect(
              results.last,
              equals(ConnectivityStatus.online),
              reason: 'stale probe result must be discarded by epoch guard',
            );

            sub.cancel();
          });
        },
      );

      test(
        'should allow a fresh connectivity-change probe to proceed when a stale probe is in flight',
        () {
          fakeAsync((async) {
            var dnsCompleter = Completer<bool>();
            fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
            final repository = _repo(
              fakeConnectivity,
              probe: () => dnsCompleter.future,
            );

            final results = <ConnectivityStatus>[];
            final sub = repository.watchConnectivity().listen(results.add);

            // Complete initial check → online
            dnsCompleter.complete(true);
            async.flushMicrotasks();
            expect(results, [ConnectivityStatus.online]);

            // Periodic probe at 30s — stays in flight
            dnsCompleter = Completer<bool>();
            async.elapse(const Duration(seconds: 30));

            // WiFi OFF while in-flight
            fakeConnectivity.emitChange([ConnectivityResult.none]);
            async.flushMicrotasks();
            expect(results.last, equals(ConnectivityStatus.offline));

            // WiFi ON — must start a fresh DNS check despite in-flight stale probe
            dnsCompleter = Completer<bool>();
            fakeConnectivity.emitChange([ConnectivityResult.wifi]);
            async.flushMicrotasks();

            // Complete fresh probe → online
            dnsCompleter.complete(true);
            async.flushMicrotasks();

            expect(
              results.last,
              equals(ConnectivityStatus.online),
              reason:
                  'fresh connectivity-change probe should not be blocked by stale isProbing flag',
            );

            sub.cancel();
          });
        },
      );
    });

    // ========================================================================
    // watchConnectivity — recovery after no-interface offline
    // ========================================================================

    group('watchConnectivity — recovery after no-interface offline', () {
      test(
        'should start recovery probes when connectivity changes to none while online',
        () {
          fakeAsync((async) {
            var dnsSucceeds = false;
            fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
            final repository = _repo(
              fakeConnectivity,
              probe: () async => dnsSucceeds,
            );

            final results = <ConnectivityStatus>[];
            final sub = repository.watchConnectivity().listen(results.add);
            async.flushMicrotasks();

            // Initial: offline (wifi present but DNS fails)
            expect(results.last, equals(ConnectivityStatus.offline));

            // WiFi OFF → no interface → offline (deduped by distinct)
            fakeConnectivity.emitChange([ConnectivityResult.none]);
            async.flushMicrotasks();

            // DNS starts succeeding; advance 5s for recovery probe
            dnsSucceeds = true;
            async.elapse(const Duration(seconds: 5));

            expect(
              results.last,
              equals(ConnectivityStatus.online),
              reason:
                  'recovery probe should detect DNS recovery after no-interface offline',
            );

            sub.cancel();
          });
        },
      );
    });

    // ========================================================================
    // watchConnectivity — connectivity change probe guard
    // ========================================================================

    group('watchConnectivity — connectivity change probe guard', () {
      test(
        'should cancel existing periodic probes and start a fresh DNS check on connectivity change',
        () {
          fakeAsync((async) {
            var dnsCallCount = 0;
            var dnsCompleter = Completer<bool>();
            fakeConnectivity.setCheckResult([ConnectivityResult.wifi]);
            final repository = _repo(
              fakeConnectivity,
              probe: () {
                dnsCallCount++;
                return dnsCompleter.future;
              },
            );

            final results = <ConnectivityStatus>[];
            final sub = repository.watchConnectivity().listen(results.add);

            // Complete initial check → online
            dnsCompleter.complete(true);
            async.flushMicrotasks();
            expect(results, [ConnectivityStatus.online]);

            // Periodic probe fires at 30s — stays in flight
            dnsCompleter = Completer<bool>();
            async.elapse(const Duration(seconds: 30));
            final callsAfterPeriodicStart = dnsCallCount;
            expect(callsAfterPeriodicStart, greaterThan(1));

            // Connectivity change while in-flight — should start fresh DNS
            dnsCompleter = Completer<bool>();
            fakeConnectivity.emitChange([ConnectivityResult.mobile]);
            async.flushMicrotasks();

            expect(
              dnsCallCount,
              greaterThan(callsAfterPeriodicStart),
              reason: 'connectivity change should initiate a fresh DNS check',
            );

            // Complete the fresh probe → online
            dnsCompleter.complete(true);
            async.flushMicrotasks();
            expect(results.last, equals(ConnectivityStatus.online));

            sub.cancel();
          });
        },
      );
    });
  });
}
