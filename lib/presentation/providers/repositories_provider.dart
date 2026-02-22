import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/utils/directus_url_resolver.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/repositories/auth_repository_impl.dart';
import 'package:oxo_menus/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/data/repositories/file_repository_impl.dart';
import 'package:oxo_menus/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/data/repositories/size_repository_impl.dart';
import 'package:oxo_menus/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';

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

/// Directus data source provider
///
/// Provides the DirectusDataSource instance for communicating with the Directus backend
final directusDataSourceProvider = Provider<DirectusDataSource>((ref) {
  final baseUrl = ref.watch(directusBaseUrlProvider);
  return DirectusDataSource(baseUrl: baseUrl);
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

/// File repository provider
///
/// Provides the FileRepository implementation for managing file uploads
final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final dataSource = ref.watch(directusDataSourceProvider);
  return FileRepositoryImpl(dataSource);
});
