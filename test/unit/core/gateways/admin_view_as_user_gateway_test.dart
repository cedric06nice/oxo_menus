import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';

void main() {
  group('AdminViewAsUserGateway', () {
    test('initial value is false', () {
      final gateway = AdminViewAsUserGateway();
      addTearDown(gateway.dispose);

      expect(gateway.currentValue, isFalse);
    });

    test('initial value can be overridden via constructor', () {
      final gateway = AdminViewAsUserGateway(initialValue: true);
      addTearDown(gateway.dispose);

      expect(gateway.currentValue, isTrue);
    });

    test('set updates currentValue and emits on the stream', () async {
      final gateway = AdminViewAsUserGateway();
      addTearDown(gateway.dispose);

      final received = <bool>[];
      final sub = gateway.valueStream.listen(received.add);
      addTearDown(sub.cancel);

      gateway.set(true);
      await Future<void>.delayed(Duration.zero);

      expect(gateway.currentValue, isTrue);
      expect(received, [true]);
    });

    test('set with the same value is a no-op (no stream emission)', () async {
      final gateway = AdminViewAsUserGateway();
      addTearDown(gateway.dispose);

      final received = <bool>[];
      final sub = gateway.valueStream.listen(received.add);
      addTearDown(sub.cancel);

      gateway.set(false);
      await Future<void>.delayed(Duration.zero);

      expect(received, isEmpty);
    });

    test('valueStream is broadcast — supports multiple listeners', () async {
      final gateway = AdminViewAsUserGateway();
      addTearDown(gateway.dispose);

      final a = <bool>[];
      final b = <bool>[];
      final subA = gateway.valueStream.listen(a.add);
      final subB = gateway.valueStream.listen(b.add);
      addTearDown(subA.cancel);
      addTearDown(subB.cancel);

      gateway.set(true);
      await Future<void>.delayed(Duration.zero);

      expect(a, [true]);
      expect(b, [true]);
    });

    test('toggle flips the value and emits', () async {
      final gateway = AdminViewAsUserGateway();
      addTearDown(gateway.dispose);

      final received = <bool>[];
      final sub = gateway.valueStream.listen(received.add);
      addTearDown(sub.cancel);

      gateway.toggle();
      gateway.toggle();
      await Future<void>.delayed(Duration.zero);

      expect(gateway.currentValue, isFalse);
      expect(received, [true, false]);
    });

    test('dispose closes the controller and is idempotent', () async {
      final gateway = AdminViewAsUserGateway();

      gateway.dispose();
      gateway.dispose();

      expect(gateway.isDisposed, isTrue);
    });

    test('set after dispose is a no-op', () async {
      final gateway = AdminViewAsUserGateway();
      gateway.dispose();

      gateway.set(true);

      expect(gateway.currentValue, isFalse);
    });
  });
}
