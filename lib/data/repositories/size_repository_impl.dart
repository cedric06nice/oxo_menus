import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/mappers/error_mapper.dart';
import 'package:oxo_menus/data/mappers/size_mapper.dart';
import 'package:oxo_menus/data/models/size_dto.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';

/// Implementation of SizeRepository using Directus as data source
class SizeRepositoryImpl implements SizeRepository {
  final DirectusDataSource dataSource;

  const SizeRepositoryImpl({required this.dataSource});

  @override
  Future<Result<List<Size>, DomainError>> getAll() async {
    try {
      final data = await dataSource.getItems<SizeDto>(
        fields: ['id', 'name', 'width', 'height'],
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
        fields: ['id', 'name', 'width', 'height'],
      );

      final dto = SizeDto(data);
      final size = SizeMapper.toEntity(dto);

      return Success(size);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
