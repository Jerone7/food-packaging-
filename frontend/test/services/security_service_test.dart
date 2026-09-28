import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ai_packaging_recommender/services/security_service.dart';

void main() {
  group('ApiErrorEnvelope Tests', () {
    test('parses standardized SmartPack error envelope JSON', () {
      final response = http.Response(
        jsonEncode({
          'error': {
            'code': 'UNAUTHORIZED_ACCESS',
            'message': 'Admin privilege required.',
            'status_code': 403,
            'timestamp': '2026-09-27T12:00:00Z',
            'request_id': 'req_abc123',
            'details': {'resource': 'audit_logs'},
          }
        }),
        403,
      );

      final envelope = ApiErrorEnvelope.fromResponse(response);
      expect(envelope.code, equals('UNAUTHORIZED_ACCESS'));
      expect(envelope.message, equals('Admin privilege required.'));
      expect(envelope.statusCode, equals(403));
      expect(envelope.requestId, equals('req_abc123'));
      expect(envelope.details?['resource'], equals('audit_logs'));
      expect(envelope.userFacingMessage, equals('Admin privilege required.'));
    });

    test('parses legacy FastAPI detail string', () {
      final response = http.Response(
        jsonEncode({'detail': 'Not authenticated'}),
        401,
      );

      final envelope = ApiErrorEnvelope.fromResponse(response);
      expect(envelope.statusCode, equals(401));
      expect(envelope.message, equals('Not authenticated'));
    });

    test('parses FastAPI 422 validation detail array', () {
      final response = http.Response(
        jsonEncode({
          'detail': [
            {'loc': ['body', 'temperature'], 'msg': 'Field required'},
            {'loc': ['body', 'humidity'], 'msg': 'Input should be greater than 0'}
          ]
        }),
        422,
      );

      final envelope = ApiErrorEnvelope.fromResponse(response);
      expect(envelope.code, equals('VALIDATION_ERROR'));
      expect(envelope.message, contains('Field required'));
      expect(envelope.message, contains('Input should be greater than 0'));
    });

    test('parses non-JSON HTML/gateway error responses gracefully', () {
      final response = http.Response(
        '<html><body>502 Bad Gateway</body></html>',
        502,
      );

      final envelope = ApiErrorEnvelope.fromResponse(response);
      expect(envelope.statusCode, equals(502));
      expect(envelope.code, equals('HTTP_502'));
      expect(envelope.userFacingMessage, contains('server error'));
    });

    test('parses rate limit 429 Retry-After header', () {
      final response = http.Response(
        jsonEncode({'detail': 'Rate limit exceeded'}),
        429,
        headers: {'retry-after': '30'},
      );

      final envelope = ApiErrorEnvelope.fromResponse(response);
      expect(envelope.statusCode, equals(429));
      expect(envelope.retryAfterSeconds, equals(30));
      expect(envelope.userFacingMessage, equals('Rate limit reached. Please wait 30 seconds before retrying.'));
    });
  });

  group('SecurityService Header & Interceptor Tests', () {
    test('buildHeaders injects Authorization Bearer token and client metadata', () {
      final headers = SecurityService.buildHeaders(
        token: 'jwt_token_sample_123',
        extra: {'X-Custom-Trace': 'trace_1'},
      );

      expect(headers['Content-Type'], equals('application/json'));
      expect(headers['Authorization'], equals('Bearer jwt_token_sample_123'));
      expect(headers['X-Client-Platform'], equals('SmartPack-Flutter'));
      expect(headers['X-Custom-Trace'], equals('trace_1'));
    });

    test('processResponse passes 200 OK responses directly', () {
      final response = http.Response('{"status": "ok"}', 200);
      final result = SecurityService.processResponse(response);
      expect(result.statusCode, equals(200));
    });

    test('processResponse triggers onUnauthorized callback on 401', () {
      bool unauthorizedTriggered = false;
      final response = http.Response('{"detail": "Token expired"}', 401);

      expect(
        () => SecurityService.processResponse(
          response,
          onUnauthorized: () {
            unauthorizedTriggered = true;
          },
        ),
        throwsA(isA<SecurityException>()),
      );

      expect(unauthorizedTriggered, isTrue);
    });

    test('processResponse triggers onRateLimited callback with seconds on 429', () {
      int? rateLimitDelay;
      final response = http.Response(
        '{"detail": "Too many requests"}',
        429,
        headers: {'retry-after': '45'},
      );

      expect(
        () => SecurityService.processResponse(
          response,
          onRateLimited: (seconds) {
            rateLimitDelay = seconds;
          },
        ),
        throwsA(isA<SecurityException>()),
      );

      expect(rateLimitDelay, equals(45));
    });
  });

  group('SecurityService Endpoints API Tests', () {
    test('getSecurityHealth queries health and parses results', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/security/health')) {
          return http.Response(
            jsonEncode({
              'status': 'healthy',
              'timestamp': '2026-09-27T12:00:00Z',
              'active_protections': {
                'rate_limiter': true,
                'rbac_guards': true,
                'password_policy': true,
              },
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = SecurityService();
      final health = await service.getSecurityHealth(client: mockClient);
      expect(health['status'], equals('healthy'));
      expect(health['active_protections']['rate_limiter'], isTrue);
    });

    test('getAuditLogs queries and returns list of admin audit records', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/security/admin/audit-logs')) {
          expect(request.headers['Authorization'], equals('Bearer valid_admin_token'));
          return http.Response(
            jsonEncode({
              'total_records': 2,
              'audit_logs': [
                {
                  'id': 1,
                  'action': 'ADMIN_DELETE_FOOD',
                  'status': 'SUCCESS',
                  'user_id': 1,
                  'timestamp': '2026-09-27T12:00:00Z',
                },
                {
                  'id': 2,
                  'action': 'AUTH_FAILED',
                  'status': 'FAILURE',
                  'user_id': null,
                  'timestamp': '2026-09-27T12:01:00Z',
                }
              ]
            }),
            200,
          );
        }
        return http.Response('Forbidden', 403);
      });

      final service = SecurityService();
      final logs = await service.getAuditLogs(token: 'valid_admin_token', client: mockClient);
      expect(logs.length, equals(2));
      expect(logs[0]['action'], equals('ADMIN_DELETE_FOOD'));
      expect(logs[1]['status'], equals('FAILURE'));
    });
  });
}
