import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/mappers/error_mapper.dart';
import 'package:oxo_menus/features/menu/data/mappers/widget_mapper.dart';
import 'package:oxo_menus/features/menu/data/models/widget_dto.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';

/// Implementation of WidgetRepository using Directus as data source
class WidgetRepositoryImpl implements WidgetRepository {
  final DirectusDataSource dataSource;

  const WidgetRepositoryImpl({required this.dataSource});

  @override
  Future<Result<WidgetInstance, DomainError>> create(
    CreateWidgetInput input,
  ) async {
    try {
      final item = WidgetDto.newItem(
        index: input.index,
        typeKey: input.type,
        version: input.version,
        status: 'published',
      );
      item.setValue(input.columnId, forKey: 'column');
      item.setValue(input.props, forKey: 'props_json');
      item.setValue(input.isTemplate, forKey: 'is_template');
      item.setValue(input.lockedForEdition, forKey: 'locked_for_edition');

      if (input.style != null) {
        item.setValue(
          WidgetMapper.widgetStyleToJson(input.style!),
          forKey: 'style_json',
        );
      }

      final data = await dataSource.createItem<WidgetDto>(item);

      final dto = WidgetDto(data);
      final widget = WidgetMapper.toEntity(dto);

      return Success(widget);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<WidgetInstance>, DomainError>> getAllForColumn(
    int columnId,
  ) async {
    try {
      final data = await dataSource.getItems<WidgetDto>(
        filter: {
          'column': {'_eq': columnId},
        },
        fields: [
          'id',
          'status',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'index',
          'type_key',
          'version',
          'props_json',
          'style_json',
          'is_template',
          'locked_for_edition',
          'editing_by',
          'editing_since',
        ],
        sort: ['index'],
      );

      final widgets = data
          .map((json) => WidgetDto(json))
          .map((dto) => WidgetMapper.toEntity(dto))
          .toList();

      return Success(widgets);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<WidgetInstance, DomainError>> getById(int id) async {
    try {
      final data = await dataSource.getItem<WidgetDto>(
        id,
        fields: [
          'id',
          'status',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'index',
          'type_key',
          'version',
          'props_json',
          'style_json',
          'is_template',
          'locked_for_edition',
          'editing_by',
          'editing_since',
        ],
      );

      final dto = WidgetDto(data);
      final widget = WidgetMapper.toEntity(dto);

      return Success(widget);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<WidgetInstance, DomainError>> update(
    UpdateWidgetInput input,
  ) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<WidgetDto>(input.id);
      final item = WidgetDto(existingData);

      if (input.type != null) {
        item.setValue(input.type, forKey: 'type_key');
      }
      if (input.version != null) {
        item.setValue(input.version, forKey: 'version');
      }
      if (input.index != null) {
        item.setValue(input.index, forKey: 'index');
      }
      if (input.props != null) {
        item.setValue(input.props, forKey: 'props_json');
      }
      if (input.style != null) {
        item.setValue(
          WidgetMapper.widgetStyleToJson(input.style!),
          forKey: 'style_json',
        );
      }
      if (input.lockedForEdition != null) {
        item.setValue(input.lockedForEdition, forKey: 'locked_for_edition');
      }

      final data = await dataSource.updateItem<WidgetDto>(item);

      final dto = WidgetDto(data);
      final widget = WidgetMapper.toEntity(dto);

      return Success(widget);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    try {
      await dataSource.deleteItem<WidgetDto>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> reorder(int widgetId, int newIndex) async {
    try {
      // First fetch the widget to get its current index and column
      final existingData = await dataSource.getItem<WidgetDto>(widgetId);
      final item = WidgetDto(existingData);
      final oldIndex = item.index;

      // Get the column ID directly from raw data (handles both int and nested object)
      final rawColumn = item.getValue(forKey: 'column');
      final int? columnId;
      if (rawColumn is int) {
        columnId = rawColumn;
      } else if (rawColumn is Map<String, dynamic>) {
        columnId = rawColumn['id'] as int?;
      } else {
        columnId = null;
      }

      if (columnId == null) {
        return const Failure(ValidationError('Widget has no column'));
      }

      if (oldIndex == newIndex) {
        return const Success(null); // No change needed
      }

      // Fetch all widgets in the same column
      final allWidgetsData = await dataSource.getItems<WidgetDto>(
        filter: {
          'column': {'_eq': columnId},
        },
        fields: ['id', 'index'],
        sort: ['index'],
      );

      // Update indices for affected widgets
      final updates = <Future<void>>[];

      for (final widgetData in allWidgetsData) {
        final dto = WidgetDto(widgetData);
        final rawId = dto.id;
        final currentIndex = dto.index;

        if (rawId == null) continue;
        final id = rawId is int ? rawId : int.tryParse(rawId.toString());
        if (id == null) continue;

        int? newWidgetIndex;

        if (id == widgetId) {
          // This is the widget being moved
          newWidgetIndex = newIndex;
        } else if (oldIndex < newIndex) {
          // Moving down: shift widgets between old and new position up
          if (currentIndex > oldIndex && currentIndex <= newIndex) {
            newWidgetIndex = currentIndex - 1;
          }
        } else {
          // Moving up: shift widgets between new and old position down
          if (currentIndex >= newIndex && currentIndex < oldIndex) {
            newWidgetIndex = currentIndex + 1;
          }
        }

        if (newWidgetIndex != null && newWidgetIndex != currentIndex) {
          dto.setValue(newWidgetIndex, forKey: 'index');
          updates.add(dataSource.updateItem<WidgetDto>(dto));
        }
      }

      await Future.wait(updates);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> moveTo(
    int widgetId,
    int newColumnId,
    int index,
  ) async {
    try {
      // First fetch the widget to get its current index and column
      final existingData = await dataSource.getItem<WidgetDto>(widgetId);
      final item = WidgetDto(existingData);
      final oldIndex = item.index;

      // Get the column ID directly from raw data (handles both int and nested object)
      final rawColumn = item.getValue(forKey: 'column');
      final int? oldColumnId;
      if (rawColumn is int) {
        oldColumnId = rawColumn;
      } else if (rawColumn is Map<String, dynamic>) {
        oldColumnId = rawColumn['id'] as int?;
      } else {
        oldColumnId = null;
      }

      if (oldColumnId == null) {
        return const Failure(ValidationError('Widget has no column'));
      }

      final updates = <Future<void>>[];

      // Update indices in the source column (shift widgets down after removed widget)
      if (oldColumnId != newColumnId) {
        final sourceWidgetsData = await dataSource.getItems<WidgetDto>(
          filter: {
            'column': {'_eq': oldColumnId},
          },
          fields: ['id', 'index'],
          sort: ['index'],
        );

        for (final widgetData in sourceWidgetsData) {
          final dto = WidgetDto(widgetData);
          final rawId = dto.id;
          final currentIndex = dto.index;

          if (rawId == null) continue;
          final id = rawId is int ? rawId : int.tryParse(rawId.toString());
          if (id == null || id == widgetId) continue;

          // Shift widgets after the removed widget down by 1
          if (currentIndex > oldIndex) {
            dto.setValue(currentIndex - 1, forKey: 'index');
            updates.add(dataSource.updateItem<WidgetDto>(dto));
          }
        }
      }

      // Update indices in the target column (shift widgets up at and after insertion point)
      final targetWidgetsData = await dataSource.getItems<WidgetDto>(
        filter: {
          'column': {'_eq': newColumnId},
        },
        fields: ['id', 'index'],
        sort: ['index'],
      );

      for (final widgetData in targetWidgetsData) {
        final dto = WidgetDto(widgetData);
        final rawId = dto.id;
        final currentIndex = dto.index;

        if (rawId == null) continue;
        final id = rawId is int ? rawId : int.tryParse(rawId.toString());
        if (id == null || id == widgetId) continue;

        // Shift widgets at and after the insertion point up by 1
        if (currentIndex >= index) {
          dto.setValue(currentIndex + 1, forKey: 'index');
          updates.add(dataSource.updateItem<WidgetDto>(dto));
        }
      }

      // Move the widget to the new column with the new index
      item.setValue(newColumnId, forKey: 'column');
      item.setValue(index, forKey: 'index');
      updates.add(dataSource.updateItem<WidgetDto>(item));

      await Future.wait(updates);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> lockForEditing(
    int widgetId,
    String userId,
  ) async {
    try {
      final dto = WidgetDto({'id': widgetId});
      dto.setValue(userId, forKey: 'editing_by');
      dto.setValue(
        DateTime.now().toUtc().toIso8601String(),
        forKey: 'editing_since',
      );

      await dataSource.updateItem<WidgetDto>(dto);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> unlockEditing(int widgetId) async {
    try {
      final dto = WidgetDto({'id': widgetId});
      dto.setValue(null, forKey: 'editing_by');
      dto.setValue(null, forKey: 'editing_since');

      await dataSource.updateItem<WidgetDto>(dto);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
