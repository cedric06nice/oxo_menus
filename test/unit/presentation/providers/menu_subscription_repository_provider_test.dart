import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

import '../../../fakes/fake_menu_subscription_repository.dart';

void main() {
  group('menuSubscriptionRepositoryProvider', () {
    test('should provide a MenuSubscriptionRepository instance', () {
      final container = ProviderContainer(
        overrides: [
          menuSubscriptionRepositoryProvider.overrideWithValue(
            FakeMenuSubscriptionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(menuSubscriptionRepositoryProvider);

      expect(repo, isA<MenuSubscriptionRepository>());
    });

    test('should return the same instance on multiple reads', () {
      final fake = FakeMenuSubscriptionRepository();
      final container = ProviderContainer(
        overrides: [menuSubscriptionRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final r1 = container.read(menuSubscriptionRepositoryProvider);
      final r2 = container.read(menuSubscriptionRepositoryProvider);

      expect(identical(r1, r2), isTrue);
    });

    test('should use the injected implementation when overridden', () {
      final fake = FakeMenuSubscriptionRepository();
      final container = ProviderContainer(
        overrides: [menuSubscriptionRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final repo = container.read(menuSubscriptionRepositoryProvider);

      expect(repo, same(fake));
    });
  });
}
