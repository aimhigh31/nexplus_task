import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 애플리케이션 로깅을 담당하는 서비스
class LoggingService {
  final String? serverLogUrl;
  
  /// 생성자
  LoggingService({this.serverLogUrl});
  
  /// 일반 정보 로그
  void info(String message, {Map<String, dynamic>? data, String? category}) {
    _log('INFO', message, data: data, category: category);
  }
  
  /// 경고 로그
  void warning(String message, {Map<String, dynamic>? data, String? category}) {
    _log('WARNING', message, data: data, category: category);
  }
  
  /// 오류 로그
  void error(String message, {dynamic exception, Map<String, dynamic>? data, String? category}) {
    final logData = data ?? {};
    if (exception != null) {
      logData['exception'] = exception.toString();
    }
    _log('ERROR', message, data: logData, category: category);
  }
  
  /// API 요청 로그
  void apiRequest(String method, String url, {Map<String, dynamic>? data}) {
    _log('API_REQUEST', '$method $url', data: data, category: 'api');
  }
  
  /// API 응답 로그
  void apiResponse(String method, String url, int statusCode, {String? body, Map<String, dynamic>? data}) {
    final logData = data ?? {};
    logData['statusCode'] = statusCode;
    
    // 오류 응답인 경우 본문 포함
    if (statusCode >= 400 && body != null) {
      logData['responseBody'] = body.length > 1000 ? '${body.substring(0, 1000)}...' : body;
    }
    
    _log('API_RESPONSE', '$method $url', data: logData, category: 'api');
  }
  
  /// API 오류 로그
  void apiError(String method, String url, dynamic error, {Map<String, dynamic>? data}) {
    final logData = data ?? {};
    logData['error'] = error.toString();
    
    _log('API_ERROR', '$method $url', data: logData, category: 'api');
  }
  
  /// 내부 로깅 메서드
  void _log(String level, String message, {Map<String, dynamic>? data, String? category}) {
    // 1. 콘솔 로깅 (디버그 모드일 때만)
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final categoryText = category != null ? '[$category]' : '';
      final dataText = data != null && data.isNotEmpty ? '\n  Data: ${_formatData(data)}' : '';
      
      debugPrint('$timestamp [$level] $categoryText $message$dataText');
    }
    
    // 2. 서버 로깅 (서버 URL이 설정된 경우)
    _logToServer(level, message, data: data, category: category);
  }
  
  /// 데이터 포맷팅 헬퍼
  String _formatData(Map<String, dynamic> data) {
    try {
      return data.entries.map((e) => '${e.key}: ${_truncateValue(e.value)}').join(', ');
    } catch (e) {
      return 'Error formatting data: $e';
    }
  }
  
  /// 긴 값 자르기
  String _truncateValue(dynamic value) {
    final stringValue = value.toString();
    return stringValue.length > 100 ? '${stringValue.substring(0, 100)}...' : stringValue;
  }
  
  /// 서버에 로그 전송
  Future<void> _logToServer(String level, String message, {Map<String, dynamic>? data, String? category}) async {
    if (serverLogUrl == null) return;
    
    try {
      final logData = {
        'level': level,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
        'category': category,
      };
      
      await http.post(
        Uri.parse(serverLogUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(logData),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('Timeout', 408),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('서버 로깅 실패: $e');
      }
    }
  }
} 