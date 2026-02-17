import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionSheetWidget {
  static void show({
    required BuildContext context,
    required String title,
    required List<ActionSheetItem> actions,
  }) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        actions: actions.map((action) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              action.onPressed();
            },
            child: Text(action.label),
          );
        }).toList(),
      ),
    );
  }
}

class ActionSheetItem {
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  const ActionSheetItem({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });
}
