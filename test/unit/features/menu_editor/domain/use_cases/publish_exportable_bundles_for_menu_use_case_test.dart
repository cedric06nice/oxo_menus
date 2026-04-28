import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_bundles_for_menu_usecase.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/publish_exportable_bundles_for_menu_use_case.dart';

import '../../../../../fakes/fake_menu_bundle_repository.dart';
import '../../../../../fakes/fake_publish_menu_bundle_usecase.dart';
import '../../auth_helpers.dart';

const _bundle = MenuBundle(id: 100, name: 'Bundle', menuIds: [1]);

void main() {
  group('PublishExportableBundlesForMenuUseCase — authenticated', () {
    test(
      'forwards to the underlying delegate and returns its results',
      () async {
        final gateway = await gatewayFor(regularUser);
        addTearDown(gateway.dispose);
        final bundleRepo = FakeMenuBundleRepository()
          ..whenFindByIncludedMenu(const Success([_bundle]));
        final publishStub = FakePublishMenuBundleUseCase()
          ..stubExecute(const Success(_bundle));
        final delegate = PublishBundlesForMenuUseCase(
          repository: bundleRepo,
          publishMenuBundleUseCase: publishStub,
        );
        final useCase = PublishExportableBundlesForMenuUseCase(
          authGateway: gateway,
          delegate: delegate,
        );

        final results = await useCase.execute(1);

        expect(results, hasLength(1));
        expect(results.single.valueOrNull, _bundle);
        expect(publishStub.calls.single.bundleId, 100);
      },
    );
  });

  group('PublishExportableBundlesForMenuUseCase — anonymous', () {
    test(
      'returns a single UnauthorizedError without invoking the delegate',
      () async {
        final gateway = await gatewayFor(null);
        addTearDown(gateway.dispose);
        final bundleRepo = FakeMenuBundleRepository();
        final publishStub = FakePublishMenuBundleUseCase();
        final delegate = PublishBundlesForMenuUseCase(
          repository: bundleRepo,
          publishMenuBundleUseCase: publishStub,
        );
        final useCase = PublishExportableBundlesForMenuUseCase(
          authGateway: gateway,
          delegate: delegate,
        );

        final results = await useCase.execute(1);

        expect(results, hasLength(1));
        expect(results.single.errorOrNull, isA<UnauthorizedError>());
        expect(publishStub.calls, isEmpty);
      },
    );
  });
}
