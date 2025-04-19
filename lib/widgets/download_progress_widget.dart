import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/download/download_progress_tracker.dart';
import 'dart:math' as math;
import 'download_notification_icon.dart';

/// 다운로드 진행 상태를 표시하는 위젯
/// 활성 다운로드가 있을 때만 표시됨
class DownloadProgressWidget extends StatelessWidget {
  /// 위젯 생성자
  const DownloadProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProgressTracker>(
      builder: (context, tracker, child) {
        // 활성 다운로드가 없으면 빈 컨테이너 반환
        if (tracker.allDownloads.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final downloads = tracker.allDownloads;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 헤더
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, 
                    vertical: 12.0
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.download_rounded, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '다운로드 (${tracker.activeDownloadsCount} 진행 중)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => tracker.clearAllDownloads(),
                        tooltip: '모든 내역 지우기',
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // 다운로드 목록
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    shrinkWrap: true,
                    itemCount: downloads.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final download = downloads[index];
                      return _DownloadItemWidget(download: download);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 개별 다운로드 항목 위젯
class _DownloadItemWidget extends StatelessWidget {
  final DownloadStatus download;
  
  const _DownloadItemWidget({required this.download});
  
  @override
  Widget build(BuildContext context) {
    final tracker = Provider.of<DownloadProgressTracker>(context, listen: false);
    
    // 상태에 따른 색상 설정
    Color statusColor;
    String statusText;
    
    switch (download.status) {
      case DownloadState.inProgress:
        statusColor = Colors.blue;
        statusText = '다운로드 중';
        break;
      case DownloadState.completed:
        statusColor = Colors.green;
        statusText = '완료됨';
        break;
      case DownloadState.failed:
        statusColor = Colors.red;
        statusText = '실패';
        break;
      case DownloadState.cancelled:
        statusColor = Colors.orange;
        statusText = '취소됨';
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 파일명 및 상태
          Row(
            children: [
              Expanded(
                child: Text(
                  download.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // 진행 상태 바 (진행 중일 때만)
          if (download.status == DownloadState.inProgress)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: download.progress > 0 ? download.progress / 100 : null,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (download.totalBytes != null && download.receivedBytes != null)
                      Text(
                        '${_formatFileSize(download.receivedBytes!)} / ${_formatFileSize(download.totalBytes!)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      )
                    else
                      Text(
                        '크기 알 수 없음',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    
                    Text(
                      _formatElapsedTime(download.elapsedTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
          
          // 메시지 표시 (있을 경우)
          if (download.message != null && download.message!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                download.message!,
                style: TextStyle(
                  fontSize: 12, 
                  color: download.status == DownloadState.failed 
                    ? Colors.red.shade700 
                    : Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          // 버튼 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 진행 중일 때는 취소 버튼
              if (download.status == DownloadState.inProgress)
                TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('취소'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Colors.red.shade700,
                  ),
                  onPressed: () => tracker.cancelDownload(download.id),
                )
              // 완료/실패/취소 상태일 때는 제거 버튼
              else
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('제거'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Colors.grey.shade700,
                  ),
                  onPressed: () => tracker.removeDownload(download.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 파일 크기 포맷팅
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  /// 경과 시간 포맷팅
  String _formatElapsedTime(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}초';
    } else if (duration.inMinutes < 60) {
      final seconds = duration.inSeconds % 60;
      return '${duration.inMinutes}분 ${seconds > 0 ? '$seconds초' : ''}';
    } else {
      final minutes = duration.inMinutes % 60;
      return '${duration.inHours}시간 ${minutes > 0 ? '$minutes분' : ''}';
    }
  }
} 