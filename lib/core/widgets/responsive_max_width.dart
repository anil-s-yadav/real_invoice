import 'package:flutter/material.dart';

class ResponsiveMaxWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
