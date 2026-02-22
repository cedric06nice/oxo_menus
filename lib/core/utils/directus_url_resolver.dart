/// Resolves the Directus API URL with a web-specific fallback.
///
/// Resolution order:
/// 1. If [dartDefineUrl] is non-empty (from `--dart-define=DIRECTUS_URL`), use it.
/// 2. If running on web ([isWeb]) and the [baseUri] host is not `localhost`,
///    derive the API URL as `https://api.{hostname}`.
/// 3. Otherwise, fall back to `http://localhost:8055` for local development.
String resolveDirectusUrl({
  required String dartDefineUrl,
  required bool isWeb,
  required Uri baseUri,
}) {
  if (dartDefineUrl.isNotEmpty) return dartDefineUrl;

  final host = baseUri.host;
  if (isWeb && host.isNotEmpty && host != 'localhost') {
    return 'https://api.$host';
  }

  return 'http://localhost:8055';
}
