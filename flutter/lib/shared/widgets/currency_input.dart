import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyInput extends StatelessWidget {
  final String label;
  final double? value;
  final ValueChanged<double?>? onChanged;
  final String? hintText;
  final int? decimals;

  const CurrencyInput({
    required this.label,
    this.value,
    this.onChanged,
    this.hintText,
    this.decimals,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: const Icon(Icons.attach_money, size: 20),
        border: const OutlineInputBorder(),
      ),
      inputFormatters: [
        CurrencyInputFormatter(decimals: decimals ?? 2),
      ],
      onChanged: (text) {
        if (text.isEmpty) {
          onChanged?.call(null);
          return;
        }
        final value = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
        onChanged?.call(value);
      },
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  final int decimals;

  CurrencyInputFormatter({this.decimals = 2});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final regExp = RegExp(r'^(\d*\.?\d{0,2})');
    final match = regExp.firstMatch(newValue.text);
    String newText = match?.group(1) ?? '0';

    if (newText.contains('.')) {
      final parts = newText.split('.');
      if (parts.length > 2) {
        newText = '${parts[0]}.${parts.sublist(1, 1 + decimals).join()}';
      }
    }

    return newValue.copyWith(text: newText);
  }
}
