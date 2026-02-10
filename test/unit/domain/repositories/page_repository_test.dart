import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';

void main() {
  group('CreatePageInput', () {
    test('should create with type field', () {
      const input = CreatePageInput(
        menuId: 1,
        name: 'Header',
        index: 0,
        type: PageType.header,
      );

      expect(input.type, PageType.header);
    });

    test('should default type to PageType.content', () {
      const input = CreatePageInput(
        menuId: 1,
        name: 'Page 1',
        index: 0,
      );

      expect(input.type, PageType.content);
    });
  });
}
