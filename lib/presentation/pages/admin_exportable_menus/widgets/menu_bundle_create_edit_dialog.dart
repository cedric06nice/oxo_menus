import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';

/// Result payload from [MenuBundleCreateEditDialog].
class MenuBundleCreateEditResult {
  final String name;
  final List<int> menuIds;
  const MenuBundleCreateEditResult({required this.name, required this.menuIds});
}

/// Create / edit dialog for a menu bundle.
///
/// Fields: a name (used as the PDF download filename) and a per-menu toggle
/// list built from the set of available menus. At least one menu must be
/// toggled on for the Save button to enable.
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
  late final Set<int> _selectedMenuIds;

  bool get _isEditMode => widget.existingBundle != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingBundle?.name ?? '',
    );
    _selectedMenuIds = {...?widget.existingBundle?.menuIds};
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

  void _toggleMenu(int menuId, bool? value) {
    setState(() {
      if (value ?? false) {
        _selectedMenuIds.add(menuId);
      } else {
        _selectedMenuIds.remove(menuId);
      }
    });
  }

  void _handleSave() {
    widget.onSave(
      MenuBundleCreateEditResult(
        name: _nameController.text.trim(),
        menuIds: _selectedMenuIds.toList(),
      ),
    );
    Navigator.of(context).pop();
  }

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
            CupertinoFormSection.insetGrouped(
              header: const Text('INCLUDED MENUS'),
              children: widget.availableMenus.map((menu) {
                return CupertinoListTile(
                  title: Text(menu.name),
                  trailing: CupertinoSwitch(
                    value: _selectedMenuIds.contains(menu.id),
                    onChanged: (v) => _toggleMenu(menu.id, v),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialDialog(BuildContext context) {
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
              Text(
                'Included menus',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              ...widget.availableMenus.map((menu) {
                return CheckboxListTile(
                  key: Key('bundle_menu_toggle_${menu.id}'),
                  value: _selectedMenuIds.contains(menu.id),
                  onChanged: (v) => _toggleMenu(menu.id, v),
                  title: Text(menu.name),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
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
}
