import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/container_mapper.dart';
import 'package:oxo_menus/data/models/directus_items/container_directus_item.dart';
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
      final item = ContainerDirectusItem.newItem();
      item.setValue(input.pageId, forKey: 'page_id');
      item.setValue(input.index, forKey: 'index');

      if (input.name != null) {
        item.setValue(input.name, forKey: 'name');
      }
      if (input.layout != null) {
        item.setValue(
          ContainerMapper.layoutConfigToJson(input.layout!),
          forKey: 'layout_json',
        );
      }

      final data = await dataSource.createItem<ContainerDirectusItem>(item);

      final dto = ContainerDto.fromJson(data);
      final container = ContainerMapper.toEntity(dto);

      return Success(container);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<Container>, DomainError>> getAllForPage(
      String pageId) async {
    try {
      final data = await dataSource.getItems<ContainerDirectusItem>(
        filter: {
          'page_id': {'_eq': pageId}
        },
        fields: [
          'id',
          'page_id',
          'index',
          'name',
          'layout_json',
          'date_created',
          'date_updated',
        ],
        sort: ['index'],
      );

      final containers = data
          .map((json) => ContainerDto.fromJson(json))
          .map((dto) => ContainerMapper.toEntity(dto))
          .toList();

      return Success(containers);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Container, DomainError>> getById(String id) async {
    try {
      final data = await dataSource.getItem<ContainerDirectusItem>(
        id,
        fields: [
          'id',
          'page_id',
          'index',
          'name',
          'layout_json',
          'date_created',
          'date_updated',
        ],
      );

      final dto = ContainerDto.fromJson(data);
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
      final existingData = await dataSource.getItem<ContainerDirectusItem>(input.id);
      final item = ContainerDirectusItem(existingData);

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

      final data = await dataSource.updateItem<ContainerDirectusItem>(item);

      final dto = ContainerDto.fromJson(data);
      final container = ContainerMapper.toEntity(dto);

      return Success(container);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(String id) async {
    try {
      await dataSource.deleteItem<ContainerDirectusItem>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> reorder(
      String containerId, int newIndex) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<ContainerDirectusItem>(containerId);
      final item = ContainerDirectusItem(existingData);
      
      item.setValue(newIndex, forKey: 'index');

      await dataSource.updateItem<ContainerDirectusItem>(item);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> moveTo(
      String containerId, String newPageId, int index) async {
    try {
      // First fetch the existing item
      final existingData = await dataSource.getItem<ContainerDirectusItem>(containerId);
      final item = ContainerDirectusItem(existingData);
      
      item.setValue(newPageId, forKey: 'page_id');
      item.setValue(index, forKey: 'index');

      await dataSource.updateItem<ContainerDirectusItem>(item);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
