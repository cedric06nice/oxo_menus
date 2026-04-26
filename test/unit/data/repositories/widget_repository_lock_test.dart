// Tests for WidgetRepositoryImpl edit-lock operations — manual fakes only.
//
// Focused on:
//   lockForEditing(widgetId, userId)
//   unlockEditing(widgetId)
//
// Lock semantics in the production code (WidgetRepositoryImpl):
//   - lockForEditing: sends a partial WidgetDto with {id, editing_by, editing_since}
//     to updateItem. No pre-fetch is performed, so conflicting lock detection is
//     NOT handled at the repo layer — it is a presentation-layer concern. The
//     repo simply overwrites the field unconditionally.
//   - unlockEditing: sends the same partial WidgetDto with editing_by=null,
//     editing_since=null.
//
// NOTE: The production implementation does NOT check whether the widget is
// already locked by another user before writing; it writes unconditionally.
// This is documented as a known behaviour; conflict detection (if needed) is
// handled at a higher layer.

import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/models/widget_dto.dart';
import 'package:oxo_menus/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';

// ---------------------------------------------------------------------------
// Local fake — updateItem only (lock operations never call other methods)
// ---------------------------------------------------------------------------

class _ErrorSentinel {
  final Object error;
  const _ErrorSentinel(this.error);
}

class _FakeDs implements DirectusDataSource {
  final List<Object> _updateItemQ = [];
  final List<Map<String, dynamic>> updateCalls = [];

  void queueUpdateItem(Map<String, dynamic> r) => _updateItemQ.add(r);
  void queueUpdateItemThrows(Object e) => _updateItemQ.add(_ErrorSentinel(e));

