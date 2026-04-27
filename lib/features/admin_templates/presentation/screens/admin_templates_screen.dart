import 'package:flutter/material.dart';
import 'package:oxo_menus/features/admin_templates/presentation/state/admin_templates_screen_state.dart';
import 'package:oxo_menus/features/admin_templates/presentation/view_models/admin_templates_view_model.dart';
import 'package:oxo_menus/features/admin_templates/presentation/widgets/template_card.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/presentation/helpers/grid_helpers.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_error_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';
import 'package:oxo_menus/shared/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:oxo_menus/shared/presentation/widgets/empty_state.dart';
import 'package:oxo_menus/shared/presentation/widgets/status_filter_bar.dart';

/// MVVM-stack admin templates screen.
///
/// Pure widget — owns no Riverpod providers and no navigation. Reads display
/// state from the injected [AdminTemplatesViewModel] and forwards user actions
/// back to it.
class AdminTemplatesScreen extends StatefulWidget {
  const AdminTemplatesScreen({super.key, required this.viewModel});

  final AdminTemplatesViewModel viewModel;

  @override
  State<AdminTemplatesScreen> createState() => _AdminTemplatesScreenState();
}

class _AdminTemplatesScreenState extends State<AdminTemplatesScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel.state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
        actions: state.isAdmin
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Create Template',
                  onPressed: widget.viewModel.openCreateTemplate,
                ),
              ]
            : null,
      ),
      body: Column(
        children: <Widget>[
          if (state.isAdmin)
            StatusFilterBar(
              selectedFilter: state.statusFilter,
              onFilterChanged: widget.viewModel.setStatusFilter,
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.viewModel.refresh,
              child: _buildBody(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminTemplatesScreenState state) {
    if (state.isLoading && state.templates.isEmpty) {
      return const Center(child: AdaptiveLoadingIndicator());
    }
    if (state.errorMessage != null && state.templates.isEmpty) {
      return _wrapInScrollable(
        AdaptiveErrorState(
          message: state.errorMessage!,
          onRetry: widget.viewModel.refresh,
        ),
      );
    }
    if (state.templates.isEmpty) {
      return _wrapInScrollable(
        EmptyState(
          icon: Icons.restaurant_menu,
          title: 'No templates found',
          subtitle: 'Create your first template to get started',
          actionLabel: 'Create Template',
          onAction: widget.viewModel.openCreateTemplate,
        ),
      );
    }
    return _buildGrid(state.templates);
  }

  Widget _wrapInScrollable(Widget child) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[SliverFillRemaining(child: child)],
    );
  }

  Widget _buildGrid(List<Menu> templates) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = computeGridColumns(constraints.maxWidth);
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: templates
                    .map(
                      (template) => TemplateCard(
                        template: template,
                        onTap: () => widget.viewModel.openTemplate(template.id),
                        onEdit: () =>
                            widget.viewModel.openTemplate(template.id),
                        onDelete: () => _confirmDelete(template),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Menu template) async {
    final confirmed = await showDeleteConfirmation(
      context,
      title: 'Delete Template',
      message:
          'Are you sure you want to delete "${template.name}"? This action '
          'cannot be undone.',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await widget.viewModel.deleteTemplate(template.id);
  }
}
