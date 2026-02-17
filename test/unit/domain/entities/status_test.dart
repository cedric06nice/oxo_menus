import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/status.dart';

void main() {
  group('Status', () {
    test('should have three values', () {
      expect(Status.values, hasLength(3));
      expect(Status.values, contains(Status.draft));
      expect(Status.values, contains(Status.published));
      expect(Status.values, contains(Status.archived));
    });
  });

  group('StatusConverter', () {
    group('mapStatusToEnum', () {
      test('should map "draft" to Status.draft', () {
        expect(StatusConverter.mapStatusToEnum('draft'), Status.draft);
      });

      test('should map "published" to Status.published', () {
        expect(StatusConverter.mapStatusToEnum('published'), Status.published);
      });

      test('should map "archived" to Status.archived', () {
        expect(StatusConverter.mapStatusToEnum('archived'), Status.archived);
      });

      test('should be case-insensitive', () {
        expect(StatusConverter.mapStatusToEnum('DRAFT'), Status.draft);
        expect(StatusConverter.mapStatusToEnum('Published'), Status.published);
        expect(StatusConverter.mapStatusToEnum('ARCHIVED'), Status.archived);
      });

      test('should default to draft for unknown status', () {
        expect(StatusConverter.mapStatusToEnum('unknown'), Status.draft);
        expect(StatusConverter.mapStatusToEnum(''), Status.draft);
      });
    });

    group('mapStatusToString', () {
      test('should map Status.draft to "draft"', () {
        expect(StatusConverter.mapStatusToString(Status.draft), 'draft');
      });

      test('should map Status.published to "published"', () {
        expect(
          StatusConverter.mapStatusToString(Status.published),
          'published',
        );
      });

      test('should map Status.archived to "archived"', () {
        expect(StatusConverter.mapStatusToString(Status.archived), 'archived');
      });
    });
  });
}
