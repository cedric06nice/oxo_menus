import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/column_mapper.dart';
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
      final item = ColumnDto.newItem(
        index: input.index,
        width: input.width?.toInt() ?? 100,
        container: input.containerId,
      );

      if (input.flex != null) {
        item.setValue(input.flex, forKey: 'flex');
      }

      final data = await dataSource.createItem<ColumnDto>(item);

      final dto = ColumnDto(data);
      final column = ColumnMapper.toEntity(dto);

      return Success(column);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<Column>, DomainError>> getAllForContainer(
    int containerId,
  ) async {
    try {
      final data = await dataSource.getItems<ColumnDto>(
        filter: {
          'container': {'_eq': containerId},
        },
        fields: [
          'id',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'index',
          'width',
          'style_json',
          'widgets.id',
          'widgets.status',
          'widgets.date_created',
          'widgets.date_updated',
          'widgets.user_created',
          'widgets.user_updated',
          'widgets.index',
          'widgets.type_key',
          'widgets.version',
          'widgets.props_json',
          'widgets.style_json',
        ],
        sort: ['index'],
      );

      final columns = data
          .map((json) => ColumnDto(json))
          .map((dto) => ColumnMapper.toEntity(dto))
          .toList();

      return Success(columns);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Column, DomainError>> getById(int id) async {
    try {
      final data = await dataSource.getItem<ColumnDto>(
        id,
        fields: [
          'id',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'index',
          'width',
          'style_json',
          'widgets.id',
          'widgets.status',
          'widgets.date_created',
          'widgets.date_updated',
          'widgets.user_created',
          'widgets.user_updated',
          'widgets.index',
          'widgets.type_key',
          'widgets.version',
          'widgets.props_json',
          'widgets.style_json',
        ],
      );

      final dto = ColumnDto(data);
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
      final existingData = await dataSource.getItem<ColumnDto>(input.id);
      final item = ColumnDto(existingData);

      if (input.index != null) {
        item.setValue(input.index, forKey: 'index');
      }
      if (input.flex != null) {
        item.setValue(input.flex, forKey: 'flex');
      }
      if (input.width != null) {
        item.setValue(input.width, forKey: 'width');
      }

      final data = await dataSource.updateItem<ColumnDto>(item);

      final dto = ColumnDto(data);
      final column = ColumnMapper.toEntity(dto);

      return Success(column);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    try {
      await dataSource.deleteItem<ColumnDto>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> reorder(int columnId, int newIndex) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<ColumnDto>(columnId);
      final item = ColumnDto(existingData);

      item.setValue(newIndex, forKey: 'index');

      await dataSource.updateItem<ColumnDto>(item);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
