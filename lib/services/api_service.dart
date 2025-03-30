import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/voc_model.dart';
import 'package:intl/intl.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final String _baseUrl = 'http://localhost:3000/api';
  
  // 싱글톤 패턴 구현
  factory ApiService() => _instance;
  
  ApiService._internal();
  
  // API 연결 테스트
  Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/voc')).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('Timeout', 408),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API 연결 테스트 실패: $e');
      return false;
    }
  }
  
  // VOC 데이터 조회 (검색 및 필터링 지원)
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
      // 쿼리 파라미터 구성
      final Map<String, String> queryParams = {};
      
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
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      
      if (dueDateStart != null) {
        queryParams['dueDateStart'] = dueDateStart.toIso8601String();
      }
      
      if (dueDateEnd != null) {
        queryParams['dueDateEnd'] = dueDateEnd.toIso8601String();
      }
      
      // URL 구성
      final uri = Uri.parse('$_baseUrl/voc').replace(queryParameters: queryParams);
      debugPrint('VOC 데이터 요청 URL: $uri');
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);
        debugPrint('VOC 데이터 ${dataList.length}개 성공적으로 로드 (첫 5개 번호: ${dataList.take(5).map((d) => d['no']).join(', ')})');
        
        return dataList.map((data) {
          final voc = VocModel.fromJson(data);
          // API에서 불러온 데이터는 저장된 것으로 처리하고 수정되지 않은 것으로 처리
          return voc.copyWith(isSaved: true, isModified: false);
        }).toList();
      } else {
        debugPrint('VOC 데이터 로드 실패: ${response.statusCode}, ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('VOC 데이터 로드 중 예외 발생: $e');
      return [];
    }
  }
  
  // 단일 VOC 조회
  Future<VocModel?> getVocById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/voc/$id'));
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return VocModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('VOC 상세 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('VOC 상세 조회 실패: $e');
      return null;
    }
  }
  
  // VOC 추가
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
      
      final response = await http.post(
        Uri.parse('$_baseUrl/voc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vocData),
      );
      
      debugPrint('VOC 추가 응답 상태: ${response.statusCode}');
      if (response.statusCode != 201 && response.statusCode != 200) {
        debugPrint('VOC 추가 응답 본문: ${response.body}');
      }
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return VocModel.fromJson(data);
      } else {
        throw Exception('VOC 추가 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('VOC 추가 실패: $e');
      return null;
    }
  }
  
  // VOC 업데이트
  Future<VocModel?> updateVoc(VocModel voc) async {
    try {
      // 코드가 없는 경우 업데이트 불가
      if (voc.code == null) {
        debugPrint('VOC 업데이트 실패: 코드가 없음');
        return null;
      }

      // 데이터를 직접 구성하여 API 형식에 맞춤
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      
      final Map<String, dynamic> vocData = {
        'no': voc.no,
        'regDate': formatter.format(voc.regDate),
        'code': voc.code,
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
      
      if (voc.id != null) {
        vocData['_id'] = voc.id;
      }
      
      final nonNullCode = voc.code!; // ! 연산자로 null이 아님을 확인 (이미 위에서 확인했음)
      
      // 간소화된 기본 데이터 설정 (디버깅용)
      final Map<String, dynamic> simpleData = {
        'no': voc.no,
        'code': nonNullCode
      };
      
      debugPrint('VOC 업데이트 요청 데이터 (간소화): ${jsonEncode(simpleData)}');
      
      // code를 URL 파라미터로 사용
      final response = await http.put(
        Uri.parse('$_baseUrl/voc/code/${Uri.encodeComponent(nonNullCode)}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vocData),
      );
      
      debugPrint('VOC 업데이트 응답 상태: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('VOC 업데이트 응답 본문: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return VocModel.fromJson(data);
      } else if (response.statusCode == 404) {
        debugPrint('VOC 업데이트 실패: 코드 $nonNullCode를 찾을 수 없음');
        return null;
      } else {
        throw Exception('VOC 업데이트 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('VOC 업데이트 실패: $e');
      return null;
    }
  }
  
  // VOC 삭제 (코드 기준)
  Future<bool> deleteVocByCode(String code) async {
    try {
      final safeCode = Uri.encodeComponent(code);
      debugPrint('VOC 삭제 요청 - 코드: $code (인코딩됨: $safeCode)');
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/voc/code/$safeCode')
      );
      
      debugPrint('VOC 삭제 응답 상태: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('VOC 삭제 실패: $e');
      return false;
    }
  }
  
  // VOC 삭제 (번호 기준 - 이전 버전과의 호환성 유지)
  Future<bool> deleteVoc(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/voc/$id'));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('VOC 삭제 실패: $e');
      return false;
    }
  }
} 