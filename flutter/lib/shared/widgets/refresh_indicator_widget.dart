import 'package:flutter/material.dart';

class RefreshIndicatorWidget extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const RefreshIndicatorWidget({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
