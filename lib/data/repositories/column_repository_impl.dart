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
  static const String collection = 'column';

  const ColumnRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Column, DomainError>> create(CreateColumnInput input) async {
    try {
      final createData = <String, dynamic>{
        'container_id': input.containerId,
        'index': input.index,
      };

      if (input.flex != null) createData['flex'] = input.flex;
      if (input.width != null) createData['width'] = input.width;

      final data = await dataSource.createItem(collection, createData);

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
      final data = await dataSource.getItems(
        collection,
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
      final data = await dataSource.getItem(
        collection,
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
      final updateData = <String, dynamic>{};

      if (input.index != null) updateData['index'] = input.index;
      if (input.flex != null) updateData['flex'] = input.flex;
      if (input.width != null) updateData['width'] = input.width;

      final data = await dataSource.updateItem(
        collection,
        input.id,
        updateData,
      );

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
      await dataSource.deleteItem(collection, id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> reorder(String columnId, int newIndex) async {
    try {
      await dataSource.updateItem(
        collection,
        columnId,
        {'index': newIndex},
      );
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
