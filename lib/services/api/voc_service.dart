import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../models/voc_model.dart';
import 'api_client.dart';
import '../utils/logging_service.dart';

/// VOC 데이터 관리를 담당하는 서비스 클래스
class VocService {
  final String baseUrl;
  final ApiClient _apiClient;
  final LoggingService _logger;
  
  /// 생성자
  VocService({
    required this.baseUrl,
    required ApiClient apiClient,
    required LoggingService logger,
  }) : 
    _apiClient = apiClient,
    _logger = logger;
  
  /// VOC 데이터 조회
  Future<List<VocModel>> getVocData({
    String? search,
    String? vocCategory,
    String? requestType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueDateStart,
    DateTime? dueDateEnd,
  }) async {
    try {
      _logger.info('VOC 데이터 조회 시작', data: {
        'search': search,
        'vocCategory': vocCategory,
        'requestType': requestType,
        'status': status,
      });
      
      // 쿼리 파라미터 구성
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (vocCategory != null) {
        queryParams['vocCategory'] = vocCategory;
      }
      if (requestType != null) {
        queryParams['requestType'] = requestType;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      
      // 날짜 필터 추가
      final dateFormat = DateFormat('yyyy-MM-dd');
      if (startDate != null) {
        queryParams['startDate'] = dateFormat.format(startDate);
      }
      if (endDate != null) {
        queryParams['endDate'] = dateFormat.format(endDate);
      }
      if (dueDateStart != null) {
        queryParams['dueDateStart'] = dateFormat.format(dueDateStart);
      }
      if (dueDateEnd != null) {
        queryParams['dueDateEnd'] = dateFormat.format(dueDateEnd);
      }
      
      // API 요청
      final uri = Uri.parse('$baseUrl/api/voc').replace(queryParameters: queryParams);
      final response = await _apiClient.safeGet(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final vocList = jsonData.map((item) => VocModel.fromJson(item)).toList();
        
        _logger.info('VOC 데이터 조회 성공', data: {'count': vocList.length});
        return vocList;
      } else {
        _logger.error('VOC 데이터 조회 실패', data: {
          'statusCode': response.statusCode,
          'response': response.body,
        });
        return [];
      }
    } catch (e) {
      _logger.error('VOC 데이터 조회 중 오류 발생', exception: e);
      return [];
    }
  }
  
  /// 새 VOC 추가
  Future<VocModel?> addVoc(VocModel voc) async {
    try {
      _logger.info('VOC 추가 시작', data: {'vocCode': voc.code});
      
      final uri = Uri.parse('$baseUrl/api/voc');
      final response = await _apiClient.safePost(
        uri,
        body: json.encode(voc.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final result = VocModel.fromJson(jsonData);
        
        _logger.info('VOC 추가 성공', data: {'vocCode': result.code});
        return result;
      } else {
        _logger.error('VOC 추가 실패', data: {
          'statusCode': response.statusCode,
          'response': response.body,
        });
        return null;
      }
    } catch (e) {
      _logger.error('VOC 추가 중 오류 발생', exception: e);
      return null;
    }
  }
  
  /// VOC 업데이트
  Future<VocModel?> updateVoc(VocModel voc) async {
    try {
      _logger.info('VOC 업데이트 시작', data: {'vocCode': voc.code});
      
      if (voc.code == null || voc.code!.isEmpty) {
        _logger.error('VOC 업데이트 실패: 유효하지 않은 VOC 코드');
        return null;
      }
      
      final uri = Uri.parse('$baseUrl/api/voc/${voc.code}');
      final response = await _apiClient.safePut(
        uri,
        body: json.encode(voc.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final result = VocModel.fromJson(jsonData);
        
        _logger.info('VOC 업데이트 성공', data: {'vocCode': result.code});
        return result;
      } else {
        _logger.error('VOC 업데이트 실패', data: {
          'statusCode': response.statusCode,
          'response': response.body,
        });
        return null;
      }
    } catch (e) {
      _logger.error('VOC 업데이트 중 오류 발생', exception: e);
      return null;
    }
  }
  
  /// VOC 삭제
  Future<bool> deleteVoc(String vocCode) async {
    try {
      _logger.info('VOC 삭제 시작', data: {'vocCode': vocCode});
      
      final uri = Uri.parse('$baseUrl/api/voc/$vocCode');
      final response = await _apiClient.safeDelete(uri);
      
      if (response.statusCode == 200) {
        _logger.info('VOC 삭제 성공', data: {'vocCode': vocCode});
        return true;
      } else {
        _logger.error('VOC 삭제 실패', data: {
          'statusCode': response.statusCode,
          'response': response.body,
        });
        return false;
      }
    } catch (e) {
      _logger.error('VOC 삭제 중 오류 발생', exception: e, data: {'vocCode': vocCode});
      return false;
    }
  }
  
  /// VOC 통계 데이터 조회
  Future<Map<String, dynamic>> getVocStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.info('VOC 통계 조회 시작');
      
      // 쿼리 파라미터 구성
      final queryParams = <String, String>{};
      final dateFormat = DateFormat('yyyy-MM-dd');
      
      if (startDate != null) {
        queryParams['startDate'] = dateFormat.format(startDate);
      }
      if (endDate != null) {
        queryParams['endDate'] = dateFormat.format(endDate);
      }
      
      // API 요청
      final uri = Uri.parse('$baseUrl/api/voc/stats').replace(queryParameters: queryParams);
      final response = await _apiClient.safeGet(uri);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        
        _logger.info('VOC 통계 조회 성공');
        return jsonData;
      } else {
        _logger.error('VOC 통계 조회 실패', data: {
          'statusCode': response.statusCode,
          'response': response.body,
        });
        return {};
      }
    } catch (e) {
      _logger.error('VOC 통계 조회 중 오류 발생', exception: e);
      return {};
    }
  }
  
  /// 여러 VOC 항목 삭제
  Future<Map<String, dynamic>> deleteMultipleVocs(List<String> vocCodes) async {
    try {
      _logger.info('다중 VOC 삭제 시작', data: {'count': vocCodes.length});
      
      final uri = Uri.parse('$baseUrl/api/voc/batch-delete');
      final response = await _apiClient.safePost(
        uri,
        body: json.encode({'codes': vocCodes}),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        
        _logger.info('다중 VOC 삭제 성공', data: jsonData);
        return jsonData;
      } else {
        _logger.error('다중 VOC 삭제 실패', data: {
          'statusCode': response.statusCode,
          'response': response.body,
        });
        return {'success': false, 'deleted': 0, 'failed': vocCodes.length};
      }
    } catch (e) {
      _logger.error('다중 VOC 삭제 중 오류 발생', exception: e);
      return {'success': false, 'deleted': 0, 'failed': vocCodes.length, 'error': e.toString()};
    }
  }
  
  /// VOC 엑셀 내보내기를 위한 데이터 준비
  Future<List<VocModel>> getVocExportData({
    String? search,
    String? vocCategory,
    String? requestType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueDateStart,
    DateTime? dueDateEnd,
  }) async {
    // 엑셀 내보내기를 위한 전체 데이터 조회 (페이지네이션 없음)
    return await getVocData(
      search: search,
      vocCategory: vocCategory,
      requestType: requestType,
      status: status,
      startDate: startDate,
      endDate: endDate,
      dueDateStart: dueDateStart,
      dueDateEnd: dueDateEnd,
    );
  }
} 