import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/container_mapper.dart';
import 'package:oxo_menus/data/models/container_dto.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';

/// Implementation of ContainerRepository using Directus as data source
class ContainerRepositoryImpl implements ContainerRepository {
  final DirectusDataSource dataSource;
  static const String collection = 'container';

  const ContainerRepositoryImpl({required this.dataSource});

  @override
  Future<Result<Container, DomainError>> create(
      CreateContainerInput input) async {
    try {
      final createData = <String, dynamic>{
        'page_id': input.pageId,
        'index': input.index,
      };

      if (input.name != null) createData['name'] = input.name;
      if (input.layout != null) {
        createData['layout_json'] = ContainerMapper.layoutConfigToJson(input.layout!);
      }

      final data = await dataSource.createItem(collection, createData);

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
      final data = await dataSource.getItems(
        collection,
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
      final data = await dataSource.getItem(
        collection,
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
      final updateData = <String, dynamic>{};

      if (input.name != null) updateData['name'] = input.name;
      if (input.index != null) updateData['index'] = input.index;
      if (input.layout != null) {
        updateData['layout_json'] = ContainerMapper.layoutConfigToJson(input.layout!);
      }

      final data = await dataSource.updateItem(
        collection,
        input.id,
        updateData,
      );

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
      await dataSource.deleteItem(collection, id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> reorder(
      String containerId, int newIndex) async {
    try {
      await dataSource.updateItem(
        collection,
        containerId,
        {'index': newIndex},
      );
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> moveTo(
      String containerId, String newPageId, int index) async {
    try {
      await dataSource.updateItem(
        collection,
        containerId,
        {
          'page_id': newPageId,
          'index': index,
        },
      );
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
