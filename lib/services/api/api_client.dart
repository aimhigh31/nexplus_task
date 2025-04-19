// 표준 Dart 라이브러리 임포트
import 'dart:convert';
import 'dart:async';
import 'dart:io';

// Flutter 패키지
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;

// 외부 패키지
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/logging_service.dart';

/// API 통신을 담당하는 클라이언트 클래스
/// 기본적인 HTTP 요청 래퍼 메서드를 제공합니다.
class ApiClient {
  final String baseUrl;
  
  /// 생성자
  ApiClient({required this.baseUrl});
  
  /// 안전한 GET 요청을 수행합니다.
  Future<http.Response> safeGet(Uri uri, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        uri,
        headers: headers ?? {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => http.Response('Timeout', 408),
      );
      
      _logResponse('GET', uri, response);
      return response;
    } catch (e) {
      _logError('GET', uri, e);
      return http.Response('Error: $e', 500);
    }
  }
  
  /// 안전한 POST 요청을 수행합니다.
  Future<http.Response> safePost(Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      final response = await http.post(
        uri,
        headers: headers ?? {'Content-Type': 'application/json'},
        body: body,
        encoding: encoding ?? utf8,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => http.Response('Timeout', 408),
      );
      
      _logResponse('POST', uri, response);
      return response;
    } catch (e) {
      _logError('POST', uri, e);
      return http.Response('Error: $e', 500);
    }
  }
  
  /// 안전한 PUT 요청을 수행합니다.
  Future<http.Response> safePut(Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      final response = await http.put(
        uri,
        headers: headers ?? {'Content-Type': 'application/json'},
        body: body,
        encoding: encoding ?? utf8,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => http.Response('Timeout', 408),
      );
      
      _logResponse('PUT', uri, response);
      return response;
    } catch (e) {
      _logError('PUT', uri, e);
      return http.Response('Error: $e', 500);
    }
  }
  
  /// 안전한 DELETE 요청을 수행합니다.
  Future<http.Response> safeDelete(Uri uri, {Map<String, String>? headers}) async {
    try {
      final response = await http.delete(
        uri,
        headers: headers ?? {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => http.Response('Timeout', 408),
      );
      
      _logResponse('DELETE', uri, response);
      return response;
    } catch (e) {
      _logError('DELETE', uri, e);
      return http.Response('Error: $e', 500);
    }
  }
  
  /// 응답 로깅 메서드
  void _logResponse(String method, Uri uri, http.Response response) {
    if (kDebugMode) {
      debugPrint('[$method] ${uri.toString()} → ${response.statusCode}');
      if (response.statusCode >= 400) {
        debugPrint('  응답: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');
      }
    }
  }
  
  /// 오류 로깅 메서드
  void _logError(String method, Uri uri, dynamic error) {
    if (kDebugMode) {
      debugPrint('[$method] ${uri.toString()} → 오류: $error');
    }
  }
} 