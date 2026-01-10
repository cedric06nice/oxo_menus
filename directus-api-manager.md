# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Dart package for communicating with Directus servers via REST API and WebSockets. The package enables model generation through reflection, automatic token management, CRUD operations, real-time subscriptions, and a sophisticated caching system.

## Development Commands

### Running Tests
```bash
# Run all tests
dart test

# Run a specific test file
dart test test/directus_api_manager_base_test.dart

# Run a specific test by name pattern
dart test --name "test_name_pattern"
```

### Code Generation
The package uses `reflectable` for code generation. After creating or modifying model classes with `@DirectusCollection()` annotation:

```bash
# Generate reflectable code for the example
dart run build_runner build lib

# Clean and rebuild
dart run build_runner clean
dart run build_runner build lib
```

**Important:** Generated `.reflectable.dart` files should NOT be committed to git (already in `.gitignore`).

### Linting
```bash
# Analyze code
dart analyze
```

## Architecture Overview

### Core Components

**DirectusApiManager** ([lib/src/directus_api_manager_base.dart](lib/src/directus_api_manager_base.dart))
- Central entry point implementing `IDirectusApiManager`
- Manages authentication, token refresh, HTTP requests, caching
- Singleton-like pattern recommended (create once per app)
- Holds cached current user and WebSocket subscriptions
- Uses mutex for request synchronization

**DirectusAPI** ([lib/src/directus_api.dart](lib/src/directus_api.dart))
- Low-level HTTP operations and token management
- Handles automatic token refresh when `shouldRefreshToken` is true
- Constructs REST endpoints and manages request/response flow

**DirectusWebSocket** ([lib/src/directus_websocket.dart](lib/src/directus_websocket.dart))
- WebSocket connection management with automatic reconnection
- Handles authentication over WebSocket
- Manages keep-alive pings and subscription lifecycle

### Data Model Hierarchy

**DirectusData** ([lib/src/model/directus_data.dart](lib/src/model/directus_data.dart))
- Base class for all Directus entities
- Tracks raw received data and updated properties via `_rawReceivedData` and `updatedProperties` maps
- Provides `getValue(forKey:)` and `setValue(_, forKey:)` for property access
- `needsSaving` indicates if there are uncommitted changes
- `id` can be String or Int (use `intId` for integer IDs)

**DirectusItem** ([lib/src/model/directus_item.dart](lib/src/model/directus_item.dart))
- Extends `DirectusData` for custom collection models
- User models should extend this class and use `@DirectusCollection()` + `@CollectionMetadata(endpointName: "collection_name")`
- Must implement constructor: `ModelName(super.rawReceivedData);`
- Must implement: `ModelName.newItem() : super.newItem();` for creating new items

**DirectusUser** ([lib/src/model/directus_user.dart](lib/src/model/directus_user.dart))
- Special model for Directus users
- Extends `DirectusData` with user-specific fields (email, first_name, last_name, role, etc.)

**DirectusFile** ([lib/src/model/directus_file.dart](lib/src/model/directus_file.dart))
- Represents files stored in Directus
- Provides `buildFileUrl()` to construct download URLs

### Filtering System

**Filter Classes** ([lib/src/filter.dart](lib/src/filter.dart))
- `PropertyFilter`: Field-based filtering with operators (equals, contains, greaterThan, between, isNull, etc.)
- `LogicalOperatorFilter`: Combines filters with AND/OR/NOT logic
- `RelationFilter`: Filter by related items (supports M2M relations)
- `GeoFilter`: Geospatial filtering using GeoJSON polygons

**GeoJsonPolygon** ([lib/src/geo_json_polygon.dart](lib/src/geo_json_polygon.dart))
- Three constructors: `rectangle()`, `polygon()`, `squareFromCenter()`
- Automatically closes polygons for valid GeoJSON

### Caching System

**ILocalDirectusCacheInterface** ([lib/src/directus_api_manager_base.dart](lib/src/directus_api_manager_base.dart))
- Interface for cache implementations
- Methods: `getCacheEntry`, `setCacheEntry`, `removeCacheEntry`, `removeCacheEntriesWithTag`, `clearCache`

