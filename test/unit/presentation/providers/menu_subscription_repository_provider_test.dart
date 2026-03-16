import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  group('menuSubscriptionRepositoryProvider', () {
    test('should provide a MenuSubscriptionRepository instance', () {
      final mockDataSource = MockDirectusDataSource();
      final container = ProviderContainer(
        overrides: [
          directusDataSourceProvider.overrideWithValue(mockDataSource),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(menuSubscriptionRepositoryProvider);

      expect(repository, isA<MenuSubscriptionRepository>());
    });
  });
}
