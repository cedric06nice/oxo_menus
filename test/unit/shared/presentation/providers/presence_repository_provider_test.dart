import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/collaboration/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';

import '../../../../fakes/fake_presence_repository.dart';

void main() {
  group('presenceRepositoryProvider', () {
    test('should provide a PresenceRepository instance', () {
      final container = ProviderContainer(
        overrides: [
          presenceRepositoryProvider.overrideWithValue(
            FakePresenceRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(presenceRepositoryProvider);

      expect(repo, isA<PresenceRepository>());
    });

    test('should return the same instance on multiple reads', () {
      final fake = FakePresenceRepository();
      final container = ProviderContainer(
        overrides: [presenceRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final r1 = container.read(presenceRepositoryProvider);
      final r2 = container.read(presenceRepositoryProvider);

      expect(identical(r1, r2), isTrue);
    });

    test('should use the injected implementation when overridden', () {
      final fake = FakePresenceRepository();
      final container = ProviderContainer(
        overrides: [presenceRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final repo = container.read(presenceRepositoryProvider);

      expect(repo, same(fake));
    });
  });
}
