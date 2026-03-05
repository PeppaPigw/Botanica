@Tags(['integration'])
library ai_proxy_integration_test;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

class _ProxyHandle {
  _ProxyHandle({required this.process, required this.baseUri});

  final Process process;
  final Uri baseUri;

  Future<void> dispose() async {
    process.kill(ProcessSignal.sigterm);
    try {
      await process.exitCode.timeout(const Duration(seconds: 2));
    } catch (_) {
      process.kill(ProcessSignal.sigkill);
    }
  }
}

Future<_ProxyHandle> _startProxy({
  required String proxyToken,
  String upstreamKey = 'dummy',
}) async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();

  final process = await Process.start(
    'node',
    ['server/ai_proxy/index.js'],
    workingDirectory: Directory.current.path,
    environment: <String, String>{
      ...Platform.environment,
      'PORT': '$port',
      'BOTANICA_GPTGOD_API_KEY': upstreamKey,
      'BOTANICA_PROXY_TOKEN': proxyToken,
      // Never hit the real upstream in tests. The proxy should reject/accept
      // before forwarding for these cases.
      'BOTANICA_AI_UPSTREAM_URL': 'http://127.0.0.1:$port/__upstream_stub',
    },
  );

  final ready = Completer<void>();
  final outSub = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    if (line.contains('Botanica AI proxy listening')) {
      if (!ready.isCompleted) ready.complete();
    }
  });
  final errSub = process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((_) {});

  try {
    await ready.future.timeout(const Duration(seconds: 3));
  } finally {
    await outSub.cancel();
    await errSub.cancel();
  }

  return _ProxyHandle(
    process: process,
    baseUri: Uri.parse('http://127.0.0.1:$port'),
  );
}

Future<HttpClientResponse> _post(
  Uri baseUri,
  String path, {
  Map<String, String> headers = const <String, String>{},
  String body = '{}',
}) async {
  final client = HttpClient();
  final req = await client.postUrl(baseUri.replace(path: path));
  headers.forEach(req.headers.set);
  req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  req.write(body);
  final res = await req.close();
  client.close(force: true);
  return res;
}

Future<String> _readBody(HttpClientResponse res) async =>
    res.transform(utf8.decoder).join();

void main() {
  const token = 'test-token';

  test('proxy rejects missing X-Botanica-Client token', () async {
    final proxy = await _startProxy(proxyToken: token);
    addTearDown(proxy.dispose);

    final res = await _post(proxy.baseUri, '/v1/chat/completions', body: '{}');
    expect(res.statusCode, 401);
  });

  test('proxy rejects oversized payloads with 413', () async {
    final proxy = await _startProxy(proxyToken: token);
    addTearDown(proxy.dispose);

    final large = List.filled(9 * 1024, 'A').join();
    final res = await _post(
      proxy.baseUri,
      '/v1/chat/completions',
      headers: const {'X-Botanica-Client': token},
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'user', 'content': large},
        ],
        'stream': false,
      }),
    );

    expect(res.statusCode, 413);
    final body = await _readBody(res);
    expect(body, contains('payload_too_large'));
  });

  test('proxy rate limits after burst traffic (429 + Retry-After)', () async {
    final proxy = await _startProxy(proxyToken: token);
    addTearDown(proxy.dispose);

    HttpClientResponse? last;
    for (var i = 0; i < 25; i++) {
      last = await _post(
        proxy.baseUri,
        '/__test__',
        headers: const {'X-Botanica-Client': token},
        body: '{}',
      );
      if (i < 20) {
        expect(last.statusCode, 404);
      }
    }

    expect(last, isNotNull);
    expect(last!.statusCode, 429);
    final retryAfter = last.headers.value(HttpHeaders.retryAfterHeader);
    expect(retryAfter, isNotNull);
    expect(int.tryParse(retryAfter!), isNotNull);
  });
}
