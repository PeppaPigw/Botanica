import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/app/theme/botanica_tokens.dart';

void main() {
  test('Color.withValues(alpha: ...) compiles', () {
    const base = Color(0xFF112233);
    final next = base.withValues(alpha: 0.5);
    expect(next.alpha, 128);
  });
}
