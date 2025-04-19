# Windows 다운로드 및 파일 피커 문제 해결 가이드

## 주요 문제점

1. **Windows 개발자 모드 필요**
   - `file_picker` 패키지는 Windows에서 심볼릭 링크를 사용하기 위해 개발자 모드가 필요합니다.
   - 활성화되지 않은 경우 파일/폴더 선택 시 권한 오류가 발생합니다.

2. **한글 파일명 UTF-8 인코딩 문제**
   - 다운로드 시 한글 파일명이 올바르게 처리되지 않는 문제가 있습니다.
   - Content-Disposition 헤더에서 파일명 추출 개선이 필요합니다.

3. **다운로드 실패 시 오류 표시 부족**
   - 다운로드 실패 시 사용자에게 적절한 피드백이 제공되지 않습니다.

## 해결 방안

### 방법 1: Windows 개발자 모드 활성화

1. Windows 설정 앱을 엽니다 (Win + I)
2. '개인 정보 보호 및 보안' > '개발자용' 메뉴로 이동
3. '개발자 모드' 옵션을 켜기로 전환
4. 컴퓨터 재시작

### 방법 2: 향상된 다운로드 서비스 사용 (권장)

새로 만든 `ImprovedDownloadService` 클래스를 사용하여 다운로드 기능을 개선할 수 있습니다.

#### 사용 방법:

1. `lib/services/api_service.dart` 파일에 다음 코드를 추가:

```dart
import 'improved_download_service.dart';

// API 서비스 클래스 내부에 다음 코드 추가
late final ImprovedDownloadService _downloadService;

// 생성자에 다음 코드 추가
ApiService() {
  // 기존 초기화 코드...
  _downloadService = ImprovedDownloadService(baseUrl: _baseUrl);
}

// 기존 downloadAttachment 메서드를 다음과 같이 수정
Future<bool> downloadAttachment(String attachmentId, {String? suggestedFileName}) async {
  return _downloadService.downloadAttachment(attachmentId, suggestedFileName: suggestedFileName);
}
```

### 방법 3: API 서비스 파일 최적화

`api_service.dart` 파일에는 중복된 import 문이 많아 파일 크기가 불필요하게 큽니다. 다음과 같이 정리하는 것을 권장합니다:

```dart
// 표준 Dart 라이브러리 임포트
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

// 플러터 라이브러리
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';

// 패키지 임포트
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// 프로젝트 임포트
import 'improved_download_service.dart';
```

## 참고 사항

1. Windows 개발자 모드가 활성화되지 않으면 `file_picker` 패키지의 `getDirectoryPath()` 메서드가 제대로 동작하지 않습니다.
2. 최신 버전의 `file_picker` 패키지(5.5.0)는 Windows, macOS, Linux에서 인라인 구현을 제공하지 않는다는 경고 메시지가 표시될 수 있습니다.
3. `excel` 패키지 API 변경으로 인해 `TextCellValue` 및 `setColumnWidth` 메서드 사용 방식이 변경되었습니다. 