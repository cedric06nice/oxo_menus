import 'dart:convert';
import 'dart:typed_data';
import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:http/http.dart' as http;
import 'package:oxo_menus/data/datasources/secure_token_storage.dart';

/// Wrapper for Directus backend communication using directus_api_manager package
///
/// This class adapts the directus_api_manager's DirectusApiManager to our repository
/// interface, providing a clean abstraction for CRUD operations and authentication.
///
/// Uses the adapter pattern to convert between our `Map<String, dynamic>` interface
/// and directus_api_manager's `GenericDirectusItem` objects.
class DirectusDataSource {
  final DirectusApiManager _apiManager;
  final SecureTokenStorage _tokenStorage;
  final String _baseUrl;

  // Internal token state for restored sessions
  String? _restoredAccessToken;

  DirectusDataSource({
    required String baseUrl,
    SecureTokenStorage? tokenStorage,
  }) : _apiManager = DirectusApiManager(baseURL: baseUrl),
       _tokenStorage = tokenStorage ?? SecureTokenStorage(),
       _baseUrl = baseUrl;

  /// Get the current access token (from api manager or restored session)
  String? get _currentAccessToken =>
      _apiManager.accessToken ?? _restoredAccessToken;

  // ===== Authentication Methods =====

  /// Login with email and password
  ///
  /// Returns the full login response including user data and tokens
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _apiManager.loginDirectusUser(email, password);

    switch (result.type) {
      case DirectusLoginResultType.success:
        // Save tokens to secure storage
        final accessToken = _apiManager.accessToken;
        final refreshToken = _apiManager.refreshToken;
        if (accessToken != null && refreshToken != null) {
          await _tokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }

        // Get current user data with expanded role relation
        final userData = await _fetchUserWithRole();

        return {
          'user': userData,
          'access_token': accessToken,
          'refresh_token': refreshToken,
        };

      case DirectusLoginResultType.invalidCredentials:
        throw DirectusException(
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
        );

      case DirectusLoginResultType.invalidOTP:
        throw DirectusException(
          code: 'INVALID_OTP',
          message: 'OTP required or invalid',
        );

      case DirectusLoginResultType.error:
        throw DirectusException(
          code: 'LOGIN_ERROR',
          message: result.message ?? 'Login failed',
        );
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    await _apiManager.logoutDirectusUser();
    await _tokenStorage.clearTokens();
    _restoredAccessToken = null;
  }

  /// Refresh the current session tokens
  ///
  /// Uses the stored refresh token to obtain new access and refresh tokens
  /// from the Directus `/auth/refresh` endpoint.
  /// Throws [DirectusException] if the refresh fails.
  Future<void> refreshSession() async {
    final refreshToken =
        _apiManager.refreshToken ?? await _tokenStorage.getRefreshToken();

    if (refreshToken == null) {
      throw DirectusException(
        code: 'TOKEN_EXPIRED',
        message: 'No refresh token available',
      );
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh_token': refreshToken, 'mode': 'json'}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final tokenData = data['data'] as Map<String, dynamic>?;
      final newAccessToken = tokenData?['access_token'] as String?;
      final newRefreshToken = tokenData?['refresh_token'] as String?;

      if (newAccessToken != null && newRefreshToken != null) {
        await _tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        _restoredAccessToken = newAccessToken;
        return;
      }
    }

    // Refresh failed — clear stale tokens
    await _tokenStorage.clearTokens();
    _restoredAccessToken = null;
    throw DirectusException(
      code: 'TOKEN_EXPIRED',
      message: 'Failed to refresh session',
    );
  }

