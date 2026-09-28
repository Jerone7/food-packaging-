/// Security & HTTP Interceptor Service
/// (Module 19: Security & Validation)
///
/// Manages security headers, standardized error envelope parsing,
/// session expiration detection (HTTP 401), rate limiting throttling (HTTP 429),
/// and administrative security audit endpoints.
library security_service;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Structured API Error Envelope representing standard backend error responses.
class ApiErrorEnvelope {
  final String code;
  final String message;
  final int statusCode;
  final DateTime? timestamp;
  final String? requestId;
  final Map<String, dynamic>? details;
  final int? retryAfterSeconds;

  const ApiErrorEnvelope({
    required this.code,
    required this.message,
    required this.statusCode,
    this.timestamp,
    this.requestId,
    this.details,
    this.retryAfterSeconds,
  });

  /// Factory constructor to parse any HTTP response into a structured ApiErrorEnvelope.
  factory ApiErrorEnvelope.fromResponse(http.Response response) {
    int? retryHeader;
    final retryHeaderVal = response.headers['retry-after'];
    if (retryHeaderVal != null) {
      retryHeader = int.tryParse(retryHeaderVal);
    }

    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('error') && decoded['error'] is Map<String, dynamic>) {
          final errMap = decoded['error'] as Map<String, dynamic>;
          return ApiErrorEnvelope(
            code: errMap['code']?.toString() ?? 'API_ERROR',
            message: errMap['message']?.toString() ?? 'An error occurred.',
            statusCode: (errMap['status_code'] as num?)?.toInt() ?? response.statusCode,
            timestamp: errMap['timestamp'] != null
                ? DateTime.tryParse(errMap['timestamp'].toString())
                : null,
            requestId: errMap['request_id']?.toString(),
            details: errMap['details'] is Map<String, dynamic>
                ? errMap['details'] as Map<String, dynamic>
                : null,
            retryAfterSeconds: retryHeader ??
                (errMap['details'] is Map ? errMap['details']['retry_after_seconds'] : null),
          );
        }

        // Standard FastAPI detail envelope fallback
        if (decoded.containsKey('detail')) {
          final detail = decoded['detail'];
          String msg = 'Request failed.';
          if (detail is String) {
            msg = detail;
          } else if (detail is List) {
            msg = detail.map((d) {
              if (d is Map && d.containsKey('msg')) return d['msg'];
              return d.toString();
            }).join(', ');
          }

          return ApiErrorEnvelope(
            code: response.statusCode == 422 ? 'VALIDATION_ERROR' : 'HTTP_${response.statusCode}',
            message: msg,
            statusCode: response.statusCode,
            retryAfterSeconds: retryHeader,
          );
        }
      }
    } catch (_) {
      // Body is not JSON (e.g. plain text or HTML 502/504 gateway response)
    }

    return ApiErrorEnvelope(
      code: 'HTTP_${response.statusCode}',
      message: _getDefaultStatusMessage(response.statusCode),
      statusCode: response.statusCode,
      retryAfterSeconds: retryHeader,
    );
  }

  static String _getDefaultStatusMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request parameters.';
      case 401:
        return 'Session expired or invalid credentials. Please sign in again.';
      case 403:
        return 'Access denied. Administrative privileges are required.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return 'Input data failed validation checks.';
      case 429:
        return 'Too many requests. Rate limit exceeded. Please wait a moment.';
      case 500:
      default:
        return 'A server error occurred. Please try again later.';
    }
  }

  /// Clean, user-facing summary string suitable for SnackBar alerts.
  String get userFacingMessage {
    if (statusCode == 429 && retryAfterSeconds != null && retryAfterSeconds! > 0) {
      return 'Rate limit reached. Please wait $retryAfterSeconds seconds before retrying.';
    }
    return message;
  }
}

/// Security Exception thrown when API requests fail security checks.
class SecurityException implements Exception {
  final ApiErrorEnvelope error;
  SecurityException(this.error);

  @override
  String toString() => 'SecurityException [${error.statusCode} ${error.code}]: ${error.message}';
}

/// Core Security and HTTP Interceptor Service.
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  /// Creates secure HTTP headers with Bearer token authentication and client identifiers.
  static Map<String, String> buildHeaders({String? token, Map<String, String>? extra}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Platform': 'SmartPack-Flutter',
    };
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  /// Intercepts and validates HTTP responses, triggering security callbacks as necessary.
  static http.Response processResponse(
    http.Response response, {
    VoidCallback? onUnauthorized,
    void Function(int retryAfterSeconds)? onRateLimited,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    final envelope = ApiErrorEnvelope.fromResponse(response);

    if (response.statusCode == 401) {
      onUnauthorized?.call();
    } else if (response.statusCode == 429) {
      final waitSec = envelope.retryAfterSeconds ?? 60;
      onRateLimited?.call(waitSec);
    }

    throw SecurityException(envelope);
  }

  /// Queries the public system security health status endpoint (/api/v1/security/health).
  Future<Map<String, dynamic>> getSecurityHealth({http.Client? client}) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.get(
        Uri.parse('${ApiService.baseUrl}/security/health'),
        headers: buildHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {
        'status': 'degraded',
        'rate_limiter_active': true,
        'rbac_enforced': true,
        'version': '1.0.0',
      };
    } catch (_) {
      return {
        'status': 'offline_mode',
        'rate_limiter_active': true,
        'rbac_enforced': true,
        'version': '1.0.0',
      };
    }
  }

  /// Queries the administrative security audit logs endpoint (/api/v1/security/admin/audit-logs).
  Future<List<Map<String, dynamic>>> getAuditLogs({
    required String token,
    int limit = 50,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.get(
        Uri.parse('${ApiService.baseUrl}/security/admin/audit-logs?limit=$limit'),
        headers: buildHeaders(token: token),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['audit_logs'] is List) {
          return List<Map<String, dynamic>>.from(decoded['audit_logs'] as List);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
