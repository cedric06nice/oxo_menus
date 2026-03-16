import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/presentation/helpers/snackbar_helper.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_provider.dart';
import 'package:oxo_menus/presentation/providers/connectivity_provider.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/widgets/template_card.dart';
import 'package:oxo_menus/presentation/helpers/grid_helpers.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_error_state.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_loading_indicator.dart';
import 'package:oxo_menus/presentation/widgets/common/authenticated_scaffold.dart';
import 'package:oxo_menus/presentation/widgets/common/empty_state.dart';
import 'package:oxo_menus/presentation/widgets/common/status_filter_bar.dart';
import 'package:oxo_menus/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';

class AdminTemplatesPage extends ConsumerStatefulWidget {
  const AdminTemplatesPage({super.key});

  @override
  ConsumerState<AdminTemplatesPage> createState() => _AdminTemplatesPageState();
}

class _AdminTemplatesPageState extends ConsumerState<AdminTemplatesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminTemplatesProvider.notifier).loadTemplates();
      _listenForConnectivityRestore();
    });
  }

  void _listenForConnectivityRestore() {
    ref.listenManual(connectivityProvider, (prev, next) {
      final wasOffline = prev?.value == ConnectivityStatus.offline;
      final isOnline = next.value == ConnectivityStatus.online;
      if (wasOffline && isOnline) {
        ref.read(adminTemplatesProvider.notifier).loadTemplates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminTemplatesProvider);
    final isApple = isApplePlatform(context);

    return AuthenticatedScaffold(
      title: 'Templates',
      actions: [
        if (isApple)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: () => context.push('/admin/templates/create'),
            child: const Icon(CupertinoIcons.add),
          )
        else
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/templates/create'),
            tooltip: 'Create Template',
          ),
      ],
      body: Column(
        children: [
          _buildStatusFilters(),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    final state = ref.watch(adminTemplatesProvider);
    return StatusFilterBar(
      selectedFilter: state.statusFilter,
      onFilterChanged: (status) => ref
          .read(adminTemplatesProvider.notifier)
          .loadTemplates(statusFilter: status),
    );
  }

  Widget _buildBody(dynamic state) {
    if (state.isLoading) {
      return const Center(child: AdaptiveLoadingIndicator());
    }

    if (state.errorMessage != null) {
      return AdaptiveErrorState(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(adminTemplatesProvider.notifier).loadTemplates(),
      );
    }

    if (state.templates.isEmpty) {
      return _buildEmptyState();
    }

    return _buildTemplatesGrid(state.templates);
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: isApplePlatform(context)
          ? CupertinoIcons.doc_text
          : Icons.restaurant_menu,
      title: 'No templates found',
      subtitle: 'Create your first template to get started',
      actionLabel: 'Create Template',
      onAction: () => context.push('/admin/templates/create'),
    );
  }

  Widget _buildTemplatesGrid(List<Menu> templates) {
    return SingleChildScrollView(
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
                children: templates.map((template) {
                  return TemplateCard(
                    template: template,
                    onTap: () =>
                        context.push('/admin/templates/${template.id}'),
                    onEdit: () =>
                        context.push('/admin/templates/${template.id}'),
                    onDelete: () => _confirmDelete(template),
                  );
                }).toList(),
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
          'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
    );

    if (confirmed == true && mounted) {
      await ref
          .read(adminTemplatesProvider.notifier)
          .deleteTemplate(template.id);

      if (mounted) {
        showThemedSnackBar(context, 'Template "${template.name}" deleted');
      }
    }
  }
}
