// ===== 주의: 이 파일은 더 이상 사용되지 않습니다. =====
// 이 파일은 download/download_service.dart로 대체되었습니다.
// 호환성을 위해 원본 코드를 유지합니다.
// =========================================================

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';

/// 다운로드 서비스 - 파일 다운로드 및 저장 기능 제공
@Deprecated('services/download/download_service.dart로 대체되었습니다.')
class ImprovedDownloadService {
  /// 파일 다운로드 함수
  /// [url]: 다운로드 URL
  /// [headers]: HTTP 헤더
  /// [suggestedFileName]: 제안된 파일명 (없으면 응답 헤더에서 추출)
  /// [onProgress]: 진행 상황 콜백
  /// [onSuccess]: 성공 콜백
  /// [onError]: 에러 콜백
  Future<void> downloadFile({
    required String url,
    Map<String, String>? headers,
    String? suggestedFileName,
    Function(double)? onProgress,
    Function(String)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // 저장 경로 선택
      String? savePath = await FilePicker.platform.getDirectoryPath();
      if (savePath == null) {
        onError?.call('사용자가 저장 경로 선택을 취소했습니다.');
        return;
      }

      // 응답 받기
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode != 200) {
        onError?.call('다운로드 실패: HTTP 오류 ${response.statusCode}');
        return;
      }

      // 파일명 결정
      String fileName = suggestedFileName ??
          _getFileNameFromResponse(response) ??
          'downloaded_file_${DateTime.now().millisecondsSinceEpoch}';
      
      // 파일명 중 유효하지 않은 문자 제거
      fileName = _sanitizeFileName(fileName);
      
      // 파일 확장자 확인 및 추가
      if (!fileName.contains('.')) {
        String? extension = _getExtensionFromMimeType(
            response.headers['content-type'] ?? '');
        if (extension != null) {
          fileName = '$fileName$extension';
        }
      }
      
      // 윈도우 경로의 경우 백슬래시로 변환
      String fullPath = path.join(savePath, fileName);
      if (Platform.isWindows) {
        fullPath = fullPath.replaceAll('/', '\\');
      }

      // 파일 쓰기
      final file = File(fullPath);
      await file.writeAsBytes(response.bodyBytes);

      onSuccess?.call(fullPath);
    } catch (e) {
      String errorMessage = '다운로드 중 오류 발생: $e';
      
      // Windows 특정 오류 감지
      if (Platform.isWindows && 
          e.toString().contains('error 1314') || 
          e.toString().contains('symbolic link privilege')) {
        errorMessage = '다운로드 실패: Windows에서 개발자 모드를 활성화해야 합니다. '
            '설정 > 개발자용 > 개발자 모드를 켜주세요.';
      }
      
      // 파일 시스템 권한 오류
      if (e is FileSystemException) {
        if (e.message.contains('Permission denied')) {
          errorMessage = '파일 저장 권한이 없습니다. 다른 폴더를 선택해보세요.';
        }
      }
      
      onError?.call(errorMessage);
    }
  }

  /// HTTP 응답에서 파일명 추출
  String? _getFileNameFromResponse(http.Response response) {
    // Content-Disposition 헤더에서 파일명 추출 시도
    final contentDisposition = response.headers['content-disposition'];
    if (contentDisposition != null) {
      // filename="파일명.확장자" 형식 처리
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
      
      // filename*=UTF-8''인코딩된_파일명 형식 처리 (RFC 5987)
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

  /// 파일명에서 유효하지 않은 문자 제거
  String _sanitizeFileName(String fileName) {
    // Windows에서 금지된 문자: < > : " / \ | ? *
    // 모든 OS에서 안전한 파일명을 위한 처리
    String sanitized = fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'[\x00-\x1F]'), ''); // 제어 문자 제거

    // 파일명 길이 제한 (255바이트로 가정)
    // UTF-8에서 한글은 3바이트이므로 전체 길이를 제한
    int maxBytes = 250; // 여유있게 설정
    List<int> bytes = utf8.encode(sanitized);
    if (bytes.length > maxBytes) {
      // 초과하는 경우 안전하게 잘라내기
      String truncated = '';
      int totalBytes = 0;
      for (int i = 0; i < sanitized.length; i++) {
        String char = sanitized[i];
        List<int> charBytes = utf8.encode(char);
        if (totalBytes + charBytes.length > maxBytes) break;
        truncated += char;
        totalBytes += charBytes.length;
      }
      sanitized = truncated;
    }

    // 파일명이 비어있으면 기본값 설정
    if (sanitized.isEmpty) {
      sanitized = 'file_${DateTime.now().millisecondsSinceEpoch}';
    }

    return sanitized;
  }

  /// MIME 타입에서 파일 확장자 추출
  String? _getExtensionFromMimeType(String mimeType) {
    final Map<String, String> mimeToExt = {
      'application/pdf': '.pdf',
      'application/msword': '.doc',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document': '.docx',
      'application/vnd.ms-excel': '.xls',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': '.xlsx',
      'application/vnd.ms-powerpoint': '.ppt',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation': '.pptx',
      'text/plain': '.txt',
      'text/html': '.html',
      'text/csv': '.csv',
      'image/jpeg': '.jpg',
      'image/png': '.png',
      'image/gif': '.gif',
      'image/bmp': '.bmp',
      'image/webp': '.webp',
      'image/svg+xml': '.svg',
      'audio/mpeg': '.mp3',
      'audio/wav': '.wav',
      'audio/ogg': '.ogg',
      'video/mp4': '.mp4',
      'video/mpeg': '.mpg',
      'video/quicktime': '.mov',
      'application/zip': '.zip',
      'application/x-rar-compressed': '.rar',
      'application/x-7z-compressed': '.7z',
      'application/json': '.json',
      'application/xml': '.xml',
    };

    // MIME 타입에서 확장자 찾기
    mimeType = mimeType.toLowerCase().split(';').first.trim();
    return mimeToExt[mimeType];
  }
} 