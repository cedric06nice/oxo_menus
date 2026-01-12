import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/menu_mapper.dart';
import 'package:oxo_menus/data/models/directus_items/menu_directus_item.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';

/// Implementation of MenuRepository using Directus as data source
class MenuRepositoryImpl implements MenuRepository {
  final DirectusDataSource dataSource;

  const MenuRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Menu, DomainError>> getById(String id) async {
    try {
      final data = await dataSource.getItem<MenuDirectusItem>(
        id,
        fields: [
          'id',
          'name',
          'status',
          'version',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'style_json',
          'area',
          'size',
        ],
      );

      final dto = MenuDto.fromJson(data);
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
              'status': {'_eq': 'published'}
            }
          : null;

      final data = await dataSource.getItems<MenuDirectusItem>(
        filter: filter,
        fields: [
          'id',
          'name',
          'status',
          'version',
          'date_created',
          'date_updated',
          'style_json',
        ],
        sort: ['-date_updated'],
      );

      final menus = data
          .map((json) => MenuDto.fromJson(json))
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
      final item = MenuDirectusItem.newItem();
      final createData = MenuMapper.toCreateDto(input);

      // Set all properties
      for (final entry in createData.entries) {
        item.setValue(entry.value, forKey: entry.key);
      }

      final data = await dataSource.createItem<MenuDirectusItem>(item);

      final dto = MenuDto.fromJson(data);
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
      final existingData = await dataSource.getItem<MenuDirectusItem>(input.id);
      final item = MenuDirectusItem(existingData);

      final updateData = MenuMapper.toUpdateDto(input);

      // Update properties
      for (final entry in updateData.entries) {
        item.setValue(entry.value, forKey: entry.key);
      }

      final data = await dataSource.updateItem<MenuDirectusItem>(item);

      final dto = MenuDto.fromJson(data);
      final menu = MenuMapper.toEntity(dto);

      return Success(menu);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(String id) async {
    try {
      await dataSource.deleteItem<MenuDirectusItem>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
