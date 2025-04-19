import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// HTTP 통신을 위한 공통 클라이언트 클래스
/// 
/// 모든 HTTP 요청에 대한 안전한 래퍼 메서드를 제공하며,
/// 에러 처리 및 로깅 기능을 포함합니다.
class HttpClient {
  /// 싱글톤 패턴 구현
  static final HttpClient _instance = HttpClient._internal();
  
  factory HttpClient() => _instance;
  
  HttpClient._internal();
  
  /// HTTP GET 요청 래퍼 함수
  /// 
  /// [uri] HTTP 요청 URI
  /// [timeoutSeconds] 요청 타임아웃 시간 (초)
  /// 
  /// 에러 발생 시 처리하고 로깅합니다.
  Future<http.Response> safeGet(Uri uri, {int timeoutSeconds = 10}) async {
    try {
      return await http.get(uri, headers: {
        'Accept-Charset': 'utf-8',
        'Content-Type': 'application/json; charset=utf-8',
      }).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () => http.Response('시간 초과', 408),
      );
    } catch (e) {
      logError('GET 요청', e, uri.toString());
      return http.Response('Error: $e', 500);
    }
  }

  /// HTTP POST 요청 래퍼 함수
  /// 
  /// [uri] HTTP 요청 URI
  /// [body] 요청 본문 데이터
  /// [timeoutSeconds] 요청 타임아웃 시간 (초)
  /// 
  /// 에러 발생 시 처리하고 로깅합니다.
  Future<http.Response> safePost(Uri uri, Map<String, dynamic> body, {int timeoutSeconds = 15}) async {
    try {
      return await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(body),
      ).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () => http.Response('시간 초과', 408),
      );
    } catch (e) {
      logError('POST 요청', e, uri.toString(), body);
      return http.Response('Error: $e', 500);
    }
  }

  /// HTTP PUT 요청 래퍼 함수
  /// 
  /// [uri] HTTP 요청 URI
  /// [body] 요청 본문 데이터
  /// [timeoutSeconds] 요청 타임아웃 시간 (초)
  /// 
  /// 에러 발생 시 처리하고 로깅합니다.
  Future<http.Response> safePut(Uri uri, Map<String, dynamic> body, {int timeoutSeconds = 15}) async {
    try {
      return await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(body),
      ).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () => http.Response('시간 초과', 408),
      );
    } catch (e) {
      logError('PUT 요청', e, uri.toString(), body);
      return http.Response('Error: $e', 500);
    }
  }

  /// HTTP DELETE 요청 래퍼 함수
  /// 
  /// [uri] HTTP 요청 URI
  /// [timeoutSeconds] 요청 타임아웃 시간 (초)
  /// 
  /// 에러 발생 시 처리하고 로깅합니다.
  Future<http.Response> safeDelete(Uri uri, {int timeoutSeconds = 10}) async {
    try {
      return await http.delete(
        uri,
        headers: {
          'Accept-Charset': 'utf-8',
        },
      ).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () => http.Response('시간 초과', 408),
      );
    } catch (e) {
      logError('DELETE 요청', e, uri.toString());
      return http.Response('Error: $e', 500);
    }
  }
  
  /// 에러 로깅 함수 (디버그 정보 향상)
  /// 
  /// [operation] 수행 중이던 작업
  /// [error] 발생한 에러 
  /// [url] 요청 URL (있는 경우)
  /// [data] 요청 데이터 (있는 경우)
  void logError(String operation, dynamic error, [String? url, dynamic data]) {
    String message = '[$operation 실패] $error';
    if (url != null) {
      message += '\nURL: $url';
    }
    if (data != null) {
      if (data is Map || data is List) {
        try {
          message += '\n데이터: ${jsonEncode(data)}';
        } catch (e) {
          message += '\n데이터: $data (인코딩 불가)';
        }
      } else {
        message += '\n데이터: $data';
      }
    }
    debugPrint(message);
  }
} 