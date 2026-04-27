import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/routing/app_router.dart';
import 'package:oxo_menus/core/utils/directus_url_resolver.dart';
import 'package:oxo_menus/features/connectivity/data/repositories/connectivity_repository_impl.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/repositories/auth_repository_impl.dart';
import 'package:oxo_menus/shared/presentation/providers/app_lifecycle_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/shared/presentation/theme/app_theme.dart';
import 'main.reflectable.dart';

void main() {
  initializeReflectable();
  usePathUrlStrategy();

  const dartDefineUrl = String.fromEnvironment('DIRECTUS_URL');
  final baseUrl = resolveDirectusUrl(
    dartDefineUrl: dartDefineUrl,
    isWeb: kIsWeb,
    baseUri: Uri.base,
  );
  final dataSource = DirectusDataSource(baseUrl: baseUrl);
  final authGateway = AuthGateway(
    repository: AuthRepositoryImpl(dataSource: dataSource),
  );
  final connectivityGateway = ConnectivityGateway(
    repository: ConnectivityRepositoryImpl(
      connectivity: Connectivity(),
      dnsProbe: kIsWeb ? () async => true : null,
    ),
  );
  final appContainer = AppContainer(
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    directusDataSource: dataSource,
  );

  runApp(
    ProviderScope(
      overrides: [
        directusDataSourceProvider.overrideWithValue(dataSource),
        authGatewayProvider.overrideWithValue(authGateway),
        appContainerProvider.overrideWithValue(appContainer),
      ],
      child: const MyApp(),
    ),
  );
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
