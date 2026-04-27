import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';

/// Result payload from [MenuBundleCreateEditDialog].
class MenuBundleCreateEditResult {
  final String name;
  final List<int> menuIds;
  const MenuBundleCreateEditResult({required this.name, required this.menuIds});
}

/// Create / edit dialog for a menu bundle.
///
/// Fields: a name (used as the PDF download filename) and an ordered list of
/// included menus. The selected list order drives PDF page order. Admins add
/// menus from the "Available" section and reorder them with up/down controls.
class MenuBundleCreateEditDialog extends StatefulWidget {
  final MenuBundle? existingBundle;
  final List<Menu> availableMenus;
  final void Function(MenuBundleCreateEditResult) onSave;

  const MenuBundleCreateEditDialog({
    super.key,
    this.existingBundle,
    required this.availableMenus,
    required this.onSave,
  });

  @override
  State<MenuBundleCreateEditDialog> createState() =>
      _MenuBundleCreateEditDialogState();
}

class _MenuBundleCreateEditDialogState
    extends State<MenuBundleCreateEditDialog> {
  late final TextEditingController _nameController;
  late final List<int> _selectedMenuIds;

  bool get _isEditMode => widget.existingBundle != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingBundle?.name ?? '',
    );
    _selectedMenuIds = [...?widget.existingBundle?.menuIds];
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _canSave() {
    final name = _nameController.text.trim();
    return name.isNotEmpty && _selectedMenuIds.isNotEmpty;
  }

  void _addMenu(int menuId) {
    setState(() => _selectedMenuIds.add(menuId));
  }

  void _removeMenu(int menuId) {
    setState(() => _selectedMenuIds.remove(menuId));
  }

  void _moveUp(int index) {
    if (index <= 0) return;
    setState(() {
      final id = _selectedMenuIds.removeAt(index);
      _selectedMenuIds.insert(index - 1, id);
    });
  }

  void _moveDown(int index) {
    if (index >= _selectedMenuIds.length - 1) return;
    setState(() {
      final id = _selectedMenuIds.removeAt(index);
      _selectedMenuIds.insert(index + 1, id);
    });
  }

  void _handleSave() {
    widget.onSave(
      MenuBundleCreateEditResult(
        name: _nameController.text.trim(),
        menuIds: List.of(_selectedMenuIds),
      ),
    );
    Navigator.of(context).pop();
  }

  Menu? _menuById(int id) {
    for (final menu in widget.availableMenus) {
      if (menu.id == id) return menu;
    }
    return null;
  }

  List<Menu> get _availableUnselected => widget.availableMenus
      .where((m) => !_selectedMenuIds.contains(m.id))
      .toList();

  @override
  Widget build(BuildContext context) {
    return isApplePlatform(context)
        ? _buildAppleForm(context)
        : _buildMaterialDialog(context);
  }

  Widget _buildAppleForm(BuildContext context) {
    final title = _isEditMode ? 'Edit Bundle' : 'Create Bundle';
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _canSave() ? _handleSave : null,
          child: const Text('Save'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('BUNDLE NAME'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _nameController,
                  prefix: const Text('Name'),
                  placeholder: 'SampleRestaurantMenu',
                  autofocus: !_isEditMode,
                ),
              ],
            ),
            if (_selectedMenuIds.isNotEmpty)
              CupertinoFormSection.insetGrouped(
                header: const Text('SELECTED MENUS (PDF ORDER)'),
                children: [
                  for (var i = 0; i < _selectedMenuIds.length; i++)
                    _buildCupertinoSelectedRow(i),
                ],
              ),
            if (_availableUnselected.isNotEmpty)
              CupertinoFormSection.insetGrouped(
                header: const Text('AVAILABLE MENUS'),
                children: _availableUnselected
                    .map(_buildCupertinoAvailableRow)
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoSelectedRow(int index) {
    final id = _selectedMenuIds[index];
    final menu = _menuById(id);
    final isFirst = index == 0;
    final isLast = index == _selectedMenuIds.length - 1;
    return CupertinoListTile(
      key: Key('bundle_selected_slot_$index'),
      leading: Text('${index + 1}.'),
      title: Text(menu?.name ?? 'Menu $id'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: isFirst ? null : () => _moveUp(index),
            child: const Icon(CupertinoIcons.arrow_up),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: isLast ? null : () => _moveDown(index),
            child: const Icon(CupertinoIcons.arrow_down),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _removeMenu(id),
            child: const Icon(CupertinoIcons.clear),
          ),
        ],
      ),
    );
  }

  Widget _buildCupertinoAvailableRow(Menu menu) {
    return CupertinoListTile(
      title: Text(menu.name),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _addMenu(menu.id),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(_isEditMode ? 'Edit Bundle' : 'Create Bundle'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('bundle_name_field'),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (used as PDF filename)',
                ),
                autofocus: !_isEditMode,
              ),
              const SizedBox(height: 16),
              Text('Selected menus (PDF order)', style: textTheme.titleSmall),
              const SizedBox(height: 4),
              if (_selectedMenuIds.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No menus selected yet. Add menus from the list below.',
                  ),
                )
              else
                for (var i = 0; i < _selectedMenuIds.length; i++)
                  _buildMaterialSelectedRow(i),
              const SizedBox(height: 16),
              Text('Available menus', style: textTheme.titleSmall),
              const SizedBox(height: 4),
              if (_availableUnselected.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('All menus are already in this bundle.'),
                )
              else
                ..._availableUnselected.map(_buildMaterialAvailableRow),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          key: const Key('bundle_save_button'),
          onPressed: _canSave() ? _handleSave : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildMaterialSelectedRow(int index) {
    final id = _selectedMenuIds[index];
    final menu = _menuById(id);
    final isFirst = index == 0;
    final isLast = index == _selectedMenuIds.length - 1;
    return ListTile(
      key: Key('bundle_selected_slot_$index'),
      dense: true,
      leading: Text('${index + 1}.'),
      title: Text(menu?.name ?? 'Menu $id'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: Key('bundle_move_up_$id'),
            icon: const Icon(Icons.arrow_upward),
            tooltip: 'Move up',
            onPressed: isFirst ? null : () => _moveUp(index),
          ),
          IconButton(
            key: Key('bundle_move_down_$id'),
            icon: const Icon(Icons.arrow_downward),
            tooltip: 'Move down',
            onPressed: isLast ? null : () => _moveDown(index),
          ),
          IconButton(
            key: Key('bundle_remove_$id'),
            icon: const Icon(Icons.close),
            tooltip: 'Remove',
            onPressed: () => _removeMenu(id),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialAvailableRow(Menu menu) {
    return ListTile(
      dense: true,
      title: Text(menu.name),
      trailing: IconButton(
        key: Key('bundle_add_${menu.id}'),
        icon: const Icon(Icons.add),
        tooltip: 'Add to bundle',
        onPressed: () => _addMenu(menu.id),
      ),
    );
  }
}
