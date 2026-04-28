import 'package:oxo_menus/shared/data/datasources/secure_token_storage.dart';

/// In-memory fake for [SecureTokenStorage].
///
/// Replaces the platform-channel-backed [FlutterSecureStorage] with a
/// plain [Map] so tests that inject [DirectusDataSource] do not require
/// platform-channel setup.
///
/// Usage:
/// ```dart
/// final fakeStorage = FakeSecureTokenStorage();
/// fakeStorage.seedTokens(accessToken: 'acc', refreshToken: 'ref');
/// final dataSource = DirectusDataSource(
///   baseUrl: 'http://localhost:8055',
///   tokenStorage: fakeStorage,
/// );
/// ```
class FakeSecureTokenStorage extends SecureTokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final Map<String, String?> _store = {};

  FakeSecureTokenStorage() : super(storage: null);

  // ---------------------------------------------------------------------------
  // Test-only helpers
  // ---------------------------------------------------------------------------

  /// Pre-seeds both tokens so tests that need a logged-in state can skip the
  /// [saveTokens] call.
  void seedTokens({required String accessToken, required String refreshToken}) {
    _store[_accessKey] = accessToken;
    _store[_refreshKey] = refreshToken;
  }

  /// Reads the current in-memory access token (null if cleared or never set).
  String? get storedAccessToken => _store[_accessKey];

  /// Reads the current in-memory refresh token (null if cleared or never set).
  String? get storedRefreshToken => _store[_refreshKey];

  // ---------------------------------------------------------------------------
  // SecureTokenStorage overrides
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _store[_accessKey] = accessToken;
    _store[_refreshKey] = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _store[_accessKey];

  @override
  Future<String?> getRefreshToken() async => _store[_refreshKey];

  @override
  Future<bool> hasTokens() async {
    final access = _store[_accessKey];
    final refresh = _store[_refreshKey];
    return access != null && refresh != null;
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    _store[_refreshKey] = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _store.remove(_accessKey);
    _store.remove(_refreshKey);
  }
}
