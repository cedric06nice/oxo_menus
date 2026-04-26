import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/utils/directus_url_resolver.dart';

void main() {
  group('resolveDirectusUrl', () {
    group('dart-define URL takes precedence', () {
      test('should return dart-define URL when it is non-empty on non-web', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: 'https://api.example.com',
          isWeb: false,
          baseUri: Uri.parse('http://localhost'),
        );

        expect(result, 'https://api.example.com');
      });

      test('should return dart-define URL even on web with real hostname', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: 'https://custom-api.example.com',
          isWeb: true,
          baseUri: Uri.parse('https://app.example.com'),
        );

        expect(result, 'https://custom-api.example.com');
      });

      test('should return dart-define URL even on web with localhost baseUri', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: 'https://api.mysite.com',
          isWeb: true,
          baseUri: Uri.parse('http://localhost:3000'),
        );

        expect(result, 'https://api.mysite.com');
      });

      test('should strip single trailing slash from dart-define URL', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: 'https://api.example.com/',
          isWeb: false,
          baseUri: Uri.parse('http://localhost'),
        );

        expect(result, 'https://api.example.com');
      });

      test('should strip multiple trailing slashes from dart-define URL', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: 'https://api.example.com///',
          isWeb: false,
          baseUri: Uri.parse('http://localhost'),
        );

        expect(result, 'https://api.example.com');
      });

      test('should not alter dart-define URL that has no trailing slash', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: 'https://api.example.com',
          isWeb: false,
          baseUri: Uri.parse('http://localhost'),
        );

        expect(result, 'https://api.example.com');
      });
    });

    group('web derivation from hostname', () {
      test('should derive api URL from hostname when on web with real hostname', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: '',
          isWeb: true,
          baseUri: Uri.parse('https://oxo-menus.example.com'),
        );

        expect(result, 'https://api.oxo-menus.example.com');
      });

      test('should derive api URL for a single-label hostname on web', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: '',
          isWeb: true,
          baseUri: Uri.parse('https://myapp.io'),
        );

        expect(result, 'https://api.myapp.io');
      });

      test('should fall back to localhost when on web but hostname is localhost', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: '',
          isWeb: true,
          baseUri: Uri.parse('http://localhost:8080'),
        );

        expect(result, 'http://localhost:8055');
      });

      test('should fall back to localhost when on web but host is empty string', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: '',
          isWeb: true,
          baseUri: Uri(),
        );

        expect(result, 'http://localhost:8055');
      });
    });

    group('non-web localhost fallback', () {
      test('should fall back to localhost when not on web', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: '',
          isWeb: false,
          baseUri: Uri.parse('http://localhost'),
        );

        expect(result, 'http://localhost:8055');
      });

      test('should fall back to localhost when not on web with arbitrary baseUri', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: '',
          isWeb: false,
          baseUri: Uri.parse('https://ignored.example.com'),
        );

        expect(result, 'http://localhost:8055');
      });
    });

    group('trailing slash stripping', () {
      test('should strip trailing slash from localhost fallback URL when applicable', () {
        // The localhost fallback itself is hard-coded without slash, but
        // if a dart-define URL ending with slash is provided, it is stripped.
        final result = resolveDirectusUrl(
          dartDefineUrl: 'http://localhost:8055/',
          isWeb: false,
          baseUri: Uri.parse('http://localhost'),
        );

        expect(result, 'http://localhost:8055');
      });

      test('should strip trailing slash from web-derived URL when applicable', () {
        // The derived url is constructed as 'https://api.$host' — no trailing slash
        // is ever added by the function. Ensure that a dart-define with trailing
        // slash is still cleaned.
        final result = resolveDirectusUrl(
          dartDefineUrl: 'https://api.example.com/',
          isWeb: true,
          baseUri: Uri.parse('https://app.example.com'),
        );

        expect(result, 'https://api.example.com');
      });
    });

    group('default fallback value', () {
      test('should default to http://localhost:8055 as documented in CLAUDE.md', () {
        final result = resolveDirectusUrl(
          dartDefineUrl: '',
          isWeb: false,
          baseUri: Uri.parse('http://localhost'),
        );

        expect(result, 'http://localhost:8055');
      });
    });
  });
}
