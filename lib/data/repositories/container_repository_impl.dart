import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/container_mapper.dart';
import 'package:oxo_menus/data/mappers/style_config_mapper.dart';
import 'package:oxo_menus/data/models/container_dto.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';

/// Implementation of ContainerRepository using Directus as data source
class ContainerRepositoryImpl implements ContainerRepository {
  final DirectusDataSource dataSource;

  const ContainerRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Container, DomainError>> create(
      CreateContainerInput input) async {
    try {
      final item = ContainerDto.newItem(
        index: input.index,
        page: input.pageId,
        status: 'published',
        direction: input.direction,
      );

      if (input.name != null) {
        item.setValue(input.name, forKey: 'name');
      }
      if (input.layout != null) {
        item.setValue(
          ContainerMapper.layoutConfigToJson(input.layout!),
          forKey: 'layout_json',
        );
      }
      if (input.styleConfig != null) {
        item.setValue(
          StyleConfigMapper.toJson(input.styleConfig!),
          forKey: 'style_json',
        );
      }

      final data = await dataSource.createItem<ContainerDto>(item);

      final dto = ContainerDto(data);
      final container = ContainerMapper.toEntity(dto);

      return Success(container);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<Container>, DomainError>> getAllForPage(
      int pageId) async {
    try {
      final data = await dataSource.getItems<ContainerDto>(
        filter: {
          'page': {'_eq': pageId}
        },
        fields: [
          'id',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'index',
          'direction',
          'style_json',
          'columns.id',
          'columns.date_created',
          'columns.date_updated',
          'columns.user_created',
          'columns.user_updated',
          'columns.index',
          'columns.width',
          'columns.style_json',
          'columns.widgets.id',
          'columns.widgets.status',
          'columns.widgets.date_created',
          'columns.widgets.date_updated',
          'columns.widgets.user_created',
          'columns.widgets.user_updated',
          'columns.widgets.index',
          'columns.widgets.type_key',
          'columns.widgets.version',
          'columns.widgets.props_json',
          'columns.widgets.style_json'
        ],
        sort: ['index'],
      );

      final containers = data
          .map((json) => ContainerDto(json))
          .map((dto) => ContainerMapper.toEntity(dto))
          .toList();

      return Success(containers);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Container, DomainError>> getById(int id) async {
    try {
      final data = await dataSource.getItem<ContainerDto>(
        id,
        fields: [
          'id',
          'date_created',
          'date_updated',
          'user_created',
          'user_updated',
          'index',
          'direction',
          'style_json',
          'columns.id',
          'columns.date_created',
          'columns.date_updated',
          'columns.user_created',
          'columns.user_updated',
          'columns.index',
          'columns.width',
          'columns.style_json',
          'columns.widgets.id',
          'columns.widgets.status',
          'columns.widgets.date_created',
          'columns.widgets.date_updated',
          'columns.widgets.user_created',
          'columns.widgets.user_updated',
          'columns.widgets.index',
          'columns.widgets.type_key',
          'columns.widgets.version',
          'columns.widgets.props_json',
          'columns.widgets.style_json'
        ],
      );

      final dto = ContainerDto(data);
      final container = ContainerMapper.toEntity(dto);

      return Success(container);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Container, DomainError>> update(
      UpdateContainerInput input) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<ContainerDto>(input.id);
      final item = ContainerDto(existingData);

      if (input.name != null) {
        item.setValue(input.name, forKey: 'name');
      }
      if (input.index != null) {
        item.setValue(input.index, forKey: 'index');
      }
      if (input.layout != null) {
        item.setValue(
          ContainerMapper.layoutConfigToJson(input.layout!),
          forKey: 'layout_json',
        );
      }
      if (input.styleConfig != null) {
        item.setValue(
          StyleConfigMapper.toJson(input.styleConfig!),
          forKey: 'style_json',
        );
      }

      final data = await dataSource.updateItem<ContainerDto>(item);

      final dto = ContainerDto(data);
      final container = ContainerMapper.toEntity(dto);

      return Success(container);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    try {
      await dataSource.deleteItem<ContainerDto>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> reorder(
      int containerId, int newIndex) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<ContainerDto>(containerId);
      final item = ContainerDto(existingData);

      item.setValue(newIndex, forKey: 'index');

      await dataSource.updateItem<ContainerDto>(item);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> moveTo(
      int containerId, int newPageId, int index) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<ContainerDto>(containerId);
      final item = ContainerDto(existingData);

      item.setValue(newPageId, forKey: 'page_id');
      item.setValue(index, forKey: 'index');

      await dataSource.updateItem<ContainerDto>(item);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