  @override
  Future<Map<String, dynamic>> updateItem<T extends DirectusItem>(
    T itemToUpdate,
  ) async {
    updateCalls.add({'type': T, 'item': itemToUpdate});
    if (_updateItemQ.isEmpty) {
      throw StateError('_FakeDs: no queued response for updateItem<$T>');
    }
    final next = _updateItemQ.removeAt(0);
    if (next is _ErrorSentinel) throw next.error;
    return next as Map<String, dynamic>;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    '_FakeDs: unexpected call to ${invocation.memberName}',
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeDs fakeDs;
  late WidgetRepository repository;

  setUp(() {
    fakeDs = _FakeDs();
    repository = WidgetRepositoryImpl(dataSource: fakeDs);
  });

  // =========================================================================
  // lockForEditing
  // =========================================================================
  group('WidgetRepositoryImpl.lockForEditing', () {
    test('should return Success(null) when lock write succeeds', () async {
      // Arrange
      fakeDs.queueUpdateItem({
        'id': 1,
        'column': 10,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': <String, dynamic>{},
        'editing_by': 'user-abc',
        'editing_since': '2025-01-15T10:30:00.000Z',
      });

      // Act
      final result = await repository.lockForEditing(1, 'user-abc');

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should call updateItem exactly once', () async {
      // Arrange
      fakeDs.queueUpdateItem({
        'id': 1,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': <String, dynamic>{},
      });

      // Act
      await repository.lockForEditing(1, 'user-abc');

      // Assert
      expect(fakeDs.updateCalls.length, 1);
    });

    test('should send editing_by with the provided userId', () async {
      // Arrange
      fakeDs.queueUpdateItem({
        'id': 5,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': <String, dynamic>{},
      });

      // Act
      await repository.lockForEditing(5, 'user-xyz');

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      expect(sentDto.getValue(forKey: 'editing_by'), 'user-xyz');
    });

    test('should send a non-null editing_since timestamp', () async {
      // Arrange
      fakeDs.queueUpdateItem({
        'id': 1,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': <String, dynamic>{},
      });

      // Act
      await repository.lockForEditing(1, 'user-abc');

      // Assert — editing_since must be a non-null ISO 8601 string
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      final editingSince = sentDto.getValue(forKey: 'editing_since');
      expect(editingSince, isNotNull);
      expect(editingSince, isA<String>());
      expect(DateTime.tryParse(editingSince as String), isNotNull);
    });

    test('should send widget id in the DTO (no pre-fetch required)', () async {
      // Arrange
      fakeDs.queueUpdateItem({
        'id': 42,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': <String, dynamic>{},
      });

      // Act
      await repository.lockForEditing(42, 'user-abc');

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      expect(sentDto.intId, 42);
    });

    test(
      'should overwrite lock fields unconditionally (no conflict check)',
      () async {
        // Arrange — simulate a widget already locked by another user;
        // the repo writes without pre-fetch, so it overwrites unconditionally.
        fakeDs.queueUpdateItem({
          'id': 1,
          'type_key': 'dish',
          'version': '1.0.0',
          'index': 0,
          'props_json': <String, dynamic>{},
          'editing_by': 'new-user', // repo wrote this unconditionally
        });

        // Act — lock requested by 'new-user' even though someone else may hold it
        final result = await repository.lockForEditing(1, 'new-user');

        // Assert — repo succeeds; conflict is a higher-layer concern
        expect(result.isSuccess, isTrue);
        final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
        expect(sentDto.getValue(forKey: 'editing_by'), 'new-user');
      },
    );

    test(
      'should return Failure(NotFoundError) when updateItem throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueUpdateItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
        );

        // Act
        final result = await repository.lockForEditing(999, 'user-abc');

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );

    test('should return Failure(UnknownError) on generic exception', () async {
      // Arrange
      fakeDs.queueUpdateItemThrows(Exception('Network failure'));

      // Act
      final result = await repository.lockForEditing(1, 'user-abc');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnknownError>());
    });

    test(
      'should return Failure(UnauthorizedError) when FORBIDDEN is thrown',
      () async {
        // Arrange
        fakeDs.queueUpdateItemThrows(
          DirectusException(code: 'FORBIDDEN', message: 'Access denied'),
        );

        // Act
        final result = await repository.lockForEditing(1, 'user-abc');

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<UnauthorizedError>());
      },
    );
  });

  // =========================================================================
  // unlockEditing
  // =========================================================================
  group('WidgetRepositoryImpl.unlockEditing', () {
    test('should return Success(null) when unlock write succeeds', () async {
      // Arrange
      fakeDs.queueUpdateItem({
        'id': 1,
        'column': 10,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': <String, dynamic>{},
      });

      // Act
      final result = await repository.unlockEditing(1);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should call updateItem exactly once', () async {
      // Arrange
      fakeDs.queueUpdateItem({
        'id': 1,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': <String, dynamic>{},
      });

      // Act
      await repository.unlockEditing(1);

      // Assert
      expect(fakeDs.updateCalls.length, 1);
    });

    test('should send editing_by=null in DTO', () async {
      // Arrange
      fakeDs.queueUpdateItem({
        'id': 1,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': <String, dynamic>{},
      });

      // Act
      await repository.unlockEditing(1);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      expect(sentDto.getValue(forKey: 'editing_by'), isNull);
    });

    test('should send editing_since=null in DTO', () async {
      // Arrange
      fakeDs.queueUpdateItem({
        'id': 1,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': <String, dynamic>{},
      });

      // Act
      await repository.unlockEditing(1);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      expect(sentDto.getValue(forKey: 'editing_since'), isNull);
    });

    test('should send the correct widget id in the DTO', () async {
      // Arrange
      fakeDs.queueUpdateItem({
        'id': 77,
        'type_key': 'dish',
        'version': '1.0.0',
        'index': 0,
        'props_json': <String, dynamic>{},
      });

      // Act
      await repository.unlockEditing(77);

      // Assert
      final sentDto = fakeDs.updateCalls.single['item'] as WidgetDto;
      expect(sentDto.intId, 77);
    });

    test(
      'should succeed even when widget was never locked (idempotent)',
      () async {
        // Arrange — widget had no lock; unlock still succeeds
        fakeDs.queueUpdateItem({
          'id': 1,
          'type_key': 'dish',
          'version': '1.0.0',
          'index': 0,
          'props_json': <String, dynamic>{},
        });

        // Act
        final result = await repository.unlockEditing(1);

        // Assert
        expect(result.isSuccess, isTrue);
      },
    );

    test(
      'should return Failure(NotFoundError) when updateItem throws NOT_FOUND',
      () async {
        // Arrange
        fakeDs.queueUpdateItemThrows(
          DirectusException(code: 'NOT_FOUND', message: 'Widget not found'),
        );

        // Act
        final result = await repository.unlockEditing(999);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      },
    );

    test('should return Failure(UnknownError) on generic exception', () async {
      // Arrange
      fakeDs.queueUpdateItemThrows(Exception('Timeout'));

      // Act
      final result = await repository.unlockEditing(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnknownError>());
    });
  });
}
