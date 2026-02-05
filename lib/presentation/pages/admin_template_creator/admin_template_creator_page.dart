import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminTemplateCreatorPage extends ConsumerStatefulWidget {
  const AdminTemplateCreatorPage({super.key});

  @override
  ConsumerState<AdminTemplateCreatorPage> createState() =>
      _AdminTemplateCreatorPageState();
}

class _AdminTemplateCreatorPageState
    extends ConsumerState<AdminTemplateCreatorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Template'),
      ),
      body: const Center(
        child: Text('Admin Template Creator Page Content Here'),
      ),
    );
  }
}