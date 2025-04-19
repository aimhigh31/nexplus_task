import 'package:flutter/material.dart';

import 'api/attachment_service.dart';
import 'service_locator.dart';

/// API 서비스 마이그레이션 예제
/// 
/// 이 예제는 기존 코드에서 새로운 서비스 아키텍처로 마이그레이션하는 방법을 보여줍니다.
class MigrationExample extends StatelessWidget {
  const MigrationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이그레이션 예제')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _downloadExampleFile,
              child: const Text('파일 다운로드 예제'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadExampleFile,
              child: const Text('파일 업로드 예제'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _downloadExampleFile() async {
    try {
      // 서비스 로케이터를 통해 첨부파일 서비스 가져오기
      final attachmentService = serviceLocator<AttachmentService>();
      
      // 파일 다운로드
      final success = await attachmentService.downloadAttachment(
        'example-attachment-id',
        suggestedFileName: '예제파일.pdf',
      );
      
      debugPrint('파일 다운로드 ${success ? '성공' : '실패'}');
    } catch (e) {
      debugPrint('파일 다운로드 중 오류: $e');
    }
  }
  
  Future<void> _uploadExampleFile() async {
    try {
      // 서비스 로케이터를 통해 첨부파일 서비스 가져오기
      final attachmentService = serviceLocator<AttachmentService>();
      
      // 파일 업로드 (실제로는 파일 선택 로직이 필요)
      final dummyBytes = List<int>.filled(1024, 0); // 더미 데이터
      
      final result = await attachmentService.uploadFile(
        fileBytes: dummyBytes,
        fileName: '예제파일.pdf',
        entityId: 'example-entity-id',
        entityType: 'example',
      );
      
      if (result != null) {
        debugPrint('파일 업로드 성공: ${result.id}');
      } else {
        debugPrint('파일 업로드 실패');
      }
    } catch (e) {
      debugPrint('파일 업로드 중 오류: $e');
    }
  }
}

/// main.dart에 추가할 코드:
/// 
/// ```dart
/// import 'services/service_locator.dart';
/// 
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // 서비스 로케이터 설정
///   setupServiceLocator();
///   
///   // 기존 의존성 주입 초기화
///   await di.init();
///   
///   // ... 나머지 코드 ...
/// }
/// ``` 