import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/widget_mapper.dart';
import 'package:oxo_menus/data/models/widget_dto.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';

/// Implementation of WidgetRepository using Directus as data source
class WidgetRepositoryImpl implements WidgetRepository {
  final DirectusDataSource dataSource;
  static const String collection = 'widget';

  const WidgetRepositoryImpl({required this.dataSource});

  @override
  Future<Result<WidgetInstance, DomainError>> create(
      CreateWidgetInput input) async {
    try {
      final createData = <String, dynamic>{
        'column_id': input.columnId,
        'type': input.type,
        'version': input.version,
        'index': input.index,
        'props': input.props,
      };

      if (input.style != null) {
        createData['style_json'] = WidgetMapper.widgetStyleToJson(input.style!);
      }

      final data = await dataSource.createItem(collection, createData);

      final dto = WidgetDto.fromJson(data);
      final widget = WidgetMapper.toEntity(dto);

      return Success(widget);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<WidgetInstance>, DomainError>> getAllForColumn(
      String columnId) async {
    try {
      final data = await dataSource.getItems(
        collection,
        filter: {
          'column_id': {'_eq': columnId}
        },
        fields: [
          'id',
          'column_id',
          'type',
          'version',
          'index',
          'props',
          'style_json',
          'date_created',
          'date_updated',
        ],
        sort: ['index'],
      );

      final widgets = data
          .map((json) => WidgetDto.fromJson(json))
          .map((dto) => WidgetMapper.toEntity(dto))
          .toList();

      return Success(widgets);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<WidgetInstance, DomainError>> getById(String id) async {
    try {
      final data = await dataSource.getItem(
        collection,
        id,
        fields: [
          'id',
          'column_id',
          'type',
          'version',
          'index',
          'props',
          'style_json',
          'date_created',
          'date_updated',
        ],
      );

      final dto = WidgetDto.fromJson(data);
      final widget = WidgetMapper.toEntity(dto);

      return Success(widget);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<WidgetInstance, DomainError>> update(
      UpdateWidgetInput input) async {
    try {
      final updateData = <String, dynamic>{};

      if (input.type != null) updateData['type'] = input.type;
      if (input.version != null) updateData['version'] = input.version;
      if (input.index != null) updateData['index'] = input.index;
      if (input.props != null) updateData['props'] = input.props;
      if (input.style != null) {
        updateData['style_json'] = WidgetMapper.widgetStyleToJson(input.style!);
      }

      final data = await dataSource.updateItem(
        collection,
        input.id,
        updateData,
      );

      final dto = WidgetDto.fromJson(data);
      final widget = WidgetMapper.toEntity(dto);

      return Success(widget);
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
  Future<Result<void, DomainError>> reorder(
      String widgetId, int newIndex) async {
    try {
      await dataSource.updateItem(
        collection,
        widgetId,
        {'index': newIndex},
      );
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> moveTo(
      String widgetId, String newColumnId, int index) async {
    try {
      await dataSource.updateItem(
        collection,
        widgetId,
        {
          'column_id': newColumnId,
          'index': index,
        },
      );
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
