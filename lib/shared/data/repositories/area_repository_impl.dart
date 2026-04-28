import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/mappers/area_mapper.dart';
import 'package:oxo_menus/shared/data/mappers/error_mapper.dart';
import 'package:oxo_menus/shared/data/models/area_dto.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/repositories/area_repository.dart';

/// Implementation of AreaRepository using Directus as data source
class AreaRepositoryImpl implements AreaRepository {
  final DirectusDataSource dataSource;

  const AreaRepositoryImpl({required this.dataSource});

  @override
  Future<Result<List<Area>, DomainError>> getAll() async {
    try {
      final data = await dataSource.getItems<AreaDto>(
        fields: ['id', 'name'],
        sort: ['name'],
      );

      final areas = data
          .map((json) => AreaDto(json))
          .map((dto) => AreaMapper.toEntity(dto))
          .toList();

      return Success(areas);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
