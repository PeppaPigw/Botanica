import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/botanica_tokens.dart';

// ignore_for_file: prefer_const_constructors_in_immutables

class BotanicaFadeThroughPage<T> extends CustomTransitionPage<T> {
  BotanicaFadeThroughPage({
    required super.child,
    super.key,
    super.fullscreenDialog = false,
  }) : super(
          transitionDuration: BotanicaTokens.motionMedium,
          reverseTransitionDuration: BotanicaTokens.motionFast,
          transitionsBuilder: _fadeThroughTransition,
        );

  static Widget _fadeThroughTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
}

class BotanicaSlideUpPage<T> extends CustomTransitionPage<T> {
  BotanicaSlideUpPage({
    required super.child,
    super.key,
    super.fullscreenDialog = true,
  }) : super(
          transitionDuration: BotanicaTokens.motionMedium,
          reverseTransitionDuration: BotanicaTokens.motionFast,
          transitionsBuilder: _slideUpTransition,
        );

  static Widget _slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ),
        child: child,
      ),
    );
  }
}
