import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

/// Windows 환경에서 파일 다운로드 관련 문제를 처리하는 도우미 클래스
class WindowsDownloadHelper {
  /// Windows 개발자 모드 활성화 여부 확인
  /// 
  /// 개발자 모드가 비활성화된 경우 FilePicker 등에서 symlink 관련 오류가 발생할 수 있음
  static Future<bool> isDeveloperModeEnabled() async {
    if (!Platform.isWindows) return true; // Windows가 아니면 항상 true 반환
    
    try {
      // Windows 레지스트리 확인 (PowerShell 사용)
      final result = await Process.run(
        'powershell.exe',
        ['-Command', '(Get-ItemProperty "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock").AllowDevelopmentWithoutDevLicense'],
        runInShell: true,
      );
      
      final output = result.stdout.toString().trim();
      return output == '1'; // 1이면 개발자 모드 활성화
    } catch (e) {
      debugPrint('개발자 모드 확인 오류: $e');
      return false; // 확인 불가능한 경우 false 반환
    }
  }
  
  /// Windows 개발자 모드 활성화 안내 메시지 반환
  static String getDeveloperModeInstructions() {
    return '''
Windows에서 파일 다운로드를 위해 개발자 모드를 활성화해야 합니다.

1. Windows 설정 앱을 엽니다.
2. [개인 정보 및 보안] > [개발자용] 메뉴로 이동합니다.
3. [개발자 모드] 옵션을 켭니다.
4. 시스템을 재시작합니다.

개발자 모드를 활성화한 후 다시 시도해 주세요.
''';
  }
  
  /// Windows에서 유효한 파일명으로 변환
  /// 
  /// Windows에서 금지된 문자를 제거하고, 길이를 제한하며,
  /// 한글 등 유니코드 문자가 포함된 경우 안전하게 처리
  static String sanitizeWindowsFilename(String filename) {
    // Windows에서 금지된 문자 제거: \ / : * ? " < > |
    String sanitized = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    
    // 파일명 길이 제한 (Windows 최대 260자)
    const maxLength = 240; // 경로 추가 여유 고려
    if (sanitized.length > maxLength) {
      final ext = path.extension(sanitized);
      final nameWithoutExt = path.basenameWithoutExtension(sanitized);
      sanitized = '${nameWithoutExt.substring(0, maxLength - ext.length - 1)}$ext';
    }
    
    // 파일명 시작/끝의 공백과 마침표 제거 (Windows 제한사항)
    sanitized = sanitized.trim().replaceAll(RegExp(r'^\.+|\.+$'), '');
    
    // 파일명이 비어있으면 기본값 사용
    if (sanitized.isEmpty || sanitized == '.') {
      sanitized = 'download_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    return sanitized;
  }
  
  /// Windows에서 symlink 생성 권한 확인
  /// 
  /// 개발자 모드가 비활성화된 경우 symlink 생성 권한이 없을 수 있음
  static Future<bool> canCreateSymlinks() async {
    if (!Platform.isWindows) return true;
    
    try {
      final tempDir = Directory.systemTemp;
      final testLinkPath = path.join(tempDir.path, 'test_symlink_${DateTime.now().millisecondsSinceEpoch}');
      final testTargetPath = path.join(tempDir.path, 'test_target_${DateTime.now().millisecondsSinceEpoch}');
      
      // 테스트 대상 파일 생성
      final testTargetFile = File(testTargetPath);
      await testTargetFile.create();
      
      // 심볼릭 링크 생성 시도
      final testLink = Link(testLinkPath);
      await testLink.create(testTargetPath);
      
      // 테스트 파일 및 링크 정리
      await testLink.delete();
      await testTargetFile.delete();
      
      return true; // 심볼릭 링크 생성 성공
    } catch (e) {
      debugPrint('심볼릭 링크 생성 테스트 실패: $e');
      return false; // 심볼릭 링크 생성 실패
    }
  }
  
  /// Windows 개발자 모드 활성화 설정 페이지 열기
  static Future<bool> openDeveloperModeSettings() async {
    if (!Platform.isWindows) return false;
    
    try {
      await Process.run(
        'start', 
        ['ms-settings:developers'], 
        runInShell: true
      );
      return true;
    } catch (e) {
      debugPrint('개발자 모드 설정 페이지 열기 실패: $e');
      return false;
    }
  }
  
  /// Windows에서 안전한 파일 저장 경로 생성
  /// 
  /// 한글 등 비ASCII 문자가 포함된 경우에도 안전하게 처리
  static String createSafeFilePath(String directory, String filename) {
    final sanitizedFilename = sanitizeWindowsFilename(filename);
    
    // 경로에 비ASCII 문자가 포함된 경우 대체 경로 사용 가능성 검사
    bool hasNonAscii = sanitizedFilename.codeUnits.any((c) => c > 127);
    if (hasNonAscii) {
      debugPrint('비ASCII 문자가 포함된 파일명: $sanitizedFilename');
    }
    
    return path.join(directory, sanitizedFilename);
  }
  
  /// 파일 저장 실패 시 대체 파일명으로 재시도
  /// 
  /// 파일명에 한글이 포함되어 저장 실패 시 ASCII 문자로만 구성된 대체 파일명 사용
  static Future<String?> saveWithFallbackFilename(
    Uint8List data, 
    String directory, 
    String originalFilename
  ) async {
    try {
      // 원본 파일명으로 저장 시도
      final originalPath = path.join(directory, sanitizeWindowsFilename(originalFilename));
      final file = File(originalPath);
      await file.writeAsBytes(data);
      return originalPath;
    } catch (e) {
      debugPrint('원본 파일명으로 저장 실패: $e');
      
      try {
        // ASCII 파일명으로 대체하여 저장
        final ext = path.extension(originalFilename);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final safeFilename = 'download_$timestamp$ext';
        final safePath = path.join(directory, safeFilename);
        
        final file = File(safePath);
        await file.writeAsBytes(data);
        debugPrint('대체 파일명으로 저장 성공: $safePath');
        return safePath;
      } catch (fallbackError) {
        debugPrint('대체 파일명으로도 저장 실패: $fallbackError');
        return null;
      }
    }
  }
} 