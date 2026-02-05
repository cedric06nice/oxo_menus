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

  const PageRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Page, DomainError>> create(CreatePageInput input) async {
    try {
      final item = PageDto.newItem(
        index: input.index,
        menu: input.menuId,
        status: 'draft',
      );

      final data = await dataSource.createItem<PageDto>(item);

      final dto = PageDto(data);
      final page = PageMapper.toEntity(dto);

      return Success(page);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<Page>, DomainError>> getAllForMenu(int menuId) async {
    try {
      final data = await dataSource.getItems<PageDto>(
        filter: {
          'menu': {'_eq': menuId}
        },
        fields: [
          'id',
          'status',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'index',
          'containers.id',
          'containers.date_created',
          'containers.date_updated',
          'containers.user_created',
          'containers.user_updated',
          'containers.index',
          'containers.direction',
          'containers.style_json',
          'containers.columns.id',
          'containers.columns.date_created',
          'containers.columns.date_updated',
          'containers.columns.user_created',
          'containers.columns.user_updated',
          'containers.columns.index',
          'containers.columns.width',
          'containers.columns.style_json',
          'containers.columns.widgets.id',
          'containers.columns.widgets.status',
          'containers.columns.widgets.date_created',
          'containers.columns.widgets.date_updated',
          'containers.columns.widgets.user_created',
          'containers.columns.widgets.user_updated',
          'containers.columns.widgets.index',
          'containers.columns.widgets.type_key',
          'containers.columns.widgets.version',
          'containers.columns.widgets.props_json',
          'containers.columns.widgets.style_json'
        ],
        sort: ['index'],
      );

      final pages = data
          .map((json) => PageDto(json))
          .map((dto) => PageMapper.toEntity(dto))
          .toList();

      return Success(pages);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Page, DomainError>> getById(int id) async {
    try {
      final data = await dataSource.getItem<PageDto>(
        id,
        fields: [
          'id',
          'status',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'index',
          'containers.id',
          'containers.date_created',
          'containers.date_updated',
          'containers.user_created',
          'containers.user_updated',
          'containers.index',
          'containers.direction',
          'containers.style_json',
          'containers.columns.id',
          'containers.columns.date_created',
          'containers.columns.date_updated',
          'containers.columns.user_created',
          'containers.columns.user_updated',
          'containers.columns.index',
          'containers.columns.width',
          'containers.columns.style_json',
          'containers.columns.widgets.id',
          'containers.columns.widgets.status',
          'containers.columns.widgets.date_created',
          'containers.columns.widgets.date_updated',
          'containers.columns.widgets.user_created',
          'containers.columns.widgets.user_updated',
          'containers.columns.widgets.index',
          'containers.columns.widgets.type_key',
          'containers.columns.widgets.version',
          'containers.columns.widgets.props_json',
          'containers.columns.widgets.style_json'
        ],
      );

      final dto = PageDto(data);
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
      final existingData = await dataSource.getItem<PageDto>(input.id);
      final item = PageDto(existingData);

      // if (input.name != null) item.setValue(input.name, forKey: 'name');
      if (input.index != null) item.setValue(input.index, forKey: 'index');

      final data = await dataSource.updateItem<PageDto>(item);

      final dto = PageDto(data);
      final page = PageMapper.toEntity(dto);

      return Success(page);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    try {
      await dataSource.deleteItem<PageDto>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> reorder(int pageId, int newIndex) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<PageDto>(pageId);
      final item = PageDto(existingData);

      item.setValue(newIndex, forKey: 'index');

      await dataSource.updateItem<PageDto>(item);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
