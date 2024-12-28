import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'generated/l10n.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).mainTitle),
        titleTextStyle: TextStyle(color: ColorScheme.of(context).onPrimary),
        centerTitle: true,
        backgroundColor: ColorScheme.of(context).primary,
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/riverpodCounter'),
              child: const Text('Riverpod的加减数'),
            ),
          ],
        ),
      ),
    );
  }
}
