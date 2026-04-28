import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/usecases/publish_bundles_for_menu_usecase.dart';

/// Auth-aware wrapper around [PublishBundlesForMenuUseCase] used by the menu
/// editor's "Show PDF" flow.
///
/// Mirrors the existing background-publish behaviour but adds the standard
/// authenticated-user gate so callers without a session never start the bundle
/// publish loop.
class PublishExportableBundlesForMenuUseCase {
  PublishExportableBundlesForMenuUseCase({
    required AuthGateway authGateway,
    required PublishBundlesForMenuUseCase delegate,
  }) : _authGateway = authGateway,
       _delegate = delegate;

  final AuthGateway _authGateway;
  final PublishBundlesForMenuUseCase _delegate;

  Future<List<Result<MenuBundle, DomainError>>> execute(int menuId) async {
    if (_authGateway.currentUser == null) {
      return const <Result<MenuBundle, DomainError>>[
        Failure<MenuBundle, DomainError>(UnauthorizedError()),
      ];
    }
    return _delegate.execute(menuId);
  }
}
