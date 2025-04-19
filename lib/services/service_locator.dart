import 'package:get_it/get_it.dart';

import 'api/api_client.dart';
import 'api/attachment_service.dart';
import 'api/voc_service.dart';
import 'api/equipment_connection_service.dart';
import 'download/download_service.dart';
import 'download/download_progress_tracker.dart';
import 'utils/logging_service.dart';

/// 전역 서비스 로케이터 인스턴스
final GetIt serviceLocator = GetIt.instance;

/// 서비스 로케이터 설정
void setupServiceLocator() {
  final baseUrl = _getBaseUrl();
  
  // 로깅 서비스
  serviceLocator.registerLazySingleton<LoggingService>(
    () => LoggingService(serverLogUrl: '$baseUrl/api/logs')
  );
  
  // API 클라이언트
  serviceLocator.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: baseUrl)
  );
  
  // 다운로드 진행 추적기
  serviceLocator.registerLazySingleton<DownloadProgressTracker>(
    () => DownloadProgressTracker()
  );
  
  // 다운로드 서비스
  serviceLocator.registerLazySingleton<DownloadService>(
    () => DownloadService(
      baseUrl: baseUrl,
      apiClient: serviceLocator<ApiClient>(),
      logger: serviceLocator<LoggingService>(),
      progressTracker: serviceLocator<DownloadProgressTracker>(),
    )
  );
  
  // 첨부파일 서비스
  serviceLocator.registerLazySingleton<AttachmentService>(
    () => AttachmentService(
      baseUrl: baseUrl,
      apiClient: serviceLocator<ApiClient>(),
      downloadService: serviceLocator<DownloadService>(),
      logger: serviceLocator<LoggingService>(),
    )
  );
  
  // VOC 서비스
  serviceLocator.registerLazySingleton<VocService>(
    () => VocService(
      baseUrl: baseUrl,
      apiClient: serviceLocator<ApiClient>(),
      logger: serviceLocator<LoggingService>(),
    )
  );
  
  // 설비연동 서비스
  serviceLocator.registerLazySingleton<EquipmentConnectionService>(
    () => EquipmentConnectionService(
      baseUrl: baseUrl,
      apiClient: serviceLocator<ApiClient>(),
      logger: serviceLocator<LoggingService>(),
    )
  );
}

/// API 기본 URL 가져오기
String _getBaseUrl() {
  // 실제 환경에서는 환경 설정이나 .env 파일에서 가져올 수 있음
  const defaultUrl = 'http://localhost:3000';
  
  // 개발 환경별 URL 설정
  const envValues = {
    'dev': 'http://localhost:3000',
    'staging': 'https://api-staging.example.com',
    'prod': 'https://api.example.com',
  };
  
  // 현재는 하드코딩된 환경을 사용하지만,
  // 실제로는 환경 변수나 빌드 구성에서 가져와야 함
  const currentEnv = 'dev';
  
  return envValues[currentEnv] ?? defaultUrl;
} 