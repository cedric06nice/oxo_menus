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

    test('ForgotPasswordRouteConfig is a singleton-equal value', () {
      const a = ForgotPasswordRouteConfig();
      const b = ForgotPasswordRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('LoginRouteConfig and ForgotPasswordRouteConfig are not equal', () {
      expect(
        const LoginRouteConfig(),
        isNot(const ForgotPasswordRouteConfig()),
      );
    });

    test('HomeRouteConfig is a singleton-equal value', () {
      const a = HomeRouteConfig();
      const b = HomeRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('HomeRouteConfig is not equal to other migrated configs', () {
      expect(const HomeRouteConfig(), isNot(const LoginRouteConfig()));
      expect(const HomeRouteConfig(), isNot(const ForgotPasswordRouteConfig()));
    });

    test('MenuListRouteConfig is a singleton-equal value', () {
      const a = MenuListRouteConfig();
      const b = MenuListRouteConfig();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('MenuListRouteConfig is not equal to other migrated configs', () {
      expect(const MenuListRouteConfig(), isNot(const HomeRouteConfig()));
      expect(const MenuListRouteConfig(), isNot(const LoginRouteConfig()));
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

    test(
      'parses /app/forgot-password into ForgotPasswordRouteConfig',
      () async {
        final config = await parser.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/app/forgot-password')),
        );

        expect(config, const ForgotPasswordRouteConfig());
      },
    );

    test('round-trips a ForgotPasswordRouteConfig to /app/forgot-password', () {
      final restored = parser.restoreRouteInformation(
        const ForgotPasswordRouteConfig(),
      );

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/forgot-password');
    });

    test('parses /app/home into HomeRouteConfig', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/app/home')),
      );

      expect(config, const HomeRouteConfig());
    });

    test('round-trips a HomeRouteConfig to /app/home', () {
      final restored = parser.restoreRouteInformation(const HomeRouteConfig());

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/home');
    });

    test('parses /app/menus into MenuListRouteConfig', () async {
      final config = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/app/menus')),
      );

      expect(config, const MenuListRouteConfig());
    });

    test('round-trips a MenuListRouteConfig to /app/menus', () {
      final restored = parser.restoreRouteInformation(
        const MenuListRouteConfig(),
      );

      expect(restored, isNotNull);
      expect(restored!.uri.path, '/app/menus');
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
