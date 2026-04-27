import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/core/utils/directus_url_resolver.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/repositories/area_repository_impl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:oxo_menus/shared/data/repositories/auth_repository_impl.dart';
import 'package:oxo_menus/features/connectivity/data/repositories/connectivity_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/shared/data/repositories/file_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_bundle_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/size_repository_impl.dart';
import 'package:oxo_menus/features/collaboration/data/repositories/menu_subscription_repository_impl.dart';
import 'package:oxo_menus/features/collaboration/data/repositories/presence_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/shared/data/repositories/asset_loader_repository_impl.dart';
import 'package:oxo_menus/shared/domain/repositories/area_repository.dart';
import 'package:oxo_menus/shared/domain/repositories/asset_loader_repository.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/features/collaboration/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/features/collaboration/domain/repositories/presence_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/shared/domain/repositories/file_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

/// Directus base URL provider
///
/// This can be overridden in tests or when launching the app with different environments.
/// Uses [resolveDirectusUrl] to derive the API URL from the hostname on web
/// when no explicit URL is configured via `--dart-define=DIRECTUS_URL`.
final directusBaseUrlProvider = Provider<String>((ref) {
  const dartDefineUrl = String.fromEnvironment('DIRECTUS_URL');
  return resolveDirectusUrl(
    dartDefineUrl: dartDefineUrl,
    isWeb: kIsWeb,
    baseUri: Uri.base,
  );
});

/// Directus access token provider
///
/// Exposes the current access token from the DirectusDataSource for
/// authenticated asset requests (e.g. Image.network with Bearer headers)
final directusAccessTokenProvider = Provider<String?>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return dataSource.currentAccessToken;
});

/// Directus data source provider
///
/// Provides the DirectusDataSource instance for communicating with the Directus backend
final directusDataSourceProvider = Provider<DirectusDataSource>((ref) {
  final baseUrl = ref.watch(directusBaseUrlProvider);
  return DirectusDataSource(baseUrl: baseUrl);
});

/// Area repository provider
///
/// Provides the AreaRepository implementation for fetching available areas
final areaRepositoryProvider = Provider<AreaRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return AreaRepositoryImpl(dataSource: dataSource);
});

/// Menu repository provider
///
/// Provides the MenuRepository implementation for managing menu entities
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return MenuRepositoryImpl(dataSource: dataSource);
});

/// Page repository provider
///
/// Provides the PageRepository implementation for managing page entities
final pageRepositoryProvider = Provider<PageRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return PageRepositoryImpl(dataSource: dataSource);
});

/// Container repository provider
///
/// Provides the ContainerRepository implementation for managing container entities
final containerRepositoryProvider = Provider<ContainerRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return ContainerRepositoryImpl(dataSource: dataSource);
});

/// Column repository provider
///
/// Provides the ColumnRepository implementation for managing column entities
final columnRepositoryProvider = Provider<ColumnRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return ColumnRepositoryImpl(dataSource: dataSource);
});

/// Widget repository provider
///
/// Provides the WidgetRepository implementation for managing widget instances
final widgetRepositoryProvider = Provider<WidgetRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return WidgetRepositoryImpl(dataSource: dataSource);
});

/// Auth repository provider
///
/// Provides the AuthRepository implementation for managing authentication
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return AuthRepositoryImpl(dataSource: dataSource);
});

/// Size repository provider
///
/// Provides the SizeRepository implementation for fetching available page sizes
final sizeRepositoryProvider = Provider<SizeRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return SizeRepositoryImpl(dataSource: dataSource);
});

/// Menu bundle repository provider
///
/// Provides the MenuBundleRepository implementation used by the admin
/// "Exportable menus" feature and the publish-bundles hook.
final menuBundleRepositoryProvider = Provider<MenuBundleRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return MenuBundleRepositoryImpl(dataSource: dataSource);
});

/// File repository provider
///
/// Provides the FileRepository implementation for managing file uploads
final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return FileRepositoryImpl(dataSource);
});

/// Image data provider
///
/// Downloads image bytes via [FileRepository.downloadFile] so that
/// authentication headers are preserved across HTTP redirects.
/// Used by ImageWidget and ImageEditDialog instead of Image.network.
final imageDataProvider = FutureProvider.family<Uint8List, String>((
  ref,
  fileId,
) async {
  final repo = ref.watch(fileRepositoryProvider);
  final result = await repo.downloadFile(fileId);
  return switch (result) {
    Success(:final value) => value,
    Failure(:final error) => throw error,
  };
});

/// Menu subscription repository provider
///
/// Provides real-time WebSocket subscriptions for menu change events
final menuSubscriptionRepositoryProvider = Provider<MenuSubscriptionRepository>(
  (ref) {
    final dataSource = ref.watch(directusDataSourceProvider);
    return MenuSubscriptionRepositoryImpl(dataSource: dataSource);
  },
);

/// Presence repository provider
///
/// Provides user presence tracking for collaborative menu editing
final presenceRepositoryProvider = Provider<PresenceRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return PresenceRepositoryImpl(dataSource: dataSource);
});

/// Asset loader repository provider
///
/// Provides the AssetLoaderRepository implementation for loading platform assets
final assetLoaderRepositoryProvider = Provider<AssetLoaderRepository>((ref) {
  return AssetLoaderRepositoryImpl();
});

/// Connectivity repository provider
///
/// Provides real-time connectivity monitoring.
/// On web, DNS probe is skipped (dart:io unavailable).
final connectivityRepositoryProvider = Provider<ConnectivityRepository>((ref) {
  return ConnectivityRepositoryImpl(
    connectivity: Connectivity(),
    dnsProbe: kIsWeb ? () async => true : null,
  );
});
