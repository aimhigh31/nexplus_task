import 'dart:async';
import 'package:flutter/foundation.dart';

/// 다운로드 진행 상태를 추적하는 클래스
class DownloadProgressTracker extends ChangeNotifier {
  /// 현재 진행 중인 모든 다운로드의 상태를 관리하는 맵
  /// key: 다운로드 ID (UUID), value: 다운로드 상태 정보
  final Map<String, DownloadStatus> _downloads = {};
  
  /// 다운로드 완료 콜백
  final Function(String downloadId, bool success)? onDownloadComplete;
  
  /// 생성자
  DownloadProgressTracker({this.onDownloadComplete});
  
  /// 새 다운로드 시작 등록
  String startDownload({
    required String fileName,
    int? totalBytes,
    String? description,
  }) {
    // UTC 타임스탬프 기반 ID 생성
    final downloadId = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    
    // 다운로드 상태 등록
    _downloads[downloadId] = DownloadStatus(
      id: downloadId,
      fileName: fileName,
      totalBytes: totalBytes,
      startTime: DateTime.now(),
      status: DownloadState.inProgress,
      description: description,
    );
    
    // 상태 변경 알림
    notifyListeners();
    return downloadId;
  }
  
  /// 다운로드 진행 상태 업데이트
  void updateProgress(String downloadId, {
    int? receivedBytes,
    int? totalBytes,
    String? message,
  }) {
    if (!_downloads.containsKey(downloadId)) return;
    
    final currentStatus = _downloads[downloadId]!;
    _downloads[downloadId] = currentStatus.copyWith(
      receivedBytes: receivedBytes,
      totalBytes: totalBytes,
      message: message,
      lastUpdateTime: DateTime.now(),
    );
    
    // 상태 변경 알림
    notifyListeners();
  }
  
  /// 다운로드 완료 처리
  void completeDownload(String downloadId, {
    bool success = true,
    String? message,
    String? filePath,
  }) {
    if (!_downloads.containsKey(downloadId)) return;
    
    final currentStatus = _downloads[downloadId]!;
    _downloads[downloadId] = currentStatus.copyWith(
      status: success ? DownloadState.completed : DownloadState.failed,
      message: message,
      filePath: filePath,
      endTime: DateTime.now(),
    );
    
    // 완료 콜백 호출
    onDownloadComplete?.call(downloadId, success);
    
    // 상태 변경 알림
    notifyListeners();
    
    // 자동 정리 타이머 설정 (완료 후 5분)
    Timer(const Duration(minutes: 5), () {
      removeDownload(downloadId);
    });
  }
  
  /// 다운로드 취소 처리
  void cancelDownload(String downloadId, {String? message}) {
    if (!_downloads.containsKey(downloadId)) return;
    
    final currentStatus = _downloads[downloadId]!;
    _downloads[downloadId] = currentStatus.copyWith(
      status: DownloadState.cancelled,
      message: message ?? '사용자에 의해 취소됨',
      endTime: DateTime.now(),
    );
    
    // 상태 변경 알림
    notifyListeners();
    
    // 자동 정리 타이머 설정 (취소 후 1분)
    Timer(const Duration(minutes: 1), () {
      removeDownload(downloadId);
    });
  }
  
  /// 다운로드 정보 제거
  void removeDownload(String downloadId) {
    if (!_downloads.containsKey(downloadId)) return;
    
    _downloads.remove(downloadId);
    notifyListeners();
  }
  
  /// 모든 다운로드 정보 제거
  void clearAllDownloads() {
    _downloads.clear();
    notifyListeners();
  }
  
  /// 진행 중인 다운로드 수 확인
  int get activeDownloadsCount => 
    _downloads.values.where((d) => d.status == DownloadState.inProgress).length;
  
  /// 모든 다운로드 상태 조회
  List<DownloadStatus> get allDownloads => _downloads.values.toList();
  
  /// 진행 중인 다운로드 상태 조회
  List<DownloadStatus> get activeDownloads => 
    _downloads.values.where((d) => d.status == DownloadState.inProgress).toList();
  
  /// 완료된 다운로드 상태 조회
  List<DownloadStatus> get completedDownloads => 
    _downloads.values.where((d) => d.status == DownloadState.completed).toList();
  
  /// 특정 다운로드 상태 조회
  DownloadStatus? getDownloadStatus(String downloadId) => _downloads[downloadId];
}

/// 다운로드 상태 열거형
enum DownloadState {
  inProgress,
  completed,
  failed,
  cancelled,
}

/// 다운로드 상태 정보 클래스
class DownloadStatus {
  /// 다운로드 고유 ID
  final String id;
  
  /// 파일 이름
  final String fileName;
  
  /// 다운로드 설명
  final String? description;
  
  /// 전체 파일 크기 (바이트)
  final int? totalBytes;
  
  /// 수신된 파일 크기 (바이트)
  final int? receivedBytes;
  
  /// 다운로드 상태
  final DownloadState status;
  
  /// 진행률 (0-100)
  double get progress {
    if (totalBytes == null || receivedBytes == null || totalBytes! <= 0) {
      return 0.0;
    }
    return (receivedBytes! / totalBytes! * 100).clamp(0.0, 100.0);
  }
  
  /// 다운로드 시작 시간
  final DateTime startTime;
  
  /// 다운로드 마지막 업데이트 시간
  final DateTime? lastUpdateTime;
  
  /// 다운로드 종료 시간
  final DateTime? endTime;
  
  /// 다운로드 경과 시간 (초)
  Duration get elapsedTime {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
  
  /// 메시지 (오류/알림 등)
  final String? message;
  
  /// 저장된 파일 경로
  final String? filePath;
  
  /// 생성자
  const DownloadStatus({
    required this.id,
    required this.fileName,
    required this.startTime,
    required this.status,
    this.description,
    this.totalBytes,
    this.receivedBytes,
    this.lastUpdateTime,
    this.endTime,
    this.message,
    this.filePath,
  });
  
  /// 새 상태로 복사하여 반환
  DownloadStatus copyWith({
    String? fileName,
    String? description,
    int? totalBytes,
    int? receivedBytes,
    DownloadState? status,
    DateTime? startTime,
    DateTime? lastUpdateTime,
    DateTime? endTime,
    String? message,
    String? filePath,
  }) {
    return DownloadStatus(
      id: this.id,
      fileName: fileName ?? this.fileName,
      description: description ?? this.description,
      totalBytes: totalBytes ?? this.totalBytes,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      endTime: endTime ?? this.endTime,
      message: message ?? this.message,
      filePath: filePath ?? this.filePath,
    );
  }
} 