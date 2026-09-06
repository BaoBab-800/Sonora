import 'package:flutter/material.dart';
import 'package:sonora/core/l10n/l10n.dart';
import 'package:sonora/core/theme/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: Card(
          color: context.colors.primary,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(context.l10n.denchik),
          ),
        ),
      ),
    );
  }
}