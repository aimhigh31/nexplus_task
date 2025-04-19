/// API 통신에 사용되는 상수들을 정의합니다.
class ApiConstants {
  /// 기본 API URL
  static const String baseUrl = 'http://localhost:3000/api';
  
  /// API 경로 상수
  static const String vocEndpoint = 'voc';
  static const String systemUpdateEndpoint = 'system-updates';
  static const String solutionDevelopmentEndpoint = 'solution-development';
  static const String hardwareEndpoint = 'hardware';
  static const String hardwareAssetsEndpoint = 'hardware-assets'; 
  static const String softwareEndpoint = 'software';
  static const String equipmentConnectionEndpoint = 'equipment-connections';
  static const String attachmentEndpoint = 'attachments';
  
  /// 메모리 백업 API 경로
  static const String memoryVocEndpoint = 'memory/voc';
  static const String memorySystemUpdateEndpoint = 'memory/system-updates';
  static const String memoryHardwareEndpoint = 'memory/hardware';
  static const String memorySoftwareEndpoint = 'memory/software';
  static const String memoryEquipmentConnectionEndpoint = 'memory/equipment-connections';
  
  /// 타임아웃 상수 (초)
  static const int defaultGetTimeout = 10;
  static const int defaultPostTimeout = 15;
  static const int defaultPutTimeout = 15;
  static const int defaultDeleteTimeout = 10;
  static const int longOperationTimeout = 30;
  static const int connectionTestTimeout = 5;
  
  /// 페이지네이션 기본값
  static const int defaultPageSize = 100;
  static const int defaultSkip = 0;
} 