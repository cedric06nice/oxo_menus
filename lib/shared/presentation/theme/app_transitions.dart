import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// Custom page transitions for go_router routes.
///
/// - Web: fade transition (instant feel)
/// - Apple: CupertinoPageRoute-style slide
/// - Android: Material fade-through
class AppTransitions {
  AppTransitions._();

  /// Returns a [CustomTransitionPage] with platform-appropriate animation.
  static CustomTransitionPage<T> buildPage<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    if (kIsWeb) {
      return _fadeTransition(state: state, child: child);
    }

    if (isApplePlatform(context)) {
      return _cupertinoSlideTransition(state: state, child: child);
    }

    return _fadeTransition(state: state, child: child);
  }

  static CustomTransitionPage<T> _fadeTransition<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static CustomTransitionPage<T> _cupertinoSlideTransition<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return CupertinoPageTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondaryAnimation,
          linearTransition: false,
          child: child,
        );
      },
    );
  }
}
