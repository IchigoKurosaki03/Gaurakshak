import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? _defaultBaseUrl;

  final http.Client _client;
  final String baseUrl;
  static const _timeout = Duration(seconds: 12);

  static String get _defaultBaseUrl {
    const configured = String.fromEnvironment('GAURAKSHAK_API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    // Local web previews use the IPv4 loopback explicitly. This avoids a
    // Windows localhost -> IPv6 mismatch when Uvicorn is bound to 127.0.0.1.
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    // Android emulators reach the host machine through 10.0.2.2. Physical
    // phones must receive their LAN/HTTPS URL through --dart-define.
    return 'http://10.0.2.2:8000';
  }

  Future<Object?> get(String path, {String? token}) =>
      _send('GET', path, token: token);
  Future<Object?> post(String path, {Object? body, String? token}) =>
      _send('POST', path, body: body, token: token);
  Future<Object?> patch(String path, {Object? body, String? token}) =>
      _send('PATCH', path, body: body, token: token);
  Future<Object?> delete(String path, {String? token}) =>
      _send('DELETE', path, token: token);

  Future<Object?> _send(
    String method,
    String path, {
    Object? body,
    String? token,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers['Accept'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    try {
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic>
            ? decoded['detail']?.toString()
            : null;
        throw ApiException(
          message ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on Exception catch (error) {
      throw ApiException('Could not reach the service: $error');
    }
  }

  void dispose() => _client.close();
}
