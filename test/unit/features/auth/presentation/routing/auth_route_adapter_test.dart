import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/auth/presentation/routing/forgot_password_router.dart';
import 'package:oxo_menus/features/auth/presentation/routing/auth_route_adapter.dart';
import 'package:oxo_menus/features/auth/presentation/routing/login_router.dart';
import 'package:oxo_menus/features/auth/presentation/routing/reset_password_router.dart';

class _RecordingRouteNavigator implements RouteNavigator {
  final List<({String location, Object? extra})> calls = [];

  @override
  void go(String location, {Object? extra}) {
    calls.add((location: location, extra: extra));
  }
}

void main() {
  group('AuthRouteAdapter', () {
    late _RecordingRouteNavigator navigator;
    late AuthRouteAdapter router;

    setUp(() {
      navigator = _RecordingRouteNavigator();
      router = AuthRouteAdapter(navigator);
    });

    test(
      'implements LoginRouter, ForgotPasswordRouter and ResetPasswordRouter',
      () {
        expect(router, isA<LoginRouter>());
        expect(router, isA<ForgotPasswordRouter>());
        expect(router, isA<ResetPasswordRouter>());
      },
    );

    group('LoginRouter contract', () {
      test('goToHomeAfterLogin navigates to AppRoutes.home', () {
        router.goToHomeAfterLogin();

        expect(navigator.calls, hasLength(1));
        expect(navigator.calls.single.location, AppRoutes.home);
        expect(navigator.calls.single.extra, isNull);
      });

      test('goToForgotPassword navigates to AppRoutes.forgotPassword', () {
        router.goToForgotPassword();

        expect(navigator.calls, hasLength(1));
        expect(navigator.calls.single.location, AppRoutes.forgotPassword);
      });
    });

    group('ForgotPasswordRouter contract', () {
      test('goBackToLogin navigates to AppRoutes.login', () {
        router.goBackToLogin();

        expect(navigator.calls, hasLength(1));
        expect(navigator.calls.single.location, AppRoutes.login);
      });
    });

    group('ResetPasswordRouter contract', () {
      test('goToLogin navigates to AppRoutes.login', () {
        router.goToLogin();

        expect(navigator.calls, hasLength(1));
        expect(navigator.calls.single.location, AppRoutes.login);
      });

      test('goToForgotPassword navigates to AppRoutes.forgotPassword', () {
        // Same method name as on LoginRouter; verifies the single
        // implementation services both interfaces.
        router.goToForgotPassword();

        expect(navigator.calls, hasLength(1));
        expect(navigator.calls.single.location, AppRoutes.forgotPassword);
      });
    });

    test('subsequent navigations record in order', () {
      router.goToForgotPassword();
      router.goBackToLogin();
      router.goToHomeAfterLogin();

      expect(navigator.calls.map((c) => c.location).toList(), <String>[
        AppRoutes.forgotPassword,
        AppRoutes.login,
        AppRoutes.home,
      ]);
    });
  });
}
