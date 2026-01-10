import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/page_mapper.dart';
import 'package:oxo_menus/data/models/page_dto.dart';
import 'package:oxo_menus/domain/entities/page.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';

/// Implementation of PageRepository using Directus as data source
class PageRepositoryImpl implements PageRepository {
  final DirectusDataSource dataSource;
  static const String collection = 'page';

  const PageRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Page, DomainError>> create(CreatePageInput input) async {
    try {
      final data = await dataSource.createItem(
        collection,
        {
          'menu_id': input.menuId,
          'name': input.name,
          'index': input.index,
        },
      );

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
      final data = await dataSource.getItems(
        collection,
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
      final data = await dataSource.getItem(
        collection,
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
      final updateData = <String, dynamic>{};

      if (input.name != null) updateData['name'] = input.name;
      if (input.index != null) updateData['index'] = input.index;

      final data = await dataSource.updateItem(
        collection,
        input.id,
        updateData,
      );

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
      await dataSource.deleteItem(collection, id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> reorder(String pageId, int newIndex) async {
    try {
      await dataSource.updateItem(
        collection,
        pageId,
        {'index': newIndex},
      );
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
