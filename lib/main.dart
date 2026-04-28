import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/di/app_scope.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/core/gateways/app_version_gateway.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/routing/app_router.dart';
import 'package:oxo_menus/core/routing/oxo_router.dart';
import 'package:oxo_menus/core/utils/directus_url_resolver.dart';
import 'package:oxo_menus/features/connectivity/data/repositories/connectivity_repository_impl.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/repositories/auth_repository_impl.dart';
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
  final adminViewAsUserGateway = AdminViewAsUserGateway();
  final appContainer = AppContainer(
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    appVersionGateway: PackageInfoAppVersionGateway(),
    adminViewAsUserGateway: adminViewAsUserGateway,
    directusDataSource: dataSource,
    directusBaseUrl: baseUrl,
  );

  runApp(AppScope(container: appContainer, child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  OxoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= AppRouter(scope: AppScope.of(context)).build();
  }

  @override
  void dispose() {
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OxoRouterScope(
      router: _router!,
      child: MaterialApp.router(
        title: 'OXO Menus',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: _router!,
      ),
    );
  }
}
