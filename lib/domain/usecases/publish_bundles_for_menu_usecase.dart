import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/domain/usecases/publish_menu_bundle_usecase.dart';

/// Re-publish every bundle that includes a given menu id.
///
/// Used by the menu editor: when the admin clicks the PDF preview button on
/// a menu, every bundle that contains that menu is regenerated and the public
/// Directus PDF is refreshed. Runs each publish sequentially and aggregates
/// the results; a failure on one bundle does not skip the others.
class PublishBundlesForMenuUseCase {
  final MenuBundleRepository repository;
  final PublishMenuBundleUseCase publishMenuBundleUseCase;

  const PublishBundlesForMenuUseCase({
    required this.repository,
    required this.publishMenuBundleUseCase,
  });

  Future<List<Result<MenuBundle, DomainError>>> execute(int menuId) async {
    final lookup = await repository.findByIncludedMenu(menuId);
    if (lookup.isFailure) {
      return [Failure(lookup.errorOrNull!)];
    }

    final results = <Result<MenuBundle, DomainError>>[];
    for (final bundle in lookup.valueOrNull!) {
      results.add(await publishMenuBundleUseCase.execute(bundle.id));
    }
    return results;
  }
}
