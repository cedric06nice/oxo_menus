import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/view_model.dart';

class _CounterState {
  const _CounterState(this.count);
  final int count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _CounterState && other.count == count;

  @override
  int get hashCode => count.hashCode;
}

class _CounterViewModel extends ViewModel<_CounterState> {
  _CounterViewModel() : super(const _CounterState(0));

  int onInitCalls = 0;
  int onDisposeCalls = 0;

  @override
  Future<void> onInit() async {
    onInitCalls++;
  }

  @override
  void onDispose() {
    onDisposeCalls++;
  }

  void increment() => emit(_CounterState(state.count + 1));

  void emitDirectly(_CounterState next) => emit(next);
}

void main() {
  group('ViewModel', () {
    test('exposes initial state via state getter', () {
      final vm = _CounterViewModel();

      expect(vm.state, const _CounterState(0));
    });

    test('emit replaces state and notifies listeners', () {
      final vm = _CounterViewModel();
      var notifications = 0;
      vm.addListener(() => notifications++);

      vm.increment();

      expect(vm.state, const _CounterState(1));
      expect(notifications, 1);
    });

    test('emit does not notify when next state equals previous', () {
      final vm = _CounterViewModel();
      var notifications = 0;
      vm.addListener(() => notifications++);

      vm.emitDirectly(const _CounterState(0));

      expect(notifications, 0);
    });

    test('onInit is called by router-driven initialise()', () async {
      final vm = _CounterViewModel();

      await vm.initialise();

      expect(vm.onInitCalls, 1);
    });

    test('initialise is idempotent', () async {
      final vm = _CounterViewModel();

      await vm.initialise();
      await vm.initialise();

      expect(vm.onInitCalls, 1);
    });

    test('dispose calls onDispose then super.dispose', () {
      final vm = _CounterViewModel();

      vm.dispose();

      expect(vm.onDisposeCalls, 1);
    });

    test('emit after dispose is a no-op (no listener notified, no throw)', () {
      final vm = _CounterViewModel();
      var notifications = 0;
      vm.addListener(() => notifications++);
      vm.dispose();

      expect(() => vm.increment(), returnsNormally);
      expect(notifications, 0);
    });

    test('isDisposed reflects dispose state', () {
      final vm = _CounterViewModel();
      expect(vm.isDisposed, isFalse);

      vm.dispose();

      expect(vm.isDisposed, isTrue);
    });

    test('extends ChangeNotifier so it can be used with ListenableBuilder', () {
      final vm = _CounterViewModel();

      expect(vm, isA<ChangeNotifier>());
    });
  });
}
