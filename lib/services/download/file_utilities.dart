import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

/// 파일 관련 유틸리티 클래스
/// 파일명 처리, MIME 타입 변환, 파일명 추출 등 파일 작업에 필요한 유틸리티 제공
class FileUtilities {
  /// MIME 타입 추출
  static String getMimeType(String fileName) {
    // 내장 MIME 타입 탐지 사용
    final mimeType = lookupMimeType(fileName);
    if (mimeType != null) return mimeType;
    
    // 내장 기능으로 감지 실패 시 확장자로 판단
    final extension = getExtensionFromFilename(fileName).toLowerCase();
    
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
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case '7z':
        return 'application/x-7z-compressed';
      default:
        return 'application/octet-stream';
    }
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
    if (mime.contains('openxmlformats') && mime.contains('word')) return 'docx';
    if (mime.contains('excel') || mime.contains('spreadsheet')) return 'xls';
    if (mime.contains('openxmlformats') && mime.contains('sheet')) return 'xlsx';
    if (mime.contains('powerpoint') || mime.contains('presentation')) return 'ppt';
    if (mime.contains('openxmlformats') && mime.contains('presentation')) return 'pptx';
    if (mime.contains('text/plain')) return 'txt';
    if (mime.contains('text/csv')) return 'csv';
    if (mime.contains('zip')) return 'zip';
    if (mime.contains('rar')) return 'rar';
    if (mime.contains('7z')) return '7z';
    
    return 'bin'; // 기본 확장자
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
  
  /// HTTP 헤더에서 Content-Disposition을 파싱하여 파일명 추출
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
  
  /// 파일 크기를 읽기 쉬운 형식으로 변환 (예: 1.2 MB)
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
  
  /// 임시 디렉토리 경로 가져오기
  static Future<String> getTempDirectoryPath() async {
    if (kIsWeb) {
      return '';
    } else {
      final Directory tempDir = await Directory.systemTemp.createTemp('app_tmp_');
      return tempDir.path;
    }
  }

  /// HTTP 응답에서 파일명 추출
  /// 여러 메서드로 파일명을 추출하며 우선순위는:
  /// 1. Content-Disposition 헤더
  /// 2. URL 경로의 마지막 부분
  /// 
  /// [response] HTTP 응답 객체
  /// 성공시 파일명 반환, 실패시 null 반환
  static String? extractFilenameFromResponse(http.Response response) {
    // Content-Disposition 헤더에서 파일명 추출 시도
    final contentDisposition = response.headers['content-disposition'];
    if (contentDisposition != null) {
      // 일반 filename="파일명.확장자" 형식 처리
      final regExpFilename = RegExp(r'filename="([^"]*)"');
      final match = regExpFilename.firstMatch(contentDisposition);
      if (match != null && match.groupCount >= 1) {
        String fileName = match.group(1)!;
        
        // URL 인코딩된 파일명 디코딩
        try {
          if (fileName.contains('%')) {
            fileName = Uri.decodeComponent(fileName);
          }
        } catch (e) {
          debugPrint('파일명 디코딩 오류: $e');
        }
        
        return fileName;
      }
      
      // RFC 5987 표준: filename*=UTF-8''인코딩된_파일명 형식 처리
      final regExpFilenameExt = RegExp(r"filename\*=UTF-8''([^;]*)");
      final matchExt = regExpFilenameExt.firstMatch(contentDisposition);
      if (matchExt != null && matchExt.groupCount >= 1) {
        try {
          return Uri.decodeComponent(matchExt.group(1)!);
        } catch (e) {
          debugPrint('UTF-8 파일명 디코딩 오류: $e');
        }
      }
    }

    // URL에서 파일명 추출 시도
    try {
      final uri = Uri.parse(response.request?.url.toString() ?? '');
      final fileName = path.basename(uri.path);
      if (fileName.isNotEmpty && fileName != '/' && !fileName.startsWith('.')) {
        return fileName;
      }
    } catch (e) {
      debugPrint('URL에서 파일명 추출 오류: $e');
    }

    return null;
  }
}

// 파일 유틸리티 관련 상수 및 확장 메서드
extension FileUtilityExtensions on String {
  /// 문자열을 파일명으로 변환 (유효하지 않은 문자 제거)
  String toSafeFileName() {
    return FileUtilities.sanitizeFileName(this);
  }
  
  /// 파일 경로에서 파일명만 추출
  String get fileName {
    return path.basename(this);
  }
  
  /// 파일 경로에서 확장자 추출
  String get fileExtension {
    return path.extension(this);
  }
  
  /// 확장자가 없는 파일명 추출
  String get fileNameWithoutExtension {
    return path.basenameWithoutExtension(this);
  }
} 