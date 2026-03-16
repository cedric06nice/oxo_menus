import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:oxo_menus/core/routing/app_router.dart';
import 'package:oxo_menus/presentation/providers/app_lifecycle_provider.dart';
import 'package:oxo_menus/presentation/theme/app_theme.dart';
import 'main.reflectable.dart';

void main() {
  initializeReflectable();
  usePathUrlStrategy();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly init lifecycle observer so it starts tracking immediately
    ref.read(appLifecycleProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'OXO Menus',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
