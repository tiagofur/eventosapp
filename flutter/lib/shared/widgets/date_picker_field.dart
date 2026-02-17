import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    required this.label,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        label: label,
        hintText: value != null
            ? DateFormat('d MMM yyyy', 'es').format(value!)
            : 'Seleccionar fecha',
        suffixIcon: const Icon(Icons.calendar_today, size: 20),
        child: Text(
          value != null
              ? DateFormat('d MMM yyyy', 'es').format(value!)
              : '',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (selected != null && context.mounted) {
      onChanged?.call(selected);
    }
  }
}

class InputDecorator extends StatelessWidget {
  final String label;
  final String hintText;
  final Widget child;
  final Widget? suffixIcon;

  const InputDecorator({
    required this.label,
    required this.hintText,
    required this.child,
    this.suffixIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hintText,
                  style: TextStyle(
                    fontSize: 16,
                    color: hintText.isEmpty
                        ? Theme.of(context).hintColor
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (suffixIcon != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: suffixIcon!,
            ),
          ],
        ],
      ),
    );
  }
}
