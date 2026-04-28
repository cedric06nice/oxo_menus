import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/mappers/error_mapper.dart';
import 'package:oxo_menus/features/menu/data/mappers/size_mapper.dart';
import 'package:oxo_menus/features/menu/data/models/size_dto.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';

/// Implementation of SizeRepository using Directus as data source
class SizeRepositoryImpl implements SizeRepository {
  final DirectusDataSource dataSource;

  const SizeRepositoryImpl({required this.dataSource});

  @override
  Future<Result<List<Size>, DomainError>> getAll() async {
    try {
      final data = await dataSource.getItems<SizeDto>(
        fields: ['id', 'name', 'width', 'height', 'status', 'direction'],
        sort: ['name'],
      );

      final sizes = data
          .map((json) => SizeDto(json))
          .map((dto) => SizeMapper.toEntity(dto))
          .toList();

      return Success(sizes);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Size, DomainError>> getById(int id) async {
    try {
      final data = await dataSource.getItem<SizeDto>(
        id,
        fields: ['id', 'name', 'width', 'height', 'status', 'direction'],
      );

      final dto = SizeDto(data);
      final size = SizeMapper.toEntity(dto);

      return Success(size);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Size, DomainError>> create(CreateSizeInput input) async {
    try {
      final item = SizeDto.newItem(
        name: input.name,
        width: input.width,
        height: input.height,
        status: StatusConverter.mapStatusToString(input.status),
        direction: input.direction,
      );

      final data = await dataSource.createItem<SizeDto>(item);

      final dto = SizeDto(data);
      final size = SizeMapper.toEntity(dto);

      return Success(size);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<Size, DomainError>> update(UpdateSizeInput input) async {
    try {
      final existingData = await dataSource.getItem<SizeDto>(
        input.id,
        fields: ['id', 'name', 'width', 'height', 'status', 'direction'],
      );
      final item = SizeDto(existingData);

      final updateData = SizeMapper.toUpdateDto(input);
      for (final entry in updateData.entries) {
        item.setValue(entry.value, forKey: entry.key);
      }

      final data = await dataSource.updateItem<SizeDto>(item);

      final dto = SizeDto(data);
      final size = SizeMapper.toEntity(dto);

      return Success(size);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    try {
      await dataSource.deleteItem<SizeDto>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
