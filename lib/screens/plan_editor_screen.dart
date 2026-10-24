import 'package:flutter/material.dart';

import '../logic/plan_rules.dart';

// This screen is the form for making a new workout plan.
class PlanEditorScreen extends StatefulWidget {
  const PlanEditorScreen({super.key});

  @override
  State<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends State<PlanEditorScreen> {
  // The form key lets the Done button check every field at once.
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _focusArea;

  // Controllers hold memory, so they are cleaned up when the screen closes.
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // This method checks that the name is not blank and not too long.
  String? _validateTitle(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Please enter a plan name.';
    if (text.length > PlanRules.maxTitleLength) {
      return 'Use ${PlanRules.maxTitleLength} characters or fewer.';
    }
    return null;
  }

  // This method checks that a focus area was chosen.
  String? _validateFocus(String? value) {
    if (value == null) return 'Please choose a focus area.';
    return null;
  }

  // This method runs when Done is pressed.
  void _onDone() {
    // The form shows red error text under any field that is not valid.
    if (!_formKey.currentState!.validate()) return;

    // Saving to the database is added in a later step.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('The form is valid.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Plan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              maxLength: PlanRules.maxTitleLength,
              textCapitalization: TextCapitalization.sentences,
              validator: _validateTitle,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLength: PlanRules.maxDescriptionLength,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _focusArea,
              decoration: const InputDecoration(
                labelText: 'Focus area',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final area in PlanRules.focusAreas)
                  DropdownMenuItem(value: area, child: Text(area)),
              ],
              onChanged: (value) {
                setState(() {
                  _focusArea = value;
                });
              },
              validator: _validateFocus,
            ),
          ],
        ),
      ),
      // The bottom bar matches the Cancel and Done boxes in the wireframe.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _onDone,
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
