import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:mime/mime.dart';

// 웹 환경에서만 필요한 import
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// 파일 다운로드 헬퍼 클래스
class DownloadHelper {
  /// 파일 다운로드 함수
  /// 웹과 네이티브 환경 모두 지원
  static Future<bool> downloadFile({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) async {
    try {
      final extension = fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : 'bin';
          
      final mime = mimeType ?? _getMimeType(extension);
      
      if (kIsWeb) {
        return _downloadInWeb(bytes, fileName, mime);
      } else {
        return _downloadInNative(bytes, fileName);
      }
    } catch (e) {
      debugPrint('다운로드 오류: $e');
      return false;
    }
  }
  
  /// 웹 환경에서 파일 다운로드
  static Future<bool> _downloadInWeb(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    try {
      // HTML5 Blob API 사용
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // 다운로드 링크 생성 및 클릭
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';
      
      html.document.body?.append(anchor);
      anchor.click();
      
      // 리소스 정리
      html.Url.revokeObjectUrl(url);
      anchor.remove();
      
      debugPrint('HTML5 API로 파일 다운로드 완료: $fileName');
      return true;
    } catch (e) {
      debugPrint('HTML5 다운로드 에러: $e');
      
      // 에러 발생 시 FileSaver로 폴백
      try {
        await FileSaver.instance.saveFile(
          name: fileName.split('.').first,
          bytes: bytes,
          ext: fileName.split('.').last,
          mimeType: MimeType.other,
        );
        debugPrint('FileSaver로 다운로드 완료: $fileName');
        return true;
      } catch (e2) {
        debugPrint('FileSaver 에러: $e2');
        return false;
      }
    }
  }
  
  /// 네이티브 환경에서 파일 다운로드
  static Future<bool> _downloadInNative(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        final path = '$result/$fileName';
        final file = File(path);
        await file.writeAsBytes(bytes);
        debugPrint('네이티브 환경에서 파일 저장 완료: $path');
        return true;
      } else {
        debugPrint('파일 저장 위치 선택 취소됨');
        return false;
      }
    } catch (e) {
      debugPrint('네이티브 다운로드 에러: $e');
      return false;
    }
  }
  
  /// 확장자로 MIME 타입 결정
  static String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
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
} 