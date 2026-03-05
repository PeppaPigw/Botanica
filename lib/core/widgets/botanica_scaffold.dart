import 'package:flutter/material.dart';

import 'botanica_background.dart';

class BotanicaScaffold extends StatelessWidget {
  const BotanicaScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.backgroundIntensity = 1.0,
    this.extendBody = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final double backgroundIntensity;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    return BotanicaBackground(
      intensity: backgroundIntensity,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: extendBody,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
