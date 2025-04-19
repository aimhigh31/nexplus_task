/// API 엔드포인트 상수 정의
class ApiEndpoints {
  // 인증 관련 엔드포인트
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh-token';
  static const String validateToken = 'auth/validate-token';
  
  // 사용자 관련 엔드포인트
  static const String users = 'users';
  static const String userProfile = 'users/profile';
  static const String updatePassword = 'users/update-password';
  
  // 첨부파일 관련 엔드포인트
  static const String attachmentsList = 'attachments';
  static const String attachmentsUpload = 'attachments/upload';
  static const String attachmentsDownload = 'attachments/download';
  static const String attachmentsDelete = 'attachments/delete';
  
  // VOC 관련 엔드포인트
  static const String voc = 'voc';
  static const String vocCategories = 'voc/categories';
  
  // 시스템 관련 엔드포인트
  static const String systemStatus = 'system/status';
  static const String systemLogs = 'system/logs';
  static const String systemConfig = 'system/config';
  
  // 알림 관련 엔드포인트
  static const String notifications = 'notifications';
  static const String notificationSettings = 'notifications/settings';
  
  // 대시보드 관련 엔드포인트
  static const String dashboardStats = 'dashboard/stats';
  static const String dashboardCharts = 'dashboard/charts';
} 