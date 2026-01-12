import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/widget_mapper.dart';
import 'package:oxo_menus/data/models/directus_items/widget_directus_item.dart';
import 'package:oxo_menus/data/models/widget_dto.dart';
import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';

/// Implementation of WidgetRepository using Directus as data source
class WidgetRepositoryImpl implements WidgetRepository {
  final DirectusDataSource dataSource;

  const WidgetRepositoryImpl({required this.dataSource});

  @override
  Future<Result<WidgetInstance, DomainError>> create(
      CreateWidgetInput input) async {
    try {
      final item = WidgetDirectusItem.newItem();
      item.setValue(input.columnId, forKey: 'column_id');
      item.setValue(input.type, forKey: 'type');
      item.setValue(input.version, forKey: 'version');
      item.setValue(input.index, forKey: 'index');
      item.setValue(input.props, forKey: 'props');

      if (input.style != null) {
        item.setValue(
          WidgetMapper.widgetStyleToJson(input.style!),
          forKey: 'style_json',
        );
      }

      final data = await dataSource.createItem<WidgetDirectusItem>(item);

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
      final data = await dataSource.getItems<WidgetDirectusItem>(
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
      final data = await dataSource.getItem<WidgetDirectusItem>(
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
      // First fetch the existing item
      final existingData = await dataSource.getItem<WidgetDirectusItem>(input.id);
      final item = WidgetDirectusItem(existingData);

      if (input.type != null) {
        item.setValue(input.type, forKey: 'type');
      }
      if (input.version != null) {
        item.setValue(input.version, forKey: 'version');
      }
      if (input.index != null) {
        item.setValue(input.index, forKey: 'index');
      }
      if (input.props != null) {
        item.setValue(input.props, forKey: 'props');
      }
      if (input.style != null) {
        item.setValue(
          WidgetMapper.widgetStyleToJson(input.style!),
          forKey: 'style_json',
        );
      }

      final data = await dataSource.updateItem<WidgetDirectusItem>(item);

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
      await dataSource.deleteItem<WidgetDirectusItem>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> reorder(
      String widgetId, int newIndex) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<WidgetDirectusItem>(widgetId);
      final item = WidgetDirectusItem(existingData);
      
      item.setValue(newIndex, forKey: 'index');

      await dataSource.updateItem<WidgetDirectusItem>(item);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> moveTo(
      String widgetId, String newColumnId, int index) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<WidgetDirectusItem>(widgetId);
      final item = WidgetDirectusItem(existingData);
      
      item.setValue(newColumnId, forKey: 'column_id');
      item.setValue(index, forKey: 'index');

      await dataSource.updateItem<WidgetDirectusItem>(item);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
