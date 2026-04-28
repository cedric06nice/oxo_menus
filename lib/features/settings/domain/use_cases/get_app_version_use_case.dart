import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/app_version_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';

/// Reads the running app's version string through [AppVersionGateway].
///
/// Wraps any thrown error as [UnknownError] so the view model never has to
/// catch raw platform exceptions.
class GetAppVersionUseCase extends UseCase<NoInput, String> {
  GetAppVersionUseCase({required AppVersionGateway gateway})
    : _gateway = gateway;

  final AppVersionGateway _gateway;

  @override
  Future<Result<String, DomainError>> execute(NoInput input) async {
    try {
      final version = await _gateway.read();
      return Success(version);
    } catch (error) {
      return Failure(UnknownError(error.toString()));
    }
  }
}
