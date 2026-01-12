import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/column_mapper.dart';
import 'package:oxo_menus/data/models/directus_items/column_directus_item.dart';
import 'package:oxo_menus/data/models/column_dto.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';

/// Implementation of ColumnRepository using Directus as data source
class ColumnRepositoryImpl implements ColumnRepository {
  final DirectusDataSource dataSource;

  const ColumnRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Column, DomainError>> create(CreateColumnInput input) async {
    try {
      final item = ColumnDirectusItem.newItem();
      item.setValue(input.containerId, forKey: 'container_id');
      item.setValue(input.index, forKey: 'index');

      if (input.flex != null) {
        item.setValue(input.flex, forKey: 'flex');
      }
      if (input.width != null) {
        item.setValue(input.width, forKey: 'width');
      }

      final data = await dataSource.createItem<ColumnDirectusItem>(item);

      final dto = ColumnDto.fromJson(data);
      final column = ColumnMapper.toEntity(dto);

      return Success(column);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<Column>, DomainError>> getAllForContainer(
      String containerId) async {
    try {
      final data = await dataSource.getItems<ColumnDirectusItem>(
        filter: {
          'container_id': {'_eq': containerId}
        },
        fields: [
          'id',
          'container_id',
          'index',
          'flex',
          'width',
          'date_created',
          'date_updated',
        ],
        sort: ['index'],
      );

      final columns = data
          .map((json) => ColumnDto.fromJson(json))
          .map((dto) => ColumnMapper.toEntity(dto))
          .toList();

      return Success(columns);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Column, DomainError>> getById(String id) async {
    try {
      final data = await dataSource.getItem<ColumnDirectusItem>(
        id,
        fields: [
          'id',
          'container_id',
          'index',
          'flex',
          'width',
          'date_created',
          'date_updated',
        ],
      );

      final dto = ColumnDto.fromJson(data);
      final column = ColumnMapper.toEntity(dto);

      return Success(column);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Column, DomainError>> update(UpdateColumnInput input) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<ColumnDirectusItem>(input.id);
      final item = ColumnDirectusItem(existingData);

      if (input.index != null) {
        item.setValue(input.index, forKey: 'index');
      }
      if (input.flex != null) {
        item.setValue(input.flex, forKey: 'flex');
      }
      if (input.width != null) {
        item.setValue(input.width, forKey: 'width');
      }

      final data = await dataSource.updateItem<ColumnDirectusItem>(item);

      final dto = ColumnDto.fromJson(data);
      final column = ColumnMapper.toEntity(dto);

      return Success(column);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(String id) async {
    try {
      await dataSource.deleteItem<ColumnDirectusItem>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> reorder(String columnId, int newIndex) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<ColumnDirectusItem>(columnId);
      final item = ColumnDirectusItem(existingData);
      
      item.setValue(newIndex, forKey: 'index');

      await dataSource.updateItem<ColumnDirectusItem>(item);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
