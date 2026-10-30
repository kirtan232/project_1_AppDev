import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// This dialog asks for a number of reps or seconds and returns it when saved.
class AmountDialog extends StatefulWidget {
  final String title;

  // The unit is "reps" or "sec" and is shown beside the number.
  final String unit;
  final int? initialAmount;

  const AmountDialog({
    super.key,
    required this.title,
    required this.unit,
    this.initialAmount,
  });

  @override
  State<AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<AmountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialAmount?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // This method checks for a whole number from 1 to 500.
  String? _validate(String? value) {
    final amount = int.tryParse((value ?? '').trim());
    if (amount == null || amount < 1 || amount > 500) {
      return 'Enter a number from 1 to 500.';
    }
    return null;
  }

  // This method closes the dialog with the number if it is valid.
  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(int.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          // Only digits can be typed, so letters and minus signs are blocked.
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Amount',
            suffixText: widget.unit,
            border: const OutlineInputBorder(),
          ),
          validator: _validate,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _onSave, child: const Text('Save')),
      ],
    );
  }
}
