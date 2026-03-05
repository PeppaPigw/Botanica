import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiSecretsRepository {
  const AiSecretsRepository({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const String _apiKeyStorageKey = 'botanica.ai.api_key';

  final FlutterSecureStorage _storage;

  Future<String?> readApiKey() async {
    final raw = await _storage.read(key: _apiKeyStorageKey);
    final normalized = raw?.trim();
    return (normalized == null || normalized.isEmpty) ? null : normalized;
  }

  Future<void> writeApiKey(String? apiKey) async {
    final normalized = apiKey?.trim();
    if (normalized == null || normalized.isEmpty) {
      await _storage.delete(key: _apiKeyStorageKey);
      return;
    }

    await _storage.write(key: _apiKeyStorageKey, value: normalized);
  }
}
