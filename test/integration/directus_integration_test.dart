import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';
import 'package:oxo_menus/main.reflectable.dart';

/// Integration tests for DirectusDataSource
///
/// These tests require a running Directus instance at http://localhost:8102
/// with the following:
/// - Test account: admin@example.com / password
/// - Collections: menu, page, container, column, widget
///
/// Run with: flutter test test/integration/directus_integration_test.dart
///
/// Skip if Directus is not available

void main() {
  initializeReflectable();
  group('DirectusDataSource Integration Tests', () {
    late DirectusDataSource dataSource;

    setUp(() {
      dataSource = DirectusDataSource(baseUrl: 'http://localhost:8102');
    });

    group('Authentication', () {
      test('should login with valid credentials', () async {
        final response = await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        expect(response['user'], isNotNull);
        expect(response['user'], isA<Map<String, dynamic>>());
        expect(response['access_token'], isNotNull);
        expect(response['refresh_token'], isNotNull);
      }); //, skip: 'Requires Directus running at localhost:8102');

      test('should throw DirectusException for invalid credentials', () async {
        expect(
          () =>
              dataSource.login(email: 'invalid@example.com', password: 'wrong'),
          throwsA(isA<DirectusException>()),
        );
      }); //, skip: 'Requires Directus running at localhost:8102');

      test('should logout successfully', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        // Then logout
        await dataSource.logout();

        // Verify we can't access protected resources
        expect(
          () => dataSource.getCurrentUser(),
          throwsA(isA<DirectusException>()),
        );
      }); //, skip: 'Requires Directus running at localhost:8102');

      test('should get current user after login', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        final user = await dataSource.getCurrentUser();

        expect(user, isNotNull);
        expect(user['email'], 'admin@example.com');
      }); //, skip: 'Requires Directus running at localhost:8102');
    });

    group('CRUD Operations', () {
      test('should fetch menu items', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        final items = await dataSource.getItems<MenuDto>();

        expect(items, isList);
      }); //, skip: 'Requires Directus running at localhost:8102');

      test('should create, update, and delete menu', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        // Create
        MenuDto newMenu = MenuDto.newItem(
          name: 'Test Menu',
          status: 'draft',
          version: '1.0.0',
        );
        final created = await dataSource.createItem<MenuDto>(newMenu);

        expect(created['id'], isNotNull);
        expect(created['name'], 'Test Menu');

        final menuId = created['id'];

        // Update
        final updatedName = MenuDto({
          'id': menuId,
          'name': 'Updated Test Menu',
        });
        final updated = await dataSource.updateItem<MenuDto>(updatedName);

        expect(updated['name'], 'Updated Test Menu');

        // Delete
        await dataSource.deleteItem<MenuDto>(menuId);

        // Verify deletion
        expect(
          () => dataSource.getItem<MenuDto>(menuId),
          throwsA(isA<DirectusException>()),
        );
      }); //, skip: 'Requires Directus running at localhost:8102');

      test('should fetch single item by ID', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        // Create a test item first
        final created = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'Test Menu for Get',
            'status': 'draft',
            'version': '1.0.0',
          }),
        );
        final menuId = created['id'];

        // Fetch by ID
        final fetched = await dataSource.getItem<MenuDto>(menuId);

        expect(fetched['id'], menuId);
        expect(fetched['name'], 'Test Menu for Get');

        // Cleanup
        await dataSource.deleteItem<MenuDto>(menuId);
      }); //, skip: 'Requires Directus running at localhost:8102');

      test('should throw DirectusException when item not found', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        expect(
          () => dataSource.getItem<MenuDto>(-1),
          throwsA(isA<DirectusException>()),
        );
      }); //, skip: 'Requires Directus running at localhost:8102');
    });

    group('Filtering', () {
      test('should filter items with _eq operator', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        // Create test items
        final draft = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'Draft Menu',
            'status': 'draft',
            'version': '1.0.0',
          }),
        );
        final published = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'Published Menu',
            'status': 'published',
            'version': '1.0.0',
          }),
        );

        // Filter for published only
        final items = await dataSource.getItems<MenuDto>(
          filter: {
            'status': {'_eq': 'published'},
          },
        );

        expect(items, isList);
        expect(items.every((item) => item['status'] == 'published'), true);

        // Cleanup
        await dataSource.deleteItem<MenuDto>(draft['id']);
        await dataSource.deleteItem<MenuDto>(published['id']);
      }); //, skip: 'Requires Directus running at localhost:8102');

      test('should filter items with _in operator', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        // Create test items
        final draft = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'Draft Menu',
            'status': 'draft',
            'version': '1.0.0',
          }),
        );
        final published = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'Published Menu',
            'status': 'published',
            'version': '1.0.0',
          }),
        );

        final archived = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'Archived Menu',
            'status': 'archived',
            'version': '1.0.0',
          }),
        );
        // Filter for draft or published
        final items = await dataSource.getItems<MenuDto>(
          filter: {
            'status': {
              '_in': ['draft', 'published'],
            },
          },
        );

        expect(items, isList);
        expect(items.length, greaterThanOrEqualTo(2));
        expect(
          items.every(
            (item) =>
                item['status'] == 'draft' || item['status'] == 'published',
          ),
          true,
        );

        // Cleanup
        await dataSource.deleteItem<MenuDto>(draft['id']);
        await dataSource.deleteItem<MenuDto>(published['id']);
        await dataSource.deleteItem<MenuDto>(archived['id']);
      }); //, skip: 'Requires Directus running at localhost:8102');
    });

    group('Sorting', () {
      test('should sort items ascending', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        // Create test items with different names
        final menu1 = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'C Menu',
            'status': 'draft',
            'version': '1.0.0',
          }),
        );
        final menu2 = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'A Menu',
            'status': 'draft',
            'version': '1.0.0',
          }),
        );

        final menu3 = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'B Menu',
            'status': 'draft',
            'version': '1.0.0',
          }),
        );
        // Fetch with ascending sort
        final items = await dataSource.getItems<MenuDto>(
          sort: ['name'],
          filter: {
            'id': {
              '_in': [menu1['id'], menu2['id'], menu3['id']],
            },
          },
        );

        expect(items.length, 3);
        expect(items[0]['name'], 'A Menu');
        expect(items[1]['name'], 'B Menu');
        expect(items[2]['name'], 'C Menu');

        // Cleanup
        await dataSource.deleteItem<MenuDto>(menu1['id']);
        await dataSource.deleteItem<MenuDto>(menu2['id']);
        await dataSource.deleteItem<MenuDto>(menu3['id']);
      }); //, skip: 'Requires Directus running at localhost:8102');

      test('should sort items descending', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        // Create test items
        final menu1 = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'A Menu',
            'status': 'draft',
            'version': '1.0.0',
          }),
        );
        final menu2 = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'C Menu',
            'status': 'draft',
            'version': '1.0.0',
          }),
        );
        final menu3 = await dataSource.createItem<MenuDto>(
          MenuDto({
            'id': 0,
            'name': 'B Menu',
            'status': 'draft',
            'version': '1.0.0',
          }),
        );
        // Fetch with descending sort
        final items = await dataSource.getItems<MenuDto>(
          sort: ['-name'],
          filter: {
            'id': {
              '_in': [menu1['id'], menu2['id'], menu3['id']],
            },
          },
        );

        expect(items.length, 3);
        expect(items[0]['name'], 'C Menu');
        expect(items[1]['name'], 'B Menu');
        expect(items[2]['name'], 'A Menu');

        // Cleanup
        await dataSource.deleteItem<MenuDto>(menu1['id']);
        await dataSource.deleteItem<MenuDto>(menu2['id']);
        await dataSource.deleteItem<MenuDto>(menu3['id']);
      }); //, skip: 'Requires Directus running at localhost:8102');
    });

    group('Pagination', () {
      test('should limit number of items', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        final items = await dataSource.getItems<MenuDto>(limit: 1);

        expect(items.length, lessThanOrEqualTo(1));
      }); //, skip: 'Requires Directus running at localhost:8102');

      test('should use offset for pagination', () async {
        // Login first
        await dataSource.login(
          email: 'admin@example.com',
          password: 'Admin!123',
        );

        final firstPage = await dataSource.getItems<MenuDto>(
          limit: 1,
          offset: 0,
        );

        final secondPage = await dataSource.getItems<MenuDto>(
          limit: 1,
          offset: 1,
        );

        // Items should be different (if there are at least 2 items)
        if (firstPage.isNotEmpty && secondPage.isNotEmpty) {
          expect(firstPage[0]['id'], isNot(secondPage[0]['id']));
        }
      }); //, skip: 'Requires Directus running at localhost:8102');
    });
  });
}
