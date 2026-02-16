import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/menu_mapper.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';

/// Implementation of MenuRepository using Directus as data source
class MenuRepositoryImpl implements MenuRepository {
  final DirectusDataSource dataSource;

  MenuRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Menu, DomainError>> getById(int id) async {
    try {
      final data = await dataSource.getItem<MenuDto>(
        id,
        fields: [
          'id',
          'status',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'name',
          'style_json',
          'display_options_json',
          'allowed_widget_types',
          'version',
          'area.id',
          'area.date_created',
          'area.date_updated',
          'area.user_created',
          'area.user_updated',
          'area.name',
          'size.id',
          'size.status',
          'size.date_created',
          'size.date_updated',
          'size.user_created',
          'size.user_updated',
          'size.name',
          'size.width',
          'size.height',
          'size.direction',
          'versions',
          'pages.id',
          'pages.status',
          'pages.date_created',
          'pages.date_updated',
          'pages.user_created',
          'pages.user_updated',
          'pages.index',
          'pages.containers.id',
          'pages.containers.date_created',
          'pages.containers.date_updated',
          'pages.containers.user_created',
          'pages.containers.user_updated',
          'pages.containers.index',
          'pages.containers.direction',
          'pages.containers.style_json',
          'pages.containers.columns.id',
          'pages.containers.columns.date_created',
          'pages.containers.columns.date_updated',
          'pages.containers.columns.user_created',
          'pages.containers.columns.user_updated',
          'pages.containers.columns.index',
          'pages.containers.columns.width',
          'pages.containers.columns.style_json',
          'pages.containers.columns.widgets.id',
          'pages.containers.columns.widgets.status',
          'pages.containers.columns.widgets.date_created',
          'pages.containers.columns.widgets.date_updated',
          'pages.containers.columns.widgets.user_created',
          'pages.containers.columns.widgets.user_updated',
          'pages.containers.columns.widgets.index',
          'pages.containers.columns.widgets.type_key',
          'pages.containers.columns.widgets.version',
          'pages.containers.columns.widgets.props_json',
          'pages.containers.columns.widgets.style_json',
        ],
      );

      // id,name,status,version,date_created,date_updated,user_created,user_updated,style_json,area.id,area.name,size.id,size.name,size.width,size.height,size.direction,versions,pages.id,pages.status,pages.date_created,pages.date_updated,pages.user_created,pages.user_updated,pages.index,pages.menu,pages.containers.id,pages.containers.index,pages.containers.direction,pages.containers.style_json,pages.containers.columns.id,pages.containers.columns.index,pages.containers.columns.width,pages.containers.columns.style_json,pages.containers.columns.widgets.id,pages.containers.columns.widgets.index,pages.containers.columns.widgets.type_key,pages.containers.columns.widgets.version,pages.containers.columns.widgets.style_json,pages.containers.columns.widgets.props_json

      final dto = MenuDto(data);
      final menu = MenuMapper.toEntity(dto);

      return Success(menu);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<Menu>, DomainError>> listAll({
    bool onlyPublished = true,
  }) async {
    try {
      final filter = onlyPublished
          ? {
              'status': {'_eq': 'published'},
            }
          : null;

      final data = await dataSource.getItems<MenuDto>(
        filter: filter,
        fields: [
          'id',
          'status',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'name',
          'style_json',
          'display_options_json',
          'allowed_widget_types',
          'version',
          'area.id',
          'area.date_created',
          'area.date_updated',
          'area.user_created',
          'area.user_updated',
          'area.name',
          'size.id',
          'size.status',
          'size.date_created',
          'size.date_updated',
          'size.user_created',
          'size.user_updated',
          'size.name',
          'size.width',
          'size.height',
          'size.direction',
          'versions',
          'pages.id',
          'pages.status',
          'pages.date_created',
          'pages.date_updated',
          'pages.user_created',
          'pages.user_updated',
          'pages.index',
          'pages.containers.id',
          'pages.containers.date_created',
          'pages.containers.date_updated',
          'pages.containers.user_created',
          'pages.containers.user_updated',
          'pages.containers.index',
          'pages.containers.direction',
          'pages.containers.style_json',
          'pages.containers.columns.id',
          'pages.containers.columns.date_created',
          'pages.containers.columns.date_updated',
          'pages.containers.columns.user_created',
          'pages.containers.columns.user_updated',
          'pages.containers.columns.index',
          'pages.containers.columns.width',
          'pages.containers.columns.style_json',
          'pages.containers.columns.widgets.id',
          'pages.containers.columns.widgets.status',
          'pages.containers.columns.widgets.date_created',
          'pages.containers.columns.widgets.date_updated',
          'pages.containers.columns.widgets.user_created',
          'pages.containers.columns.widgets.user_updated',
          'pages.containers.columns.widgets.index',
          'pages.containers.columns.widgets.type_key',
          'pages.containers.columns.widgets.version',
          'pages.containers.columns.widgets.props_json',
          'pages.containers.columns.widgets.style_json',
        ],
        sort: ['-date_updated'],
      );

      final menus = data
          .map((json) => MenuDto(json))
          .map((dto) => MenuMapper.toEntity(dto))
          .toList();

      return Success(menus);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Menu, DomainError>> create(CreateMenuInput input) async {
    try {
      final item = MenuDto.newItem(name: input.name, version: input.version);
      final createData = MenuMapper.toCreateDto(input);

      // Set all properties
      for (final entry in createData.entries) {
        item.setValue(entry.value, forKey: entry.key);
      }

      final data = await dataSource.createItem<MenuDto>(item);

      final dto = MenuDto(data);
      final menu = MenuMapper.toEntity(dto);

      return Success(menu);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Menu, DomainError>> update(UpdateMenuInput input) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<MenuDto>(input.id);
      final item = MenuDto(existingData);

      final updateData = MenuMapper.toUpdateDto(input);

      // Update properties
      for (final entry in updateData.entries) {
        item.setValue(entry.value, forKey: entry.key);
      }

      final data = await dataSource.updateItem<MenuDto>(item);

      final dto = MenuDto(data);
      final menu = MenuMapper.toEntity(dto);

      return Success(menu);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    try {
      await dataSource.deleteItem<MenuDto>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
