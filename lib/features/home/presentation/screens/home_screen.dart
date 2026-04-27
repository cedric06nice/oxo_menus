import 'package:flutter/material.dart';
import 'package:oxo_menus/features/home/presentation/state/home_state.dart';
import 'package:oxo_menus/features/home/presentation/view_models/home_view_model.dart';
import 'package:oxo_menus/features/home/presentation/widgets/quick_action_card.dart';
import 'package:oxo_menus/features/home/presentation/widgets/welcome_card.dart';
import 'package:oxo_menus/shared/presentation/theme/app_spacing.dart';

/// MVVM-stack home screen.
///
/// Pure widget — owns no auth state, no Riverpod providers, no navigation.
/// Reads display state from the injected [HomeViewModel] and forwards
/// quick-action taps back to it.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel.state;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeCard(
                    user: state.user,
                    isAdmin: state.isAdmin,
                    greeting: state.greeting,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Quick Actions', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _quickActions(state),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _quickActions(HomeState state) {
    final actions = <Widget>[
      SizedBox(
        width: 200,
        child: QuickActionCard(
          key: const Key('quick_action_menus'),
          icon: Icons.restaurant_menu,
          title: 'OXO Menus',
          subtitle: 'Browse and manage menus',
          onTap: widget.viewModel.goToMenus,
        ),
      ),
    ];
    if (state.isAdmin) {
      actions.addAll(<Widget>[
        SizedBox(
          width: 200,
          child: QuickActionCard(
            key: const Key('quick_action_admin_templates'),
            icon: Icons.dashboard,
            title: 'Manage Templates',
            subtitle: 'Edit and organise templates',
            onTap: widget.viewModel.goToAdminTemplates,
          ),
        ),
        SizedBox(
          width: 200,
          child: QuickActionCard(
            key: const Key('quick_action_admin_template_create'),
            icon: Icons.add_box,
            title: 'Create Template',
            subtitle: 'Start a new template',
            onTap: widget.viewModel.goToAdminTemplateCreate,
          ),
        ),
        SizedBox(
          width: 200,
          child: QuickActionCard(
            key: const Key('quick_action_admin_exportable_menus'),
            icon: Icons.picture_as_pdf,
            title: 'Exportable Menus',
            subtitle: 'Compose public PDF bundles',
            onTap: widget.viewModel.goToAdminExportableMenus,
          ),
        ),
      ]);
    }
    return actions;
  }
}
