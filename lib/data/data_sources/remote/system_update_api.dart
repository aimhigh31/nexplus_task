import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../models/system_update_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_client.dart';

/// 시스템 업데이트 API 호출을 담당하는 클래스
class SystemUpdateApi {
  final HttpClient _httpClient;
  
  /// 시스템 업데이트 API 생성자
  SystemUpdateApi(this._httpClient);
  
  /// 시스템 업데이트 목록 조회
  /// 
  /// [search] 검색어
  /// [targetSystem] 대상 시스템
  /// [updateType] 업데이트 유형
  /// [status] 상태
  /// [startDate] 시작일
  /// [endDate] 종료일
  Future<List<SystemUpdateModel>> getSystemUpdates({
    String? search,
    String? targetSystem,
    String? updateType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    bool isSuccess = false;
    String endpoint = '';
    List<dynamic> dataList = [];
    
    // 쿼리 파라미터 구성
    final Map<String, String> queryParams = {};
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    if (targetSystem != null && targetSystem.isNotEmpty) {
      queryParams['targetSystem'] = targetSystem;
    }
    
    if (updateType != null && updateType.isNotEmpty) {
      queryParams['updateType'] = updateType;
    }
    
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    
    if (startDate != null) {
      queryParams['startDate'] = DateFormat('yyyy-MM-dd').format(startDate);
    }
    
    if (endDate != null) {
      queryParams['endDate'] = DateFormat('yyyy-MM-dd').format(endDate);
    }
    
    try {
      // 첫 번째 시도: 솔루션 개발 전용 API
      try {
        final uri = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.solutionDevelopmentEndpoint}')
            .replace(queryParameters: queryParams);
        debugPrint('시도 1 (솔루션 개발 API): $uri');
          
        final response = await _httpClient.safeGet(uri);
        debugPrint('solution-development 응답 상태: ${response.statusCode}');
          
        if (response.statusCode == 200) {
          dataList = json.decode(response.body);
          debugPrint('solution-development 엔드포인트에서 ${dataList.length}개 데이터 로드 성공');
          isSuccess = true;
          endpoint = 'solution-development';
        } else {
          debugPrint('solution-development 엔드포인트 요청 실패: ${response.statusCode}');
          debugPrint('응답 본문: ${response.body}');
        }
      } catch (e) {
        debugPrint('solution-development 엔드포인트 요청 오류: $e');
      }
      
      // 두 번째 시도: 메모리 저장소 API
      if (!isSuccess) {
        try {
          final uri = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.memorySystemUpdateEndpoint}')
              .replace(queryParameters: queryParams);
          debugPrint('시도 2 (메모리 API): $uri');
          
          final response = await _httpClient.safeGet(uri);
          debugPrint('memory 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            dataList = json.decode(response.body);
            debugPrint('memory 엔드포인트에서 ${dataList.length}개 데이터 로드 성공');
            isSuccess = true;
            endpoint = 'memory';
          } else {
            debugPrint('memory 엔드포인트 요청 실패: ${response.statusCode}');
            debugPrint('응답 본문: ${response.body}');
          }
        } catch (e) {
          debugPrint('memory 엔드포인트 요청 오류: $e');
        }
      }
      
      // 세 번째 시도: 일반 시스템 업데이트 API
      if (!isSuccess) {
        try {
          final uri = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.systemUpdateEndpoint}')
              .replace(queryParameters: queryParams);
          debugPrint('시도 3 (일반 API): $uri');
          
          final response = await _httpClient.safeGet(uri);
          debugPrint('system-updates 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            dataList = json.decode(response.body);
            debugPrint('system-updates 엔드포인트에서 ${dataList.length}개 데이터 로드 성공');
            isSuccess = true;
            endpoint = 'system-updates';
          } else {
            debugPrint('system-updates 엔드포인트 요청 실패: ${response.statusCode}');
            debugPrint('응답 본문: ${response.body}');
          }
        } catch (e) {
          debugPrint('system-updates 엔드포인트 요청 오류: $e');
        }
      }
      
      // 모든 API 요청 실패 시 빈 목록 반환
      if (!isSuccess) {
        debugPrint('모든 API 요청 실패, 빈 목록 반환');
        return [];
      }
      
