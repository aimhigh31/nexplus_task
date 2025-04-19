// ===== 주의: 이 파일은 더 이상 사용되지 않습니다. =====
// 이 파일은 download/file_utilities.dart로 대체되었습니다.
// 호환성을 위해 원본 코드를 유지합니다.
// =========================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:http/http.dart' as http;

/// 파일 다운로드 처리를 위한 헬퍼 클래스
@Deprecated('services/download/file_utilities.dart로 대체되었습니다.')
class DownloadHelper {
  /// HTTP 응답에서 파일을 저장하는 메서드
  static Future<bool> processDownloadResponse(
    http.Response response, {
    String? suggestedFileName,
    String entityType = '',
    Function(String)? onLog,
  }) async {
    void log(String message) {
      debugPrint(message);
      onLog?.call(message);
    }

    try {
      if (response.statusCode != 200) {
        log('다운로드 실패: HTTP ${response.statusCode}');
        return false;
      }

      final contentTypeHeader = response.headers['content-type'] ?? 'application/octet-stream';
      final contentLength = response.contentLength ?? response.bodyBytes.length;
      
      // 파일명 결정
      String fileName = getFilenameFromHeaders(response.headers) ?? 
          suggestedFileName ?? 
          'downloaded_file_${DateTime.now().millisecondsSinceEpoch}';
      
      // 파일명 처리 - 인코딩 및 유효성 검사
      fileName = sanitizeFileName(fileName);
          
      // 확장자 처리
      if (!fileName.contains('.')) {
        final extension = getExtensionFromMimeType(contentTypeHeader);
        fileName = '$fileName.$extension';
      }
      
      log('다운로드: $fileName (${contentLength / 1024} KB)');
      
      // 웹 환경 처리
      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: response.bodyBytes,
          ext: fileName.split('.').last,
          mimeType: MimeType.other,
        );
        log('웹 환경에서 파일 저장 완료: $fileName');
        return true;
      } 
      // 네이티브 환경 처리
      else {
        try {
          final result = await FilePicker.platform.getDirectoryPath();
          if (result != null) {
            final path = '$result/$fileName';
            final file = File(path);
            
            try {
              await file.writeAsBytes(response.bodyBytes);
              log('파일 저장 완료: $path');
              return true;
            } catch (fileWriteError) {
              String errorMessage = '파일 쓰기 오류: $fileWriteError';
              
              // Windows 개발자 모드 관련 메시지 처리
              if (Platform.isWindows && 
                  fileWriteError.toString().toLowerCase().contains('access is denied')) {
                errorMessage = 'Windows 파일 쓰기 권한 오류: 개발자 모드가 활성화되어 있는지 확인하세요.\n$fileWriteError';
              }
              
              log(errorMessage);
              return false;
            }
          } else {
            log('파일 저장 위치 선택이 취소되었습니다.');
            return false;
          }
        } catch (pickerError) {
          String errorMessage = '파일 저장 위치 선택 중 오류: $pickerError';
          
          // FilePicker Windows 개발자 모드 관련 예외 처리
          if (Platform.isWindows && 
              pickerError.toString().toLowerCase().contains('developer mode')) {
            errorMessage = 'Windows 개발자 모드 필요: FilePicker가 제대로 작동하려면 Windows 개발자 모드를 활성화해야 합니다.\n$pickerError';
          }
          
          log(errorMessage);
          return false;
        }
      }
    } catch (e) {
      debugPrint('다운로드 처리 중 예외 발생: $e');
      return false;
    }
  }

  /// HTTP 헤더에서 파일명 추출
  static String? getFilenameFromHeaders(Map<String, String> headers) {
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
        // UTF-8 이스케이프 시퀀스 디코딩
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
  static String _decodeUtf8Escapes(String input) {
    final pattern = RegExp(r'\\u([0-9a-fA-F]{4})');
    return input.replaceAllMapped(pattern, (match) {
      final hexCode = match.group(1)!;
      final codePoint = int.parse(hexCode, radix: 16);
      return String.fromCharCode(codePoint);
    });
  }
  
  /// 파일명 정리 (유효하지 않은 문자 제거 및 길이 제한)
  static String sanitizeFileName(String fileName) {
    // Windows에서 금지된 파일명 문자: \ / : * ? " < > |
    final invalidChars = RegExp(r'[\\/:*?"<>|]');
    String sanitized = fileName.replaceAll(invalidChars, '_');
    
    // 파일명 길이 제한 (Windows 기준 최대 255자)
    const maxLength = 240; // 여유를 두고 설정
    if (sanitized.length > maxLength) {
      final extension = getExtensionFromFilename(sanitized);
      final nameWithoutExt = sanitized.substring(0, sanitized.lastIndexOf('.'));
      sanitized = nameWithoutExt.substring(0, maxLength - extension.length - 1) + '.' + extension;
    }
    
    return sanitized;
  }
  
  /// 파일명에서 확장자 추출
  static String getExtensionFromFilename(String filename) {
    final lastDotIndex = filename.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < filename.length - 1) {
      return filename.substring(lastDotIndex + 1).toLowerCase();
    }
    return 'bin'; // 기본 확장자
  }
  
  /// MIME 타입에서 확장자 추출
  static String getExtensionFromMimeType(String mimeType) {
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