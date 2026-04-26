import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/status.dart';

void main() {
  group('Status enum', () {
    group('values', () {
      test('should have exactly three cases', () {
        expect(Status.values.length, 3);
      });

      test('should include draft case', () {
        expect(Status.values, contains(Status.draft));
      });

      test('should include published case', () {
        expect(Status.values, contains(Status.published));
      });

      test('should include archived case', () {
        expect(Status.values, contains(Status.archived));
      });
    });

    group('name', () {
      test('should have name "draft" for draft case', () {
        expect(Status.draft.name, 'draft');
      });

      test('should have name "published" for published case', () {
        expect(Status.published.name, 'published');
      });

      test('should have name "archived" for archived case', () {
        expect(Status.archived.name, 'archived');
      });
    });

    group('index', () {
      test('should have index 0 for draft', () {
        expect(Status.draft.index, 0);
      });

      test('should have index 1 for published', () {
        expect(Status.published.index, 1);
      });

      test('should have index 2 for archived', () {
        expect(Status.archived.index, 2);
      });
    });

    group('equality', () {
      test('should be equal to itself for each case', () {
        for (final status in Status.values) {
          expect(status, equals(status));
        }
      });

      test('should not be equal to a different case', () {
        expect(Status.draft, isNot(equals(Status.published)));
        expect(Status.published, isNot(equals(Status.archived)));
      });
    });

    group('toString', () {
      test('should produce a non-empty string for each case', () {
        for (final status in Status.values) {
          expect(status.toString(), isNotEmpty);
        }
      });
    });
  });

  group('StatusConverter', () {
    group('mapStatusToEnum', () {
      test('should return Status.draft when value is "draft"', () {
        expect(StatusConverter.mapStatusToEnum('draft'), Status.draft);
      });

      test('should return Status.published when value is "published"', () {
        expect(StatusConverter.mapStatusToEnum('published'), Status.published);
      });

      test('should return Status.archived when value is "archived"', () {
        expect(StatusConverter.mapStatusToEnum('archived'), Status.archived);
      });

      test('should be case-insensitive for "DRAFT"', () {
        expect(StatusConverter.mapStatusToEnum('DRAFT'), Status.draft);
      });

      test('should be case-insensitive for "Published"', () {
        expect(StatusConverter.mapStatusToEnum('Published'), Status.published);
      });

      test('should be case-insensitive for "ARCHIVED"', () {
        expect(StatusConverter.mapStatusToEnum('ARCHIVED'), Status.archived);
      });

      test('should default to Status.draft when value is an unknown string', () {
        expect(StatusConverter.mapStatusToEnum('unknown'), Status.draft);
      });

      test('should default to Status.draft when value is an empty string', () {
        expect(StatusConverter.mapStatusToEnum(''), Status.draft);
      });
    });

    group('mapStatusToString', () {
      test('should return "draft" for Status.draft', () {
        expect(StatusConverter.mapStatusToString(Status.draft), 'draft');
      });

      test('should return "published" for Status.published', () {
        expect(StatusConverter.mapStatusToString(Status.published), 'published');
      });

      test('should return "archived" for Status.archived', () {
        expect(StatusConverter.mapStatusToString(Status.archived), 'archived');
      });
    });

    group('round-trip', () {
      test('should round-trip every case through mapStatusToString then mapStatusToEnum', () {
        for (final status in Status.values) {
          final str = StatusConverter.mapStatusToString(status);
          final restored = StatusConverter.mapStatusToEnum(str);
          expect(restored, status);
        }
      });
    });
  });
}
