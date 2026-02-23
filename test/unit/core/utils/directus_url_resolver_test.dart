import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/utils/directus_url_resolver.dart';

void main() {
  group('resolveDirectusUrl', () {
    test('returns explicit URL when dart-define is provided', () {
      final result = resolveDirectusUrl(
        dartDefineUrl: 'https://api.example.com',
        isWeb: false,
        baseUri: Uri.parse('http://localhost'),
      );
      expect(result, 'https://api.example.com');
    });

    test('returns explicit URL even on web with real hostname', () {
      final result = resolveDirectusUrl(
        dartDefineUrl: 'https://custom-api.example.com',
        isWeb: true,
        baseUri: Uri.parse('https://oxo-menus-dev.example.com'),
      );
      expect(result, 'https://custom-api.example.com');
    });

    test('derives API URL from hostname on web when no URL configured', () {
      final result = resolveDirectusUrl(
        dartDefineUrl: '',
        isWeb: true,
        baseUri: Uri.parse('https://oxo-menus-dev.example.com'),
      );
      expect(result, 'https://api.oxo-menus-dev.example.com');
    });

    test('falls back to localhost on web when hostname is localhost', () {
      final result = resolveDirectusUrl(
        dartDefineUrl: '',
        isWeb: true,
        baseUri: Uri.parse('http://localhost:8080'),
      );
      expect(result, 'http://localhost:8055');
    });

    test('falls back to localhost when not on web', () {
      final result = resolveDirectusUrl(
        dartDefineUrl: '',
        isWeb: false,
        baseUri: Uri.parse('http://localhost'),
      );
      expect(result, 'http://localhost:8055');
    });

    test('falls back to localhost on web when host is empty', () {
      final result = resolveDirectusUrl(
        dartDefineUrl: '',
        isWeb: true,
        baseUri: Uri(),
      );
      expect(result, 'http://localhost:8055');
    });
  });
}
