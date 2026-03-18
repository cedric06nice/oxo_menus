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
  String url;
  if (dartDefineUrl.isNotEmpty) {
    url = dartDefineUrl;
  } else {
    final host = baseUri.host;
    if (isWeb && host.isNotEmpty && host != 'localhost') {
      url = 'https://api.$host';
    } else {
      url = 'http://localhost:8055';
    }
  }
  while (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }
  return url;
}
