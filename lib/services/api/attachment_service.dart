import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';

import '../../models/attachment_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import '../utils/logging_service.dart';
import '../download/download_service.dart';
import '../download/file_utilities.dart';

/// 첨부파일 관련 기능을 담당하는 서비스
class AttachmentService {
  final ApiClient _apiClient;
  final DownloadService _downloadService;
  final LoggingService _logger;
  final String baseUrl;
  
  /// 생성자
  AttachmentService({
    required this.baseUrl,
    required ApiClient apiClient,
    required DownloadService downloadService,
    required LoggingService logger,
  }) : 
    _apiClient = apiClient,
    _downloadService = downloadService,
    _logger = logger;
  
  /// 첨부파일 목록 조회 (엔티티 ID 기준)
  Future<List<AttachmentModel>> getAttachmentsByEntityId(String entityId, String entityType) async {
    try {
      _logger.info('첨부파일 목록 조회 시작', data: {'entityId': entityId, 'entityType': entityType});
      
      final uri = Uri.parse('$baseUrl/${ApiEndpoints.attachmentsList}')
          .replace(queryParameters: {
        'relatedEntityId': entityId,
        'relatedEntityType': entityType,
      });
      
      final response = await _apiClient.safeGet(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final attachments = jsonList
            .map((json) => AttachmentModel.fromJson(json))
            .toList();
        
        _logger.info('첨부파일 목록 조회 성공', data: {
          'count': attachments.length,
          'entityId': entityId,
        });
        
        return attachments;
      } else {
        _logger.error('첨부파일 목록 조회 실패', data: {
          'statusCode': response.statusCode,
          'response': response.body,
        });
        return [];
      }
    } catch (e) {
      _logger.error('첨부파일 목록 조회 중 예외 발생', exception: e, data: {
        'entityId': entityId,
        'entityType': entityType,
      });
      return [];
    }
  }
  
  /// 첨부파일 업로드
  Future<AttachmentModel?> uploadFile({
    required List<int> fileBytes,
    required String fileName,
    required String entityId,
    required String entityType,
  }) async {
    try {
      _logger.info('첨부파일 업로드 시작', data: {
        'fileName': fileName,
        'entityId': entityId,
        'entityType': entityType,
        'fileSize': fileBytes.length,
      });
      
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      
      // 멀티파트 요청 생성
      final uri = Uri.parse('$baseUrl/${ApiEndpoints.attachmentsUpload}');
      final request = http.MultipartRequest('POST', uri);
      
      // 파일 데이터 추가
      final fileField = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(fileField);
      
      // 관련 엔티티 정보 추가
      request.fields['relatedEntityId'] = entityId;
      request.fields['relatedEntityType'] = entityType;
      
      // 요청 전송
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.info('첨부파일 업로드 성공', data: {
          'fileName': fileName,
          'response': response.statusCode,
        });
        
        final data = json.decode(response.body);
        // _id 필드를 id로 매핑
        if (data['_id'] != null && data['id'] == null) {
          data['id'] = data['_id'];
        }
        
        final savedAttachment = AttachmentModel.fromJson(data);
        return savedAttachment;
      } else {
        _logger.error('첨부파일 업로드 실패', data: {
          'statusCode': response.statusCode,
          'response': response.body,
        });
        return null;
      }
    } catch (e) {
      String errorMessage = '첨부파일 업로드 중 오류 발생: $e';
      
      _logger.error(errorMessage, exception: e, data: {
        'fileName': fileName,
        'entityId': entityId,
      });
      return null;
    }
  }
  
  /// 파일 경로로부터 첨부파일 업로드
  Future<AttachmentModel?> uploadFileFromPath({
    required String filePath,
    required String fileName,
    required String entityId,
    required String entityType,
  }) async {
    if (kIsWeb) {
      _logger.error('웹 환경에서는 파일 경로 업로드 지원되지 않음', data: {'fileName': fileName});
      throw UnsupportedError('웹 환경에서는 파일 경로로 업로드가 지원되지 않습니다.');
    }
    
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      return uploadFile(
        fileBytes: bytes,
        fileName: fileName,
        entityId: entityId,
        entityType: entityType,
      );
    } catch (e) {
      _logger.error('파일 경로 업로드 중 오류', exception: e, data: {
        'filePath': filePath,
        'fileName': fileName,
      });
      return null;
    }
  }
  
  /// 첨부파일 다운로드
  Future<bool> downloadAttachment(String attachmentId, {String? suggestedFileName}) async {
    return _downloadService.downloadAttachment(
      attachmentId,
      suggestedFileName: suggestedFileName,
    );
  }
  
  /// 첨부파일 삭제
  Future<bool> deleteAttachment(String attachmentId) async {
    try {
      _logger.info('첨부파일 삭제 시작', data: {'attachmentId': attachmentId});
      
      final uri = Uri.parse('$baseUrl/${ApiEndpoints.attachmentsDelete}/$attachmentId');
      final response = await _apiClient.safeDelete(uri);
      
      if (response.statusCode == 200) {
        _logger.info('첨부파일 삭제 성공', data: {'attachmentId': attachmentId});
        return true;
      } else {
        _logger.error('첨부파일 삭제 실패', data: {
          'statusCode': response.statusCode,
          'response': response.body,
        });
        return false;
      }
    } catch (e) {
      _logger.error('첨부파일 삭제 중 예외 발생', exception: e, data: {
        'attachmentId': attachmentId,
      });
      return false;
    }
  }
  
  /// 첨부파일 상세 정보 조회
  Future<AttachmentModel?> getAttachmentDetails(String attachmentId) async {
    try {
      _logger.info('첨부파일 상세 정보 조회 시작', data: {'attachmentId': attachmentId});
      
      final uri = Uri.parse('$baseUrl/${ApiEndpoints.attachmentsList}/$attachmentId');
      final response = await _apiClient.safeGet(uri);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final attachment = AttachmentModel.fromJson(jsonData);
        
        _logger.info('첨부파일 상세 정보 조회 성공', data: {
          'attachmentId': attachmentId,
          'fileName': attachment.fileName,
        });
        
        return attachment;
      } else {
        _logger.error('첨부파일 상세 정보 조회 실패', data: {
          'statusCode': response.statusCode,
          'response': response.body,
        });
        return null;
      }
    } catch (e) {
      _logger.error('첨부파일 상세 정보 조회 중 예외 발생', exception: e, data: {
        'attachmentId': attachmentId,
      });
      return null;
    }
  }
} 