  /// Try to restore session from stored tokens
  ///
  /// Returns true if session was restored successfully, false otherwise
  Future<bool> tryRestoreSession() async {
    final hasTokens = await _tokenStorage.hasTokens();
    if (!hasTokens) {
      return false;
    }

    try {
      await refreshSession();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get the current authenticated user with expanded role
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _fetchUserWithRole();
  }

  /// Fetch current user with role relation expanded
  ///
  /// Makes a direct HTTP request to /users/me with fields parameter to expand
  /// the role relation and get the role name instead of just the UUID
  Future<Map<String, dynamic>> _fetchUserWithRole() async {
    final accessToken = _currentAccessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw DirectusException(
        code: 'NOT_AUTHENTICATED',
        message: 'No access token available',
      );
    }

    // Fetch user with expanded role using Directus API
    // The fields parameter tells Directus to expand the role relation
    final url = Uri.parse(
      '$_baseUrl/users/me?fields=id,email,first_name,last_name,avatar,role.name',
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      // Token might be expired, clear stored tokens
      await _tokenStorage.clearTokens();
      _restoredAccessToken = null;
      throw DirectusException(
        code: 'NOT_AUTHENTICATED',
        message: 'Authentication required',
      );
    } else {
      throw DirectusException(
        code: 'FETCH_USER_FAILED',
        message: 'Failed to fetch user: ${response.statusCode}',
      );
    }
  }

  // ===== CRUD Operations =====

  /// Get a single item by ID from a collection
  Future<Map<String, dynamic>> getItem<T extends DirectusItem>(
    int id, {
    List<String>? fields,
  }) async {
    final item = await _apiManager.getSpecificItem<T>(
      id: id.toString(),
      fields: fields?.join(','),
    );

    if (item == null) {
      throw DirectusException(code: 'NOT_FOUND', message: 'Item not found');
    }

    return item.getRawData();
  }

  /// Get multiple items from a collection
  Future<List<Map<String, dynamic>>> getItems<T extends DirectusItem>({
    Map<String, dynamic>? filter,
    List<String>? fields,
    List<String>? sort,
    int? limit,
    int? offset,
  }) async {
    // Convert our filter format to directus_api_manager filter format
    Filter? directusFilter;
    if (filter != null) {
      directusFilter = _convertFilterToDirectusFilter(filter);
    }

    // Convert sort strings to SortProperty objects
    List<SortProperty>? sortProperties;
    if (sort != null) {
      sortProperties = sort.map((sortStr) {
        final isDescending = sortStr.startsWith('-');
        final fieldName = isDescending ? sortStr.substring(1) : sortStr;
        return SortProperty(fieldName, ascending: !isDescending);
      }).toList();
    }

    final items = await _apiManager.findListOfItems<T>(
      filter: directusFilter,
      fields: fields?.join(','),
      sortBy: sortProperties,
      limit: limit,
      offset: offset,
    );

    return items.map((item) => item.getRawData()).toList();
  }

  /// Create a new item in a collection
  Future<Map<String, dynamic>> createItem<T extends DirectusItem>(
    T newItem,
  ) async {
    final result = await _apiManager.createNewItem<T>(objectToCreate: newItem);

    if (!result.isSuccess || result.createdItem == null) {
      throw DirectusException(
        code: 'CREATE_FAILED',
        message: result.error?.messageFromBody ?? 'Failed to create item',
      );
    }

    return result.createdItem!.getRawData();
  }

  /// Update an existing item in a collection
  Future<Map<String, dynamic>> updateItem<T extends DirectusItem>(
    T itemToUpdate,
  ) async {
    final updated = await _apiManager.updateItem<T>(
      objectToUpdate: itemToUpdate,
    );

    return updated.getRawData();
  }

  /// Delete an item from a collection
  Future<void> deleteItem<T extends DirectusItem>(int id) async {
    final success = await _apiManager.deleteItem<T>(objectId: id.toString());

    if (!success) {
      throw DirectusException(
        code: 'DELETE_FAILED',
        message: 'Failed to delete item',
      );
    }
  }

  // ===== File Operations =====

