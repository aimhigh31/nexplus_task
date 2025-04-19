// 표준 Dart 라이브러리 임포트
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:http/http.dart' as http;

/// 향상된 파일 다운로드 서비스
/// Windows 개발자 모드 문제와 한글 파일명 처리를 개선
class ImprovedDownloadService {
  final String baseUrl;
  
  // 서비스 생성자
  ImprovedDownloadService({required this.baseUrl});
  
  /// 첨부파일 다운로드
  Future<bool> downloadAttachment(String attachmentId, {String? suggestedFileName}) async {
    try {
      debugPrint('=== 첨부파일 다운로드 시작 (개선된 버전) ===');
      debugPrint('첨부파일ID: $attachmentId');
      
      final uri = Uri.parse('$baseUrl/api/attachments/download/$attachmentId');
      
      try {
        // GET 요청으로 파일 다운로드
        final response = await http.get(
          uri,
          headers: {'Accept': '*/*'}, // 모든 응답 유형 허용
        ).timeout(
          const Duration(seconds: 120), // 대용량 파일 고려 타임아웃 증가
          onTimeout: () => http.Response('Timeout', 408),
        );

        debugPrint('응답 상태: ${response.statusCode}');
        
        // 개선된 다운로드 응답 처리
        final success = await _processDownloadResponse(
          response, 
          suggestedFileName: suggestedFileName,
          entityType: 'attachment'
        );
        
        return success;
      } catch (httpError) {
        debugPrint('첨부파일 다운로드 HTTP 요청 실패: $httpError');
        
        // 대체 엔드포인트 시도 (api/attachment/download)
        try {
          debugPrint('대체 엔드포인트로 다시 시도');
          final uri2 = Uri.parse('$baseUrl/api/attachment/download?id=$attachmentId');
          
          final response = await http.get(
            uri2,
            headers: {'Accept': '*/*'},
          ).timeout(
            const Duration(seconds: 120),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          debugPrint('대체 엔드포인트 응답 상태: ${response.statusCode}');
          
          final success = await _processDownloadResponse(
            response, 
            suggestedFileName: suggestedFileName,
            entityType: 'attachment'
          );
          
          return success;
        } catch (altError) {
          debugPrint('대체 엔드포인트 요청도 실패: $altError');
          _logError('첨부파일 다운로드', '모든 다운로드 시도 실패: $httpError, $altError');
          return false;
        }
      }
    } catch (e) {
      _logError('첨부파일 다운로드', '$e');
      return false;
    }
  }

  /// 다운로드 응답 처리 (바이너리 데이터를 파일로 저장)
  Future<bool> _processDownloadResponse(http.Response response, {String? suggestedFileName, String entityType = ''}) async {
    try {
      if (response.statusCode != 200) {
        debugPrint('다운로드 실패: HTTP ${response.statusCode}');
        return false;
      }

      final contentTypeHeader = response.headers['content-type'] ?? 'application/octet-stream';
      final contentLength = response.contentLength ?? response.bodyBytes.length;
      
      // 헤더에서 파일명 추출 (한글 파일명 처리 개선)
      String fileName = '';
      
      // 1. 헤더에서 파일명 추출 시도
      final headerFileName = _getFilenameFromHeaders(response.headers);
      
      // 2. 헤더에서 추출한 파일명 처리 (인코딩 문제 해결)
      if (headerFileName != null && headerFileName.isNotEmpty) {
        fileName = headerFileName;
        // 비ASCII 문자 (한글 등) 확인 및 처리
        final hasNonAscii = fileName.codeUnits.any((code) => code > 127);
        if (hasNonAscii) {
          debugPrint('비ASCII 문자가 포함된 파일명: $fileName');
          // 필요시 추가 디코딩 처리
          try {
            fileName = Uri.decodeComponent(fileName);
          } catch (e) {
            debugPrint('파일명 디코딩 중 오류: $e');
          }
        }
      } else {
        // 3. 헤더에서 추출 실패 시 대체 파일명 사용
        fileName = suggestedFileName ?? 'downloaded_file_${DateTime.now().millisecondsSinceEpoch}';
        debugPrint('헤더에서 파일명을 찾을 수 없어 대체 파일명 사용: $fileName');
      }
      
      // 4. 유효하지 않은 파일명 문자 제거 (Windows 파일 시스템 호환성)
      final invalidChars = RegExp(r'[\\/:*?"<>|]');
      fileName = fileName.replaceAll(invalidChars, '_');
          
      // 5. 확장자가 없는 경우 콘텐츠 타입을 기반으로 적절한 확장자 추가
      if (!fileName.contains('.')) {
        final extension = _getExtensionFromMimeType(contentTypeHeader);
        fileName = '$fileName.$extension';
      }
      
      // MIME 타입 확인
      final mimeType = _getMimeType(fileName);
      
      debugPrint('다운로드: $fileName ($mimeType, ${contentLength / 1024} KB)');
      
      // 웹 환경에서는 FileSaver 사용
      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: response.bodyBytes,
          ext: fileName.split('.').last,
          mimeType: MimeType.other,
        );
        debugPrint('웹 환경에서 파일 저장 완료: $fileName');
        return true;
      } else {
        // 네이티브 환경에서는 파일로 저장
        try {
          final result = await FilePicker.platform.getDirectoryPath();
          if (result != null) {
            final path = '$result/$fileName';
            final file = File(path);
            
            try {
              await file.writeAsBytes(response.bodyBytes);
              debugPrint('네이티브 환경에서 파일 저장 완료: $path');
              return true;
            } catch (fileWriteError) {
              // 파일 쓰기 오류 처리 (Windows 개발자 모드 문제 등)
              String errorMessage = '파일 쓰기 오류: $fileWriteError';
              if (Platform.isWindows && fileWriteError.toString().contains('Access is denied')) {
                errorMessage = 'Windows에서 파일 쓰기 권한 오류: 개발자 모드가 활성화되어 있는지 확인하세요. $fileWriteError';
              }
              debugPrint(errorMessage);
              return false;
            }
          } else {
            debugPrint('파일 저장 위치 선택 취소됨');
            return false;
          }
        } catch (pickerError) {
          String errorMessage = '파일 저장 위치 선택 중 오류: $pickerError';
          if (Platform.isWindows && pickerError.toString().contains('Developer Mode')) {
            errorMessage = 'Windows 개발자 모드가 필요합니다: FilePicker가 제대로 작동하려면 Windows 개발자 모드를 활성화해야 합니다.';
          }
          debugPrint(errorMessage);
          return false;
        }
      }
    } catch (e) {
      String errorDetails = '다운로드 처리 중 예외 발생: $e';
      debugPrint(errorDetails);
      return false;
    }
  }

  /// 로깅 메서드
  void _logError(String operation, String error) {
    debugPrint('오류 - $operation: $error');
  }

  /// HTTP 응답에서 Content-Disposition 헤더를 파싱하여 파일명 추출
  String? _getFilenameFromHeaders(Map<String, String> headers) {
    final contentDisposition = headers['content-disposition'] ?? headers['Content-Disposition'];
    if (contentDisposition == null) return null;
    
    final regExp = RegExp(r'filename[^;=\n]*=([\"]?)([^\";]*)\1');
    final matches = regExp.firstMatch(contentDisposition);
    
    if (matches != null && matches.groupCount >= 2) {
      String filename = matches.group(2) ?? '';
      
      // URL 인코딩된 한글 파일명 디코딩
      try {
        if (filename.contains('%')) {
          filename = Uri.decodeComponent(filename);
          // 이중 인코딩된 경우 한 번 더 디코딩
          if (filename.contains('%')) {
            filename = Uri.decodeComponent(filename);
          }
        }
        // 파일명에 UTF-8 이스케이프 시퀀스가 포함된 경우 처리
        if (filename.contains(r'\u')) {
          filename = _decodeUtf8Escapes(filename);
        }
      } catch (e) {
        debugPrint('파일명 디코딩 오류: $e, 원본: $filename');
      }
      
      return filename;
    }
    
    return null;
  }
  
  /// UTF-8 이스케이프 시퀀스 디코딩 (\uXXXX 형식)
  String _decodeUtf8Escapes(String input) {
    final pattern = RegExp(r'\\u([0-9a-fA-F]{4})');
    return input.replaceAllMapped(pattern, (match) {
      final hexCode = match.group(1)!;
      final codePoint = int.parse(hexCode, radix: 16);
      return String.fromCharCode(codePoint);
    });
  }
  
  /// MIME 타입 추출 헬퍼 메서드
  String _getMimeType(String fileName) {
    final extension = _getExtensionFromFilename(fileName);
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }
  
  /// 파일명에서 확장자 추출
  String _getExtensionFromFilename(String filename) {
    final lastDotIndex = filename.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < filename.length - 1) {
      return filename.substring(lastDotIndex + 1).toLowerCase();
    }
    return 'bin'; // 기본 확장자
  }
  
  /// MIME 타입에서 확장자 추출
  String _getExtensionFromMimeType(String mimeType) {
    final mime = mimeType.toLowerCase();
    
    if (mime.contains('jpeg') || mime.contains('jpg')) return 'jpg';
    if (mime.contains('png')) return 'png';
    if (mime.contains('gif')) return 'gif';
    if (mime.contains('pdf')) return 'pdf';
    if (mime.contains('msword') || mime.contains('doc')) return 'doc';
    if (mime.contains('excel') || mime.contains('xls')) return 'xls';
    if (mime.contains('powerpoint') || mime.contains('ppt')) return 'ppt';
    if (mime.contains('text/plain')) return 'txt';
    if (mime.contains('zip')) return 'zip';
    
    return 'bin'; // 기본 확장자
  }
} 