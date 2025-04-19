# API 서비스 아키텍처 개선 가이드

## 1. 개요

이 문서는 기존의 단일 파일 `api_service.dart`를 여러 모듈로 분리하여 유지보수성을 높이고 코드 품질을 개선하기 위한 가이드입니다.

## 2. 새로운 구조

```
lib/services/
├── api/
│   ├── api_client.dart      # 기본 HTTP 통신 래퍼
│   ├── api_endpoints.dart   # API 엔드포인트 상수
│   └── attachment_service.dart # 첨부파일 관련 서비스
├── download/
│   ├── download_service.dart # 다운로드 관련 서비스
│   └── file_utilities.dart   # 파일 관련 유틸리티
├── utils/
│   └── logging_service.dart  # 로깅 기능
└── service_locator.dart      # 의존성 주입 설정
```

## 3. 마이그레이션 가이드

기존 코드에서 새 아키텍처로 마이그레이션하는 단계:

1. `setupServiceLocator()`를 앱 시작 시 호출하여 서비스를 초기화합니다.
2. 기존 `api_service.dart`를 사용하는 코드를 새 서비스를 사용하도록 점진적으로 변경합니다.

예시:

```dart
// 이전 코드
final apiService = ApiService();
await apiService.downloadAttachment('123');

// 새 코드
final attachmentService = serviceLocator<AttachmentService>();
await attachmentService.downloadAttachment('123');
```

## 4. 주요 개선사항

### 4.1 의존성 주입

GetIt을 활용한 의존성 주입으로 다음과 같은 이점을 얻습니다:

- 테스트 용이성 향상
- 코드 모듈화
- 관심사의 분리

### 4.2 로깅 개선

표준화된 로깅 메커니즘을 제공합니다:

```dart
final logger = serviceLocator<LoggingService>();
logger.info('작업 시작', data: {'key': 'value'});
logger.error('오류 발생', exception: e, data: {'key': 'value'});
```

### 4.3 파일 다운로드 강화

개선된 다운로드 서비스 기능:

- Windows 개발자 모드 관련 오류 처리
- 한글 파일명 UTF-8 인코딩 처리
- 다양한 환경(웹/네이티브)에 대한 통합 지원

## 5. 코드 품질 지침

전체 코드베이스에 적용할 가이드라인:

### 5.1 함수 크기

- 각 메서드는 최대 50줄을 넘지 않도록 함
- 한 가지 책임만 담당하도록 설계

### 5.2 오류 처리

- 모든 예외는 로깅하여 추적 가능하게 함
- 사용자에게 친화적인 오류 메시지 제공

### 5.3 명명 규칙

- 클래스: `PascalCase` (예: `ApiClient`)
- 메서드와 변수: `camelCase` (예: `downloadFile()`)
- 상수: `UPPER_SNAKE_CASE` (예: `MAX_RETRY_COUNT`)

### 5.4 주석

- Public API에는 다트독 주석(`///`) 사용
- 복잡한 로직에는 일반 주석(`//`) 추가

## 6. 마이그레이션 우선순위

1. 다운로드 관련 기능 → `download_service.dart`
2. 첨부파일 관련 기능 → `attachment_service.dart`
3. API 관련 공통 기능 → `api_client.dart`
4. 로깅 관련 기능 → `logging_service.dart`

## 7. UTF-8 인코딩

모든 텍스트 처리 및 파일 처리에 UTF-8 인코딩을 일관되게 적용합니다:

- HTTP 요청/응답 처리
- 파일 저장 및 로드
- 한글 등 비ASCII 문자 처리 