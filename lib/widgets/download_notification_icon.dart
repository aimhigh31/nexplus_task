import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../services/download/download_progress_tracker.dart';

/// 다운로드 알림 아이콘
/// 활성 다운로드가 있을 때만 표시됨
class DownloadNotificationIcon extends StatelessWidget {
  const DownloadNotificationIcon({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProgressTracker>(
      builder: (context, tracker, child) {
        // 활성 다운로드가 없으면 빈 컨테이너 반환
        if (tracker.activeDownloadsCount == 0) {
          return const SizedBox.shrink();
        }
        
        // 활성 다운로드가 있으면 뱃지와 함께 아이콘 표시
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // 클릭 시 다운로드 진행 상태 위젯 표시 토글
              // 이 기능은 DownloadProgressWidget의 표시 상태를 관리하는 
              // ValueNotifier 등으로 확장 가능
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  const DownloadingIcon(),
                  if (tracker.activeDownloadsCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${tracker.activeDownloadsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 다운로드 중 회전하는 아이콘
class DownloadingIcon extends StatefulWidget {
  const DownloadingIcon({super.key});

  @override
  State<DownloadingIcon> createState() => _DownloadingIconState();
}

class _DownloadingIconState extends State<DownloadingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: const Icon(
            Icons.downloading_rounded,
            color: Colors.blue,
            size: 28,
          ),
        );
      },
    );
  }
} 