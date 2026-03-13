import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';

class EditorStructureCrudHelper {
  final PageRepository pageRepository;
  final ContainerRepository containerRepository;
  final ColumnRepository columnRepository;
  final Future<void> Function() onReload;
  final void Function(String message, {bool isError})? onMessage;
  final Future<bool> Function() showDeleteConfirmation;

  const EditorStructureCrudHelper({
    required this.pageRepository,
    required this.containerRepository,
    required this.columnRepository,
    required this.onReload,
    this.onMessage,
    required this.showDeleteConfirmation,
  });

  Future<void> addPage({required int menuId, required int pageCount}) async {
    final result = await pageRepository.create(
      CreatePageInput(
        menuId: menuId,
        name: 'Page ${pageCount + 1}',
        index: pageCount,
      ),
    );

    if (result.isSuccess) {
      await onReload();
    } else {
      onMessage?.call(
        'Failed to add page: ${result.errorOrNull?.message ?? 'Unknown error'}',
        isError: true,
      );
    }
  }

  Future<void> deletePage(int pageId) async {
    final confirmed = await showDeleteConfirmation();
    if (!confirmed) return;

    final result = await pageRepository.delete(pageId);
    if (result.isSuccess) {
      await onReload();
    }
  }

  Future<void> addHeader(int menuId) async {
    final result = await pageRepository.create(
      CreatePageInput(
        menuId: menuId,
        name: 'Header',
        index: 0,
        type: entity.PageType.header,
      ),
    );

    if (result.isSuccess) {
      await onReload();
    } else {
      onMessage?.call(
        'Failed to add header: ${result.errorOrNull?.message ?? 'Unknown error'}',
        isError: true,
      );
    }
  }

  Future<void> deleteHeader(int pageId) async {
    final confirmed = await showDeleteConfirmation();
    if (!confirmed) return;

    final result = await pageRepository.delete(pageId);
    if (result.isSuccess) {
      await onReload();
    }
  }

  Future<void> addFooter(int menuId) async {
    final result = await pageRepository.create(
      CreatePageInput(
        menuId: menuId,
        name: 'Footer',
        index: 0,
        type: entity.PageType.footer,
      ),
    );

    if (result.isSuccess) {
      await onReload();
    } else {
      onMessage?.call(
        'Failed to add footer: ${result.errorOrNull?.message ?? 'Unknown error'}',
        isError: true,
      );
    }
  }

  Future<void> deleteFooter(int pageId) async {
    final confirmed = await showDeleteConfirmation();
    if (!confirmed) return;

    final result = await pageRepository.delete(pageId);
    if (result.isSuccess) {
      await onReload();
    }
  }

  Future<void> addContainer({
    required int pageId,
    required int containerCount,
  }) async {
    final result = await containerRepository.create(
      CreateContainerInput(
        pageId: pageId,
        index: containerCount,
        direction: 'portrait',
      ),
    );

    if (result.isSuccess) {
      await onReload();
    } else {
      onMessage?.call(
        'Failed to add container: ${result.errorOrNull?.message ?? 'Unknown error'}',
        isError: true,
      );
    }
  }

  Future<void> deleteContainer(int containerId) async {
    final confirmed = await showDeleteConfirmation();
    if (!confirmed) return;

    final result = await containerRepository.delete(containerId);
    if (result.isSuccess) {
      await onReload();
    }
  }

  Future<void> addColumn({
    required int containerId,
    required int columnCount,
  }) async {
    final result = await columnRepository.create(
      CreateColumnInput(containerId: containerId, index: columnCount, flex: 1),
    );

    if (result.isSuccess) {
      await onReload();
    } else {
      onMessage?.call(
        'Failed to add column: ${result.errorOrNull?.message ?? 'Unknown error'}',
        isError: true,
      );
    }
  }

  Future<void> deleteColumn(int columnId) async {
    final confirmed = await showDeleteConfirmation();
    if (!confirmed) return;

    final result = await columnRepository.delete(columnId);
    if (result.isSuccess) {
      await onReload();
    }
  }
}
