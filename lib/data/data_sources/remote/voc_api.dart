import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../models/voc_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_client.dart';

/// VOC API 호출을 담당하는 클래스
class VocApi {
  final HttpClient _httpClient;
  
  /// VOC API 생성자
  VocApi(this._httpClient);
  
  /// VOC 목록 조회
  /// 
  /// [search] 검색어
  /// [detailSearch] 상세 검색어
  /// [vocCategory] VOC 분류
  /// [requestType] 요청 유형
  /// [status] 상태
  /// [startDate] 시작일
  /// [endDate] 종료일
  /// [dueDateStart] 처리 예정일 시작
  /// [dueDateEnd] 처리 예정일 종료
  Future<List<VocModel>> getVocData({
    String? search,
    String? detailSearch,
    String? vocCategory,
    String? requestType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueDateStart,
    DateTime? dueDateEnd,
  }) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    
    // 쿼리 파라미터 구성
    final Map<String, String> queryParams = {};
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    if (detailSearch != null && detailSearch.isNotEmpty) {
      queryParams['detailSearch'] = detailSearch;
    }
    
    if (vocCategory != null && vocCategory.isNotEmpty) {
      queryParams['vocCategory'] = vocCategory;
    }
    
    if (requestType != null && requestType.isNotEmpty) {
      queryParams['requestType'] = requestType;
    }
    
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    
    if (startDate != null) {
      queryParams['startDate'] = formatter.format(startDate);
    }
    
    if (endDate != null) {
      queryParams['endDate'] = formatter.format(endDate);
    }
    
    if (dueDateStart != null) {
      queryParams['dueDateStart'] = formatter.format(dueDateStart);
    }
    
    if (dueDateEnd != null) {
      queryParams['dueDateEnd'] = formatter.format(dueDateEnd);
    }
    
    // API 호출 및 결과 처리
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.vocEndpoint}')
          .replace(queryParameters: queryParams);
      
      final response = await _httpClient.safeGet(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<VocModel> vocList = jsonList.map((json) => VocModel.fromJson(json)).toList();
        return vocList;
      } else {
        debugPrint('VOC 데이터 로드 실패: ${response.statusCode} - ${response.body}');
        
        // 메모리 백업 API 시도
        final memoryUri = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.memoryVocEndpoint}')
            .replace(queryParameters: queryParams);
        
        final memoryResponse = await _httpClient.safeGet(memoryUri);
        
        if (memoryResponse.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(memoryResponse.body);
          final List<VocModel> vocList = jsonList.map((json) => VocModel.fromJson(json)).toList();
          return vocList;
        }
        
        // 모든 API 요청 실패 시 빈 목록 반환
        return [];
      }
    } catch (e) {
      debugPrint('VOC 데이터 로드 오류: $e');
      return [];
    }
  }

  /// VOC 추가
  /// 
  /// [voc] 추가할 VOC 모델
  Future<VocModel?> addVoc(VocModel voc) async {
    try {
      // 데이터를 직접 구성하여 API 형식에 맞춤
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      
      final Map<String, dynamic> vocData = {
        'no': voc.no,
        'regDate': formatter.format(voc.regDate),
        'vocCategory': voc.vocCategory,
        'requestDept': voc.requestDept,
        'requester': voc.requester,
        'systemPath': voc.systemPath,
        'request': voc.request,
        'requestType': voc.requestType,
        'action': voc.action,
        'actionTeam': voc.actionTeam,
        'actionPerson': voc.actionPerson,
        'status': voc.status,
        'dueDate': formatter.format(voc.dueDate),
      };
      
      // 코드가 있는 경우에만 추가
      if (voc.code != null && voc.code!.isNotEmpty) {
        vocData['code'] = voc.code;
      }
      
      // 간소화된 기본 데이터 설정
      final Map<String, dynamic> simpleData = {
        'no': voc.no,
        'code': voc.code
      };
      
      debugPrint('VOC 추가 요청 데이터 (간소화): ${jsonEncode(simpleData)}');
      
      // API 호출
      final uri = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.vocEndpoint}');
      final response = await _httpClient.safePost(uri, vocData);
      
      debugPrint('VOC 추가 응답 상태: ${response.statusCode}');
      if (response.statusCode != 201 && response.statusCode != 200) {
        debugPrint('VOC 추가 응답 본문: ${response.body}');
      }
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return VocModel.fromJson(data);
      } else {
        // 메모리 백업 API 시도
        final memoryUri = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.memoryVocEndpoint}');
        final memoryResponse = await _httpClient.safePost(memoryUri, vocData);
        
        if (memoryResponse.statusCode == 201 || memoryResponse.statusCode == 200) {
          final dynamic data = json.decode(memoryResponse.body);
          return VocModel.fromJson(data);
        }
        
        throw Exception('VOC 추가 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('VOC 추가 오류: $e');
      return null;
    }
  }

  /// VOC 수정
  /// 
  /// [code] 수정할 VOC 코드
  /// [voc] 수정된 VOC 모델
  Future<VocModel?> updateVoc(String code, VocModel voc) async {
    try {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      
      final Map<String, dynamic> vocData = {
        'no': voc.no,
        'code': code,
        'regDate': formatter.format(voc.regDate),
        'vocCategory': voc.vocCategory,
        'requestDept': voc.requestDept,
        'requester': voc.requester,
        'systemPath': voc.systemPath,
        'request': voc.request,
        'requestType': voc.requestType,
        'action': voc.action,
        'actionTeam': voc.actionTeam,
        'actionPerson': voc.actionPerson,
        'status': voc.status,
        'dueDate': formatter.format(voc.dueDate),
      };
      
      // API 호출
      final uri = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.vocEndpoint}/code/$code');
      final response = await _httpClient.safePut(uri, vocData);
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return VocModel.fromJson(data);
      } else {
        // 메모리 백업 API 시도
        final memoryUri = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.memoryVocEndpoint}/code/$code');
        final memoryResponse = await _httpClient.safePut(memoryUri, vocData);
        
        if (memoryResponse.statusCode == 200) {
          final dynamic data = json.decode(memoryResponse.body);
          return VocModel.fromJson(data);
        }
        
        throw Exception('VOC 수정 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('VOC 수정 오류: $e');
      return null;
    }
  }

  /// VOC 삭제
  /// 
  /// [code] 삭제할 VOC 코드
  Future<bool> deleteVoc(String code) async {
    try {
      // API 호출
      final uri = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.vocEndpoint}/code/$code');
      final response = await _httpClient.safeDelete(uri);
      
      if (response.statusCode == 200) {
        return true;
      } else {
        // 메모리 백업 API 시도
        final memoryUri = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.memoryVocEndpoint}/code/$code');
        final memoryResponse = await _httpClient.safeDelete(memoryUri);
        
        if (memoryResponse.statusCode == 200) {
          return true;
        }
        
        throw Exception('VOC 삭제 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('VOC 삭제 오류: $e');
      return false;
    }
  }
} 