  /// Upload a file to Directus and return the file ID
  Future<String> uploadFile(Uint8List bytes, String filename) async {
    final accessToken = _currentAccessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw DirectusException(
        code: 'NOT_AUTHENTICATED',
        message: 'No access token available',
      );
    }

    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/files'));

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final fileData = data['data'] as Map<String, dynamic>?;
      final fileId = fileData?['id'] as String?;

      if (fileId != null) {
        return fileId;
      } else {
        throw DirectusException(
          code: 'UPLOAD_FAILED',
          message: 'File uploaded but no ID returned',
        );
      }
    } else if (response.statusCode == 401) {
      throw DirectusException(
        code: 'NOT_AUTHENTICATED',
        message: 'Authentication required',
      );
    } else {
      throw DirectusException(
        code: 'UPLOAD_FAILED',
        message: 'Failed to upload file: ${response.statusCode}',
      );
    }
  }

  // ===== Helper Methods =====

  /// Convert our filter format to directus_api_manager Filter format
  ///
  /// Our format: {'field': {'_operator': value}}
  /// Example: {'menu_id': {'_eq': 'menu-1'}}
  Filter? _convertFilterToDirectusFilter(Map<String, dynamic> filter) {
    final filters = <Filter>[];

    for (final entry in filter.entries) {
      final fieldName = entry.key;
      final filterValue = entry.value;

      if (filterValue is Map<String, dynamic>) {
        for (final operatorEntry in filterValue.entries) {
          final operator = operatorEntry.key;
          final value = operatorEntry.value;

          final propertyFilter = _createPropertyFilter(
            fieldName,
            operator,
            value,
          );

          if (propertyFilter != null) {
            filters.add(propertyFilter);
          }
        }
      }
    }

    if (filters.isEmpty) {
      return null;
    }

    // If multiple filters, combine with AND
    if (filters.length == 1) {
      return filters.first;
    }

    return LogicalOperatorFilter(
      operator: LogicalOperator.and,
      children: filters,
    );
  }

  /// Create a PropertyFilter from field name, operator, and value
  PropertyFilter? _createPropertyFilter(
    String fieldName,
    String operator,
    dynamic value,
  ) {
    switch (operator) {
      case '_eq':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.equals,
          value: value,
        );
      case '_neq':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.notEqual,
          value: value,
        );
      case '_lt':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.lessThan,
          value: value,
        );
      case '_lte':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.lessThanOrEqual,
          value: value,
        );
      case '_gt':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.greaterThan,
          value: value,
        );
      case '_gte':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.greaterThanOrEqual,
          value: value,
        );
      case '_in':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.oneOf,
          value: value,
        );
      case '_nin':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.notOneOf,
          value: value,
        );
      case '_null':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.isNull,
          value: null,
        );
      case '_nnull':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.isNotNull,
          value: null,
        );
      case '_contains':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.contains,
          value: value,
        );
      case '_ncontains':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.notContains,
          value: value,
        );
      case '_starts_with':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.startWith,
          value: value,
        );
      case '_nstarts_with':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.notStartWith,
          value: value,
        );
      case '_ends_with':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.endWith,
          value: value,
        );
      case '_nends_with':
        return PropertyFilter(
          field: fieldName,
          operator: FilterOperator.notEndWith,
          value: value,
        );
      case '_between':
        if (value is List && value.length == 2) {
          return PropertyFilter(
            field: fieldName,
            operator: FilterOperator.between,
            value: value,
          );
        }
        return null;
      case '_nbetween':
        if (value is List && value.length == 2) {
          return PropertyFilter(
            field: fieldName,
            operator: FilterOperator.notBetween,
            value: value,
          );
        }
        return null;
      default:
        // Unsupported operator
        return null;
    }
  }
}

/// Custom exception class for Directus errors
class DirectusException implements Exception {
  final String code;
  final String message;

  DirectusException({required this.code, required this.message});

  @override
  String toString() => 'DirectusException: $code - $message';
}
