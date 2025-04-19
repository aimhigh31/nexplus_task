import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/equipment_connection_model.dart';
import 'api_client.dart';
import '../utils/logging_service.dart';

/// 설비연동 데이터 관리를 담당하는 서비스
class EquipmentConnectionService {
  final String baseUrl;
  final ApiClient _apiClient;
  final LoggingService _logger;
  
  /// MongoDB 컬렉션 이름
  static const String _collectionName = 'connection';
  
  /// MongoDB API 엔드포인트
  static const String _mongoEndpoint = '/api/mongodb';
  
  /// 생성자
  EquipmentConnectionService({
    required this.baseUrl,
    required ApiClient apiClient,
    required LoggingService logger,
  }) : 
    _apiClient = apiClient,
    _logger = logger;
  
  /// MongoDB 연결 테스트
  Future<Map<String, dynamic>> testMongoDBConnection() async {
    try {
      _logger.info('MongoDB 연결 테스트 시작');
      
      // 직접 MongoDB API 호출 테스트
      final mongoUri = Uri.parse('$baseUrl$_mongoEndpoint/$_collectionName/find');
      final fallbackUri = Uri.parse('$baseUrl/api/equipment-connections');
      
      _logger.info('MongoDB 연결 테스트: API 호출 시도', data: {
        'mongoUri': mongoUri.toString(),
        'fallbackUri': fallbackUri.toString(),
      });
      
      // MongoDB API 호출 시도
      final mongoResponse = await http.post(
        mongoUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'filter': {}}),
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        return http.Response('{"error": "timeout"}', 408);
      });
      
      // 백업 API 호출 시도
      final fallbackResponse = await http.get(fallbackUri).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return http.Response('{"error": "timeout"}', 408);
        },
      );
      
      _logger.info('MongoDB 연결 테스트 결과', data: {
        'mongoStatusCode': mongoResponse.statusCode,
        'fallbackStatusCode': fallbackResponse.statusCode,
      });
      
      return {
        'success': mongoResponse.statusCode == 200 || fallbackResponse.statusCode == 200,
        'mongoApiAvailable': mongoResponse.statusCode == 200,
        'fallbackApiAvailable': fallbackResponse.statusCode == 200,
        'mongoStatusCode': mongoResponse.statusCode,
        'fallbackStatusCode': fallbackResponse.statusCode,
        'mongo': mongoResponse.statusCode == 200 
            ? json.decode(mongoResponse.body) 
            : mongoResponse.body,
        'fallback': fallbackResponse.statusCode == 200 
            ? json.decode(fallbackResponse.body)
            : fallbackResponse.body,
      };
    } catch (e) {
      _logger.error('MongoDB 연결 테스트 예외 발생', exception: e);
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// 설비 연동 데이터 조회
  Future<List<EquipmentConnectionModel>> getEquipmentConnections({
    String? search,
    String? line,
    String? equipment,
    String? workType,
    String? dataType,
    String? connectionType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.info('설비 연동 데이터 조회 시작', data: {
        'filters': {
          'search': search,
          'line': line,
          'equipment': equipment,
          'workType': workType,
          'dataType': dataType,
          'connectionType': connectionType,
          'status': status,
        }
      });
      
      // 필터 조건 구성
      final Map<String, dynamic> filter = {};
      
      if (search != null && search.isNotEmpty) {
        // 여러 필드에 대한 검색 지원
        filter[r'$or'] = [
          {'line': {r'$regex': search, r'$options': 'i'}},
          {'equipment': {r'$regex': search, r'$options': 'i'}},
          {'detail': {r'$regex': search, r'$options': 'i'}},
          {'remarks': {r'$regex': search, r'$options': 'i'}},
        ];
      }
      
      if (line != null && line.isNotEmpty) {
        filter['line'] = line;
      }
      
      if (equipment != null && equipment.isNotEmpty) {
        filter['equipment'] = equipment;
      }
      
      if (workType != null && workType.isNotEmpty) {
        filter['workType'] = workType;
      }
      
      if (dataType != null && dataType.isNotEmpty) {
        filter['dataType'] = dataType;
      }
      
      if (connectionType != null && connectionType.isNotEmpty) {
        filter['connectionType'] = connectionType;
      }
      
      if (status != null && status.isNotEmpty) {
        filter['status'] = status;
      }
      
      if (startDate != null && endDate != null) {
        filter['regDate'] = {
          r'$gte': startDate.toIso8601String(),
          r'$lte': endDate.toIso8601String(),
        };
      } else if (startDate != null) {
        filter['regDate'] = {r'$gte': startDate.toIso8601String()};
      } else if (endDate != null) {
        filter['regDate'] = {r'$lte': endDate.toIso8601String()};
      }
      
      // MongoDB API 호출
      final uri = Uri.parse('$baseUrl$_mongoEndpoint/$_collectionName/find');
      _logger.info('MongoDB API 요청', data: {'uri': uri.toString(), 'filter': filter});
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'filter': filter}),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        _logger.info('설비 연동 데이터 조회 성공', data: {'count': jsonList.length});
        
        final connections = <EquipmentConnectionModel>[];
        
        for (var item in jsonList) {
          try {
            // MongoDB _id 처리
            if (item['_id'] != null && item['code'] == null) {
              item['code'] = item['_id'];
            }
            
            connections.add(EquipmentConnectionModel.fromJson(item));
          } catch (e) {
            _logger.error('설비 연동 데이터 변환 오류', exception: e, data: {'item': item});
          }
        }
        
        return connections;
      } else {
        _logger.error('설비 연동 데이터 조회 실패', data: {
          'statusCode': response.statusCode,
          'body': response.body,
        });
        
        // 실패 시 메모리 백업 데이터 시도
        return _getFallbackData();
      }
    } catch (e) {
      _logger.error('설비 연동 데이터 조회 예외 발생', exception: e);
      
      // 예외 발생 시 메모리 백업 데이터 시도
      return _getFallbackData();
    }
  }
  
  /// 메모리 백업 데이터 조회 (MongoDB 연결 실패 시)
  Future<List<EquipmentConnectionModel>> _getFallbackData() async {
    try {
      final uri = Uri.parse('$baseUrl/memory/equipment-connections');
      _logger.info('메모리 백업 데이터 조회 시도', data: {'uri': uri.toString()});
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        _logger.info('메모리 백업 데이터 조회 성공', data: {'count': jsonList.length});
        
        final connections = <EquipmentConnectionModel>[];
        
        for (var item in jsonList) {
          try {
            if (item['_id'] != null && item['code'] == null) {
              item['code'] = item['_id'];
            }
            connections.add(EquipmentConnectionModel.fromJson(item));
          } catch (e) {
            _logger.error('메모리 백업 데이터 변환 오류', exception: e);
          }
        }
        
        return connections;
      } else {
        _logger.error('메모리 백업 데이터 조회 실패', data: {
          'statusCode': response.statusCode,
          'body': response.body,
        });
        return [];
      }
    } catch (e) {
      _logger.error('메모리 백업 데이터 조회 예외 발생', exception: e);
      return [];
    }
  }
  
  /// 설비 연동 데이터 추가
  Future<EquipmentConnectionModel?> addEquipmentConnection(EquipmentConnectionModel connection) async {
    try {
      _logger.info('설비 연동 데이터 추가 시작', data: {
        'code': connection.code,
        'line': connection.line,
        'equipment': connection.equipment,
      });
      
      // MongoDB 저장용 데이터 준비
      final Map<String, dynamic> document = connection.toJson();
      
      // 날짜 필드 처리
      if (connection.regDate != null) {
        document['regDate'] = connection.regDate.toIso8601String();
      }
      if (connection.startDate != null) {
        document['startDate'] = connection.startDate!.toIso8601String();
      } else {
        document.remove('startDate');
      }
      if (connection.completionDate != null) {
        document['completionDate'] = connection.completionDate!.toIso8601String();
      } else {
        document.remove('completionDate');
      }
      
      // MongoDB API 호출
      final uri = Uri.parse('$baseUrl$_mongoEndpoint/$_collectionName/insertOne');
      _logger.info('MongoDB API 요청 (데이터 추가)', data: {'uri': uri.toString()});
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'document': document}),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _logger.info('설비 연동 데이터 추가 성공', data: {
          'inserted_id': responseData['_id'],
          'code': connection.code,
        });
        
        // 문서 ID를 코드로 설정
        if (responseData['_id'] != null && connection.code == null) {
          document['code'] = responseData['_id'];
        }
        
        // 결과 모델 생성
        return EquipmentConnectionModel.fromJson(document);
      } else {
        _logger.error('설비 연동 데이터 추가 실패', data: {
          'statusCode': response.statusCode,
          'body': response.body,
        });
        
        // 백업 메모리 저장소 시도
        return _addToFallbackStorage(connection);
      }
    } catch (e) {
      _logger.error('설비 연동 데이터 추가 예외 발생', exception: e);
      
      // 예외 발생 시 백업 저장소 시도
      return _addToFallbackStorage(connection);
    }
  }
  
  /// 백업 저장소에 추가 (MongoDB 연결 실패 시)
  Future<EquipmentConnectionModel?> _addToFallbackStorage(EquipmentConnectionModel connection) async {
    try {
      final uri = Uri.parse('$baseUrl/memory/equipment-connections');
      _logger.info('메모리 백업 저장소 데이터 추가 시도', data: {'uri': uri.toString()});
      
      final Map<String, dynamic> document = connection.toJson();
      
      // 날짜 필드 처리
      if (connection.regDate != null) {
        document['regDate'] = connection.regDate.toIso8601String();
      }
      if (connection.startDate != null) {
        document['startDate'] = connection.startDate!.toIso8601String();
      } else {
        document.remove('startDate');
      }
      if (connection.completionDate != null) {
        document['completionDate'] = connection.completionDate!.toIso8601String();
      } else {
        document.remove('completionDate');
      }
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(document),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _logger.info('메모리 백업 저장소 데이터 추가 성공', data: {'code': connection.code});
        
        return EquipmentConnectionModel.fromJson(responseData);
      } else {
        _logger.error('메모리 백업 저장소 데이터 추가 실패', data: {
          'statusCode': response.statusCode,
          'body': response.body,
        });
        return null;
      }
    } catch (e) {
      _logger.error('메모리 백업 저장소 데이터 추가 예외 발생', exception: e);
      return null;
    }
  }
  
  /// 설비 연동 데이터 수정
  Future<EquipmentConnectionModel?> updateEquipmentConnection(EquipmentConnectionModel connection) async {
    try {
      if (connection.code == null) {
        _logger.error('설비 연동 데이터 수정 실패: 코드 없음');
        return null;
      }
      
      _logger.info('설비 연동 데이터 수정 시작', data: {'code': connection.code});
      
      // MongoDB 업데이트용 데이터 준비
      final Map<String, dynamic> document = connection.toJson();
      
      // 날짜 필드 처리
      if (connection.regDate != null) {
        document['regDate'] = connection.regDate.toIso8601String();
      }
      if (connection.startDate != null) {
        document['startDate'] = connection.startDate!.toIso8601String();
      } else {
        document.remove('startDate');
      }
      if (connection.completionDate != null) {
        document['completionDate'] = connection.completionDate!.toIso8601String();
      } else {
        document.remove('completionDate');
      }
      
      // MongoDB API 호출
      final uri = Uri.parse('$baseUrl$_mongoEndpoint/$_collectionName/updateOne');
      _logger.info('MongoDB API 요청 (데이터 수정)', data: {'uri': uri.toString()});
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'filter': {'code': connection.code},
          'update': {r'$set': document},
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _logger.info('설비 연동 데이터 수정 성공', data: {
          'matched_count': responseData['matchedCount'],
          'modified_count': responseData['modifiedCount'],
          'code': connection.code,
        });
        
        // 결과 모델 생성 (수정된 문서 그대로 반환)
        return connection.copyWith(isModified: false);
      } else {
        _logger.error('설비 연동 데이터 수정 실패', data: {
          'statusCode': response.statusCode,
          'body': response.body,
        });
        
        // 백업 메모리 저장소 시도
        return _updateInFallbackStorage(connection);
      }
    } catch (e) {
      _logger.error('설비 연동 데이터 수정 예외 발생', exception: e);
      
      // 예외 발생 시 백업 저장소 시도
      return _updateInFallbackStorage(connection);
    }
  }
  
  /// 백업 저장소에서 수정 (MongoDB 연결 실패 시)
  Future<EquipmentConnectionModel?> _updateInFallbackStorage(EquipmentConnectionModel connection) async {
    try {
      final uri = Uri.parse('$baseUrl/memory/equipment-connections/${connection.code}');
      _logger.info('메모리 백업 저장소 데이터 수정 시도', data: {'uri': uri.toString()});
      
      final Map<String, dynamic> document = connection.toJson();
      
      // 날짜 필드 처리
      if (connection.regDate != null) {
        document['regDate'] = connection.regDate.toIso8601String();
      }
      if (connection.startDate != null) {
        document['startDate'] = connection.startDate!.toIso8601String();
      } else {
        document.remove('startDate');
      }
      if (connection.completionDate != null) {
        document['completionDate'] = connection.completionDate!.toIso8601String();
      } else {
        document.remove('completionDate');
      }
      
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(document),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _logger.info('메모리 백업 저장소 데이터 수정 성공', data: {'code': connection.code});
        
        return EquipmentConnectionModel.fromJson(responseData).copyWith(isModified: false);
      } else {
        _logger.error('메모리 백업 저장소 데이터 수정 실패', data: {
          'statusCode': response.statusCode,
          'body': response.body,
        });
        return null;
      }
    } catch (e) {
      _logger.error('메모리 백업 저장소 데이터 수정 예외 발생', exception: e);
      return null;
    }
  }
  
  /// 설비 연동 데이터 삭제
  Future<bool> deleteEquipmentConnection(String code) async {
    try {
      _logger.info('설비 연동 데이터 삭제 시작', data: {'code': code});
      
      // MongoDB API 호출
      final uri = Uri.parse('$baseUrl$_mongoEndpoint/$_collectionName/deleteOne');
      _logger.info('MongoDB API 요청 (데이터 삭제)', data: {'uri': uri.toString()});
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'filter': {'code': code}}),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final deletedCount = responseData['deletedCount'] ?? 0;
        
        _logger.info('설비 연동 데이터 삭제 결과', data: {
          'code': code,
          'deleted_count': deletedCount,
        });
        
        if (deletedCount > 0) {
          return true;
        } else {
          // MongoDB에서 삭제되지 않았으면 백업 저장소 시도
          return _deleteFromFallbackStorage(code);
        }
      } else {
        _logger.error('설비 연동 데이터 삭제 실패', data: {
          'statusCode': response.statusCode,
          'body': response.body,
        });
        
        // 백업 메모리 저장소 시도
        return _deleteFromFallbackStorage(code);
      }
    } catch (e) {
      _logger.error('설비 연동 데이터 삭제 예외 발생', exception: e);
      
      // 예외 발생 시 백업 저장소 시도
      return _deleteFromFallbackStorage(code);
    }
  }
  
  /// 백업 저장소에서 삭제 (MongoDB 연결 실패 시)
  Future<bool> _deleteFromFallbackStorage(String code) async {
    try {
      final uri = Uri.parse('$baseUrl/memory/equipment-connections/$code');
      _logger.info('메모리 백업 저장소 데이터 삭제 시도', data: {'uri': uri.toString()});
      
      final response = await http.delete(uri);
      
      if (response.statusCode == 200) {
        _logger.info('메모리 백업 저장소 데이터 삭제 성공', data: {'code': code});
        return true;
      } else {
        _logger.error('메모리 백업 저장소 데이터 삭제 실패', data: {
          'statusCode': response.statusCode,
          'body': response.body,
        });
        return false;
      }
    } catch (e) {
      _logger.error('메모리 백업 저장소 데이터 삭제 예외 발생', exception: e);
      return false;
    }
  }
} 