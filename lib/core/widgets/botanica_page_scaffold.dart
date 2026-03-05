import 'package:flutter/material.dart';

import 'botanica_scaffold.dart';

class BotanicaPageScaffold extends StatelessWidget {
  const BotanicaPageScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundIntensity = 1.0,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final double backgroundIntensity;

  @override
  Widget build(BuildContext context) {
    return BotanicaScaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      backgroundIntensity: backgroundIntensity,
    );
  }
}