**JsonCacheEngine** ([lib/src/cache/json_cache_engine.dart](lib/src/cache/json_cache_engine.dart))
- Persistent JSON file-based cache in specified folder

**MemoryCacheEngine** ([lib/src/cache/memory_cache_engine.dart](lib/src/cache/memory_cache_engine.dart))
- In-memory cache, cleared on app restart

**Cache Parameters:**
All read operations support:
- `canUseCacheForResponse`: Use cached data if valid and not expired
- `maxCacheAge`: Duration before cache is considered stale (default: 1 day)
- `canSaveResponseToCache`: Whether to save response to cache
- `canUseOldCachedResponseAsFallback`: Use expired cache if network fails
- `requestIdentifier`: Custom cache key
- `extraTags`: Tags for batch invalidation

**Automatic Cache Invalidation:**
- Create operations → invalidate list caches for that type
- Update operations → invalidate specific item and list caches
- Delete operations → invalidate specific item and list caches
- Use `extraTagsToClear` parameter in write operations for custom invalidation

### WebSocket Subscriptions

**DirectusWebSocketSubscription** ([lib/src/directus_websocket_subscription.dart](lib/src/directus_websocket_subscription.dart))
- Represents a subscription to server events (create, update, delete)
- Requires unique `uid` and at least one callback: `onCreate`, `onUpdate`, `onDelete`
- Supports filter, sort, limit, offset parameters
- Start with `apiManager.startWebsocketSubscription(subscription)`
- Stop with `apiManager.stopWebsocketSubscription(subscription.uid)`

### Annotations and Reflection

**MetadataGenerator** ([lib/src/metadata_generator.dart](lib/src/metadata_generator.dart))
- Uses `reflectable` to discover collection endpoint names
- Maps Dart classes to Directus collection names via `@CollectionMetadata(endpointName: "...")`

**Annotations** ([lib/src/annotations.dart](lib/src/annotations.dart))
- `@DirectusCollection()`: Marks classes for reflection
- `@CollectionMetadata(endpointName: "...")`: Specifies Directus collection name

## Key Patterns

### Model Definition
```dart
@DirectusCollection()
@CollectionMetadata(endpointName: "player")
class PlayerDirectusModel extends DirectusItem {
  PlayerDirectusModel(super.rawReceivedData);
  PlayerDirectusModel.newItem() : super.newItem();

  String get nickname => getValue(forKey: "nickname");
  int? get bestScore => getValue(forKey: "best_score");
  set bestScore(int? value) => setValue(value, forKey: "best_score");
}
```

### Initialization
Always call `initializeReflectable()` before using the API:
```dart
void main() {
  initializeReflectable();
  final apiManager = DirectusApiManager(baseURL: "http://...");
}
```

### Error Handling
`DirectusApiError` ([lib/src/model/directus_api_error.dart](lib/src/model/directus_api_error.dart)) provides methods to extract error information from failed API responses.

### Authentication Flow
1. `loginDirectusUser(email, password)` returns `DirectusLoginResult`
2. Check `result.type` for: `success`, `invalidCredentials`, `invalidOTP`, `error`
3. If `invalidOTP`, call `loginDirectusUserWithOtp(email, password, otp)`
4. All subsequent requests automatically use the access token

## Testing

Tests use mocks extensively:
- `MockDirectusApiManager` ([lib/test/mock_directus_api_manager.dart](lib/test/mock_directus_api_manager.dart))
- `MockCacheEngine` ([lib/test/mock_cache_engine.dart](lib/test/mock_cache_engine.dart))
- `MockHTTPClient` ([test/mock/mock_http_client.dart](test/mock/mock_http_client.dart))
- `MockDirectusApi` ([test/mock/mock_directus_api.dart](test/mock/mock_directus_api.dart))

Each test file has a corresponding `.reflectable.dart` file that must be imported.

## Important Notes

- The `_requestLock` mutex in DirectusApiManager serializes concurrent requests to prevent race conditions with token refresh
- WebSocket connections automatically handle reconnection and re-authentication
- Property keys in `getValue`/`setValue` must match exactly the field names in Directus (case-sensitive)
- `SortProperty` ([lib/src/sort_property.dart](lib/src/sort_property.dart)) controls result ordering in queries
- Cache entries use tags for flexible invalidation strategies beyond automatic behavior