      // 성공한 응답 데이터 변환 및 반환
      debugPrint('성공한 엔드포인트: $endpoint, 데이터 변환 중...');
      return dataList.map((json) => SystemUpdateModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('시스템 업데이트 데이터 로드 오류: $e');
      return [];
    }
  }

  /// 시스템 업데이트 추가
  /// 
  /// [updateModel] 추가할 시스템 업데이트 모델
  Future<SystemUpdateModel?> addSystemUpdate(SystemUpdateModel updateModel) async {
    try {
      // API 호출을 위한 데이터 준비
      final Map<String, dynamic> updateData = updateModel.toJson();
      
      // 중요 필드가 누락됐는지 확인
      if (updateData['description'] == null || updateData['description'].isEmpty) {
        throw Exception('설명은 필수 항목입니다.');
      }
      
      if (updateData['targetSystem'] == null || updateData['targetSystem'].isEmpty) {
        throw Exception('대상 시스템은 필수 항목입니다.');
      }
      
      debugPrint('시스템 업데이트 추가 요청: ${updateData['updateCode'] ?? '신규'}');
      
      // 복수 API 엔드포인트 시도
      List<String> endpoints = [
        ApiConstants.solutionDevelopmentEndpoint,
        ApiConstants.memorySystemUpdateEndpoint,
        ApiConstants.systemUpdateEndpoint
      ];
      
      for (final endpoint in endpoints) {
        try {
          final uri = Uri.parse('${ApiConstants.baseUrl}/$endpoint');
          final response = await _httpClient.safePost(uri, updateData);
          
          if (response.statusCode == 201 || response.statusCode == 200) {
            debugPrint('$endpoint 통해 시스템 업데이트 추가 성공');
            final responseData = json.decode(response.body);
            return SystemUpdateModel.fromJson(responseData);
          } else {
            debugPrint('$endpoint 시스템 업데이트 추가 실패: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('$endpoint 시스템 업데이트 추가 오류: $e');
        }
      }
      
      throw Exception('모든 API 엔드포인트 요청 실패');
    } catch (e) {
      debugPrint('시스템 업데이트 추가 프로세스 오류: $e');
      return null;
    }
  }

  /// 시스템 업데이트 수정
  /// 
  /// [code] 업데이트 코드
  /// [updateModel] 수정된 시스템 업데이트 모델
  Future<SystemUpdateModel?> updateSystemUpdate(String code, SystemUpdateModel updateModel) async {
    try {
      // API 호출을 위한 데이터 준비
      final Map<String, dynamic> updateData = updateModel.toJson();
      
      // 코드 일관성 확인
      updateData['updateCode'] = code;
      
      debugPrint('시스템 업데이트 수정 요청: $code');
      
      // 복수 API 엔드포인트 시도
      List<String> endpoints = [
        ApiConstants.solutionDevelopmentEndpoint,
        ApiConstants.memorySystemUpdateEndpoint,
        ApiConstants.systemUpdateEndpoint
      ];
      
      for (final endpoint in endpoints) {
        try {
          final uri = Uri.parse('${ApiConstants.baseUrl}/$endpoint/code/$code');
          final response = await _httpClient.safePut(uri, updateData);
          
          if (response.statusCode == 200) {
            debugPrint('$endpoint 통해 시스템 업데이트 수정 성공');
            final responseData = json.decode(response.body);
            return SystemUpdateModel.fromJson(responseData);
          } else {
            debugPrint('$endpoint 시스템 업데이트 수정 실패: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('$endpoint 시스템 업데이트 수정 오류: $e');
        }
      }
      
      throw Exception('모든 API 엔드포인트 요청 실패');
    } catch (e) {
      debugPrint('시스템 업데이트 수정 프로세스 오류: $e');
      return null;
    }
  }

  /// 시스템 업데이트 삭제
  /// 
  /// [code] 삭제할 업데이트 코드
  Future<bool> deleteSystemUpdate(String code) async {
    try {
      debugPrint('시스템 업데이트 삭제 요청: $code');
      
      // 복수 API 엔드포인트 시도
      List<String> endpoints = [
        ApiConstants.solutionDevelopmentEndpoint,
        ApiConstants.memorySystemUpdateEndpoint,
        ApiConstants.systemUpdateEndpoint
      ];
      
      for (final endpoint in endpoints) {
        try {
          final uri = Uri.parse('${ApiConstants.baseUrl}/$endpoint/code/$code');
          final response = await _httpClient.safeDelete(uri);
          
          if (response.statusCode == 200) {
            debugPrint('$endpoint 통해 시스템 업데이트 삭제 성공');
            return true;
          } else {
            debugPrint('$endpoint 시스템 업데이트 삭제 실패: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('$endpoint 시스템 업데이트 삭제 오류: $e');
        }
      }
      
      throw Exception('모든 API 엔드포인트 요청 실패');
    } catch (e) {
      debugPrint('시스템 업데이트 삭제 프로세스 오류: $e');
      return false;
    }
  }
} 