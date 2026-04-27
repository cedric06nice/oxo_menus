import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/route_config.dart';
import 'package:oxo_menus/core/routing/route_information_parser.dart';

void main() {
  group('RouteConfig', () {
    test('UnknownRouteConfig holds the original URI', () {
      final uri = Uri.parse('/app/something/123?x=1');
      final config = UnknownRouteConfig(uri);

      expect(config.uri, uri);
    });

    test('UnknownRouteConfig equality compares URIs', () {
      final a = UnknownRouteConfig(Uri.parse('/app/x'));
      final b = UnknownRouteConfig(Uri.parse('/app/x'));
      final c = UnknownRouteConfig(Uri.parse('/app/y'));

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('LoginRouteConfig is a singleton-equal value', () {
      const a = LoginRouteConfig();
      const b = LoginRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('AppRouteInformationParser', () {
    final parser = AppRouteInformationParser();

    test('parses /app/login into LoginRouteConfig', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/app/login')),
      );

      expect(config, const LoginRouteConfig());
    });

    test('parses an unmigrated /app/* URI into UnknownRouteConfig', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/app/settings')),
      );

      expect(config, isA<UnknownRouteConfig>());
      expect(config, UnknownRouteConfig(Uri.parse('/app/settings')));
    });

    test('round-trips an UnknownRouteConfig back to the same URI', () async {
      final original = Uri.parse('/app/menus/42?foo=bar');
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: original),
      );
      final restored = parser.restoreRouteInformation(config);

      expect(restored, isNotNull);
      expect(restored!.uri, original);
    });

    test('round-trips a LoginRouteConfig to /app/login', () {
      final restored = parser.restoreRouteInformation(const LoginRouteConfig());

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/login');
    });

    test('handles root path', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/')),
      );

      expect(config, isA<UnknownRouteConfig>());
      expect((config as UnknownRouteConfig).uri.path, '/');
    });
  });
}
