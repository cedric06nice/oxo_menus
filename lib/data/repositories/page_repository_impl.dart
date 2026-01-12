import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/page_mapper.dart';
import 'package:oxo_menus/data/models/directus_items/page_directus_item.dart';
import 'package:oxo_menus/data/models/page_dto.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';

/// Implementation of PageRepository using Directus as data source
class PageRepositoryImpl implements PageRepository {
  final DirectusDataSource dataSource;

  const PageRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Page, DomainError>> create(CreatePageInput input) async {
    try {
      final item = PageDirectusItem.newItem();
      item.setValue(input.menuId, forKey: 'menu_id');
      item.setValue(input.name, forKey: 'name');
      item.setValue(input.index, forKey: 'index');

      final data = await dataSource.createItem<PageDirectusItem>(item);

      final dto = PageDto.fromJson(data);
      final page = PageMapper.toEntity(dto);

      return Success(page);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<Page>, DomainError>> getAllForMenu(String menuId) async {
    try {
      final data = await dataSource.getItems<PageDirectusItem>(
        filter: {
          'menu_id': {'_eq': menuId}
        },
        fields: [
          'id',
          'menu_id',
          'name',
          'index',
          'date_created',
          'date_updated',
        ],
        sort: ['index'],
      );

      final pages = data
          .map((json) => PageDto.fromJson(json))
          .map((dto) => PageMapper.toEntity(dto))
          .toList();

      return Success(pages);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Page, DomainError>> getById(String id) async {
    try {
      final data = await dataSource.getItem<PageDirectusItem>(
        id,
        fields: [
          'id',
          'menu_id',
          'name',
          'index',
          'date_created',
          'date_updated',
        ],
      );

      final dto = PageDto.fromJson(data);
      final page = PageMapper.toEntity(dto);

      return Success(page);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Page, DomainError>> update(UpdatePageInput input) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<PageDirectusItem>(input.id);
      final item = PageDirectusItem(existingData);

      if (input.name != null) item.setValue(input.name, forKey: 'name');
      if (input.index != null) item.setValue(input.index, forKey: 'index');

      final data = await dataSource.updateItem<PageDirectusItem>(item);

      final dto = PageDto.fromJson(data);
      final page = PageMapper.toEntity(dto);

      return Success(page);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(String id) async {
    try {
      await dataSource.deleteItem<PageDirectusItem>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> reorder(String pageId, int newIndex) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<PageDirectusItem>(pageId);
      final item = PageDirectusItem(existingData);
      
      item.setValue(newIndex, forKey: 'index');

      await dataSource.updateItem<PageDirectusItem>(item);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
