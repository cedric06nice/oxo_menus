import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/shared/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/shared/data/mappers/error_mapper.dart';
import 'package:oxo_menus/features/menu/data/mappers/menu_bundle_mapper.dart';
import 'package:oxo_menus/features/menu/data/models/menu_bundle_dto.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';

class MenuBundleRepositoryImpl implements MenuBundleRepository {
  final DirectusDataSource dataSource;

  const MenuBundleRepositoryImpl({required this.dataSource});

  static const _fields = [
    'id',
    'name',
    'menu_ids',
    'pdf_file_id',
    'date_created',
    'date_updated',
  ];

  @override
  Future<Result<List<MenuBundle>, DomainError>> getAll() async {
    try {
      final data = await dataSource.getItems<MenuBundleDto>(
        fields: _fields,
        sort: ['name'],
      );
      final bundles = data
          .map((json) => MenuBundleDto(json))
          .map(MenuBundleMapper.toEntity)
          .toList();
      return Success(bundles);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<MenuBundle, DomainError>> getById(int id) async {
    try {
      final data = await dataSource.getItem<MenuBundleDto>(id, fields: _fields);
      return Success(MenuBundleMapper.toEntity(MenuBundleDto(data)));
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<List<MenuBundle>, DomainError>> findByIncludedMenu(
    int menuId,
  ) async {
    // Directus `_contains` on a JSON-array column has inconsistent behaviour
    // across v10/v11 and depending on whether the field is a plain JSON or an
    // M2M alias, so we filter client-side. Bundle volume is small (typically
    // well under 100 per tenant) so this is cheap and predictable.
    final all = await getAll();
    return all.map(
      (bundles) => bundles.where((b) => b.menuIds.contains(menuId)).toList(),
    );
  }

  @override
  Future<Result<MenuBundle, DomainError>> create(
    CreateMenuBundleInput input,
  ) async {
    try {
      final item = MenuBundleDto.newItem(
        name: input.name,
        menuIds: input.menuIds,
      );
      final data = await dataSource.createItem<MenuBundleDto>(item);
      return Success(MenuBundleMapper.toEntity(MenuBundleDto(data)));
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<MenuBundle, DomainError>> update(
    UpdateMenuBundleInput input,
  ) async {
    try {
      final existingData = await dataSource.getItem<MenuBundleDto>(
        input.id,
        fields: _fields,
      );
      final item = MenuBundleDto(existingData);
      final patch = MenuBundleMapper.toUpdatePayload(input);
      for (final entry in patch.entries) {
        item.setValue(entry.value, forKey: entry.key);
      }
      final data = await dataSource.updateItem<MenuBundleDto>(item);
      return Success(MenuBundleMapper.toEntity(MenuBundleDto(data)));
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }

  @override
  Future<Result<void, DomainError>> delete(int id) async {
    try {
      await dataSource.deleteItem<MenuBundleDto>(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapDirectusError(e));
    }
  }
}
