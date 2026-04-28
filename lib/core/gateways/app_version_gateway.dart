import 'package:package_info_plus/package_info_plus.dart';

/// Gateway exposing the running app's version string.
///
/// One instance lives on `AppContainer` for the app's lifetime. The Settings
/// view model resolves the version at construction so the screen renders the
/// final value on first frame; refreshes are not needed because the version
/// only changes across app restarts.
abstract class AppVersionGateway {
  /// Returns the formatted version string (e.g. `1.2.3 (42)`).
  Future<String> read();
}

/// Production implementation backed by `package_info_plus`.
///
/// The [reader] is injectable for tests so the gateway is fully unit-testable
/// without setting platform mock values. Defaults to
/// [PackageInfo.fromPlatform], which the platform plugin caches internally.
class PackageInfoAppVersionGateway implements AppVersionGateway {
  PackageInfoAppVersionGateway({Future<PackageInfo> Function()? reader})
    : _reader = reader ?? PackageInfo.fromPlatform;

  final Future<PackageInfo> Function() _reader;

  @override
  Future<String> read() async {
    final info = await _reader();
    if (info.buildNumber.isEmpty) {
      return info.version;
    }
    return '${info.version} (${info.buildNumber})';
  }
}
