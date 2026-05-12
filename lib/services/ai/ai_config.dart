import 'package:flutter/foundation.dart';

enum AiAuthMode {
  /// Calls an unauthenticated proxy (recommended for production).
  none,

  /// Calls an OpenAI-compatible API that requires a Bearer token.
  bearer,
}

class AiConfig {
  const AiConfig({
    required this.baseUrl,
    required this.model,
    required this.authMode,
    required this.proxyToken,
  });

  /// Base URL for an OpenAI-compatible endpoint.
  ///
  /// For production mobile apps, **do not** point directly at an upstream API
  /// that requires a long-lived secret. Instead, point to your own proxy where
  /// the API key is stored server-side.
  final String baseUrl;
  final String model;
  final AiAuthMode authMode;

  /// Optional lightweight client token sent as `X-Botanica-Client` when set.
  ///
  /// This is not a substitute for proper auth. It is used by the Botanica proxy
  /// as a small abuse-prevention speed bump when the proxy URL is discovered.
  final String proxyToken;

  bool get requiresApiKey => authMode == AiAuthMode.bearer;

  factory AiConfig.fromEnvironment() {
    return AiConfig(
      baseUrl: const String.fromEnvironment(
        'BOTANICA_AI_BASE_URL',
        // Default to a local proxy for development. For devices/emulators you
        // may need to override this (e.g. Android emulator: 10.0.2.2).
        defaultValue: kReleaseMode ? 'https://ai.botanica-app.com/v1' : 'http://localhost:8787',
      ),
      model: const String.fromEnvironment(
        'BOTANICA_AI_MODEL',
        defaultValue: 'gpt-4o-mini',
      ),
      authMode: _authModeFromEnv(
        const String.fromEnvironment(
          'BOTANICA_AI_AUTH',
          // The recommended mode for mobile is an unauthenticated proxy.
          defaultValue: 'none',
        ),
      ),
      proxyToken: const String.fromEnvironment(
        'BOTANICA_PROXY_TOKEN',
        defaultValue: '',
      ),
    );
  }
}

AiAuthMode _authModeFromEnv(String raw) {
  final value = raw.trim().toLowerCase();
  return switch (value) {
    'none' || 'proxy' || 'unauthenticated' => AiAuthMode.none,
    _ => AiAuthMode.bearer,
  };
}
