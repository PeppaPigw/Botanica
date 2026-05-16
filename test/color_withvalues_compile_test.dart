import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Color.withValues(alpha: ...) compiles', () {
    const base = Color(0xFF112233);
    final next = base.withValues(alpha: 0.5);
    expect((next.a * 255.0).round().clamp(0, 255), 128);
  });
}
