import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/repositories/area_repository.dart';
import 'package:oxo_menus/domain/repositories/asset_loader_repository.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

import '../../../fakes/fake_area_repository.dart';
import '../../../fakes/fake_asset_loader_repository.dart';
import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/fake_column_repository.dart';
import '../../../fakes/fake_connectivity_repository.dart';
import '../../../fakes/fake_container_repository.dart';
import '../../../fakes/fake_file_repository.dart';
import '../../../fakes/fake_menu_bundle_repository.dart';
import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/fake_menu_subscription_repository.dart';
import '../../../fakes/fake_page_repository.dart';
import '../../../fakes/fake_presence_repository.dart';
import '../../../fakes/fake_size_repository.dart';
import '../../../fakes/fake_widget_repository.dart';

void main() {
  group('directusBaseUrlProvider', () {
    test(
      'should return the localhost default URL when no dart-define is set',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final url = container.read(directusBaseUrlProvider);

        expect(url, 'http://localhost:8055');
      },
    );
  });

  group('repository providers — identity and type', () {
    // Each provider is a simple factory that wraps the data source.
    // We test that: (1) the provider returns the correct abstract type, and
    // (2) the result is the same object on subsequent reads (singleton-within-container).

    ProviderContainer buildContainer() {
      return ProviderContainer(
        overrides: [
          menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
          pageRepositoryProvider.overrideWithValue(FakePageRepository()),
          containerRepositoryProvider.overrideWithValue(
            FakeContainerRepository(),
          ),
          columnRepositoryProvider.overrideWithValue(FakeColumnRepository()),
          widgetRepositoryProvider.overrideWithValue(FakeWidgetRepository()),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          sizeRepositoryProvider.overrideWithValue(FakeSizeRepository()),
          fileRepositoryProvider.overrideWithValue(FakeFileRepository()),
          menuBundleRepositoryProvider.overrideWithValue(
            FakeMenuBundleRepository(),
          ),
          menuSubscriptionRepositoryProvider.overrideWithValue(
            FakeMenuSubscriptionRepository(),
          ),
          presenceRepositoryProvider.overrideWithValue(
            FakePresenceRepository(),
          ),
          areaRepositoryProvider.overrideWithValue(FakeAreaRepository()),
          assetLoaderRepositoryProvider.overrideWithValue(
            FakeAssetLoaderRepository(),
          ),
          connectivityRepositoryProvider.overrideWithValue(
            FakeConnectivityRepository(),
          ),
        ],
      );
    }

    test('menuRepositoryProvider should return a MenuRepository', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(menuRepositoryProvider), isA<MenuRepository>());
    });

    test('pageRepositoryProvider should return a PageRepository', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(pageRepositoryProvider), isA<PageRepository>());
    });

    test('containerRepositoryProvider should return a ContainerRepository', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(containerRepositoryProvider),
        isA<ContainerRepository>(),
      );
    });

    test('columnRepositoryProvider should return a ColumnRepository', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(columnRepositoryProvider), isA<ColumnRepository>());
    });

    test('widgetRepositoryProvider should return a WidgetRepository', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(widgetRepositoryProvider), isA<WidgetRepository>());
    });

    test('authRepositoryProvider should return an AuthRepository', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(authRepositoryProvider), isA<AuthRepository>());
    });

    test('sizeRepositoryProvider should return a SizeRepository', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(sizeRepositoryProvider), isA<SizeRepository>());
    });

    test('fileRepositoryProvider should return a FileRepository', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(fileRepositoryProvider), isA<FileRepository>());
    });

    test(
      'menuBundleRepositoryProvider should return a MenuBundleRepository',
      () {
        final container = buildContainer();
        addTearDown(container.dispose);

        expect(
          container.read(menuBundleRepositoryProvider),
          isA<MenuBundleRepository>(),
        );
      },
    );

    test(
      'menuSubscriptionRepositoryProvider should return a MenuSubscriptionRepository',
      () {
        final container = buildContainer();
        addTearDown(container.dispose);

        expect(
          container.read(menuSubscriptionRepositoryProvider),
          isA<MenuSubscriptionRepository>(),
        );
      },
    );

    test('presenceRepositoryProvider should return a PresenceRepository', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(presenceRepositoryProvider),
        isA<PresenceRepository>(),
      );
    });

    test('areaRepositoryProvider should return an AreaRepository', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(areaRepositoryProvider), isA<AreaRepository>());
    });

    test(
      'assetLoaderRepositoryProvider should return an AssetLoaderRepository',
      () {
        final container = buildContainer();
        addTearDown(container.dispose);

        expect(
          container.read(assetLoaderRepositoryProvider),
          isA<AssetLoaderRepository>(),
        );
      },
    );

    test(
      'connectivityRepositoryProvider should return a ConnectivityRepository',
      () {
        final container = buildContainer();
        addTearDown(container.dispose);

        expect(
          container.read(connectivityRepositoryProvider),
          isA<ConnectivityRepository>(),
        );
      },
    );

    test(
      'should return the same instance on multiple reads within same container',
      () {
        final container = buildContainer();
        addTearDown(container.dispose);

        final r1 = container.read(menuRepositoryProvider);
        final r2 = container.read(menuRepositoryProvider);
        expect(identical(r1, r2), isTrue);
      },
    );
  });

  group('directusAccessTokenProvider', () {
    test('should return overridden token value', () {
      final container = ProviderContainer(
        overrides: [
          directusAccessTokenProvider.overrideWithValue('test-token'),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(directusAccessTokenProvider), 'test-token');
    });

    test('should return null when overridden with null', () {
      final container = ProviderContainer(
        overrides: [directusAccessTokenProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);

      expect(container.read(directusAccessTokenProvider), isNull);
    });
  });
}
