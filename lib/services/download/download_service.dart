import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'windows_download_helper.dart';
import 'file_utilities.dart';
import 'download_progress_tracker.dart';
import '../api/api_client.dart';
import '../utils/logging_service.dart';
import '../api/api_endpoints.dart';
import 'package:uuid/uuid.dart';

/// 파일 다운로드 서비스
/// 향상된 다운로드 기능과 오류 처리 제공
class DownloadService {
  final String baseUrl;
  final ApiClient _apiClient;
  final LoggingService _logger;
  final DownloadProgressTracker _progressTracker;
  final Uuid _uuid = const Uuid();
  
  /// 최대 재시도 횟수
  final int _maxRetries = 3;
  
  /// 재시도 간격 (밀리초)
  final List<int> _retryDelays = [1000, 3000, 5000]; // 점진적으로 증가하는 대기 시간
  
  /// 생성자
  DownloadService({
    required this.baseUrl,
    required ApiClient apiClient,
    required LoggingService logger,
    required DownloadProgressTracker progressTracker,
  }) : 
    _apiClient = apiClient,
    _logger = logger,
    _progressTracker = progressTracker;
  
  /// 첨부파일 다운로드
  Future<bool> downloadAttachment(
    String attachmentId, {
    String? suggestedFileName,
    bool showErrors = true,
    String? description,
  }) async {
    // 다운로드 진행상태 시작
    final downloadId = _progressTracker.startDownload(
      fileName: suggestedFileName ?? '첨부파일 다운로드',
      description: description ?? '첨부파일 ID: $attachmentId',
    );
    
    try {
      _logger.info('첨부파일 다운로드 시작', data: {'attachmentId': attachmentId});
      
      final uri = Uri.parse('$baseUrl/api/attachments/download/$attachmentId');
      bool success = false;
      Exception? lastError;
      
      // 재시도 메커니즘 구현
      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          // 다운로드 진행 상태 업데이트
          _progressTracker.updateProgress(
            downloadId,
            message: attempt > 0 ? '다운로드 재시도 중 (${attempt+1}/$_maxRetries)...' : '다운로드 중...',
          );
          
          // GET 요청으로 파일 다운로드
          final response = await http.get(
            uri,
            headers: {'Accept': '*/*'}, // 모든 응답 유형 허용
          ).timeout(
            const Duration(seconds: 120), // 대용량 파일 고려 타임아웃 증가
            onTimeout: () => http.Response('Timeout', 408),
          );

          _logger.info('첨부파일 다운로드 응답 수신', data: {
            'statusCode': response.statusCode, 
            'contentLength': response.contentLength,
            'attempt': attempt + 1,
          });
          
          // 응답 본문 크기 업데이트
          _progressTracker.updateProgress(
            downloadId,
            totalBytes: response.contentLength,
            receivedBytes: response.bodyBytes.length,
          );
          
          // 다운로드 응답 처리
          success = await _processDownloadResponse(
            response, 
            suggestedFileName: suggestedFileName,
            entityType: 'attachment',
            showErrors: showErrors,
            downloadId: downloadId,
            description: description,
          );
          
          if (success) {
            return true; // 성공하면 재시도 중단
          } else {
            lastError = Exception('다운로드 처리 실패 (상태 코드: ${response.statusCode})');
          }
        } catch (e) {
          _logger.error('첨부파일 다운로드 HTTP 요청 실패', 
            exception: e, 
            data: {'attachmentId': attachmentId, 'url': uri.toString(), 'attempt': attempt + 1}
          );
          
          lastError = e is Exception ? e : Exception(e.toString());
          
          // 대체 엔드포인트 시도
          if (attempt == 0) {
            try {
              _logger.info('대체 엔드포인트로 다시 시도');
              _progressTracker.updateProgress(
                downloadId,
                message: '대체 엔드포인트로 다시 시도 중...',
              );
              
              final uri2 = Uri.parse('$baseUrl/api/attachment/download?id=$attachmentId');
              
              final response = await http.get(
                uri2,
                headers: {'Accept': '*/*'},
              ).timeout(
                const Duration(seconds: 120),
                onTimeout: () => http.Response('Timeout', 408),
              );
              
              _logger.info('대체 엔드포인트 응답', data: {'statusCode': response.statusCode});
              
              // 응답 본문 크기 업데이트
              _progressTracker.updateProgress(
                downloadId,
                totalBytes: response.contentLength,
                receivedBytes: response.bodyBytes.length,
              );
              
              success = await _processDownloadResponse(
                response, 
                suggestedFileName: suggestedFileName,
                entityType: 'attachment',
                showErrors: showErrors,
                downloadId: downloadId,
                description: description,
              );
              
              if (success) {
                return true; // 성공하면 재시도 중단
              }
            } catch (altError) {
              _logger.error('대체 엔드포인트 요청도 실패', 
                exception: altError, 
                data: {'attachmentId': attachmentId}
              );
            }
          }
          
          // 마지막 시도가 아니면 재시도 대기
          if (attempt < _maxRetries - 1) {
            final delayMs = _retryDelays[attempt];
            _progressTracker.updateProgress(
              downloadId,
              message: '다운로드 실패, ${delayMs ~/ 1000}초 후 재시도 예정...',
            );
            await Future.delayed(Duration(milliseconds: delayMs));
          }
        }
      }
      
      // 모든 시도 실패
      _progressTracker.completeDownload(
        downloadId, 
        success: false,
        message: '최대 재시도 횟수($_maxRetries회) 초과, 다운로드 실패',
      );
      
      _logger.error('첨부파일 다운로드 최대 재시도 횟수 초과', 
        exception: lastError, 
        data: {'attachmentId': attachmentId, 'maxRetries': _maxRetries}
      );
      
      return false;
    } catch (e) {
      _logger.error('첨부파일 다운로드 처리 중 예외 발생', exception: e);
      
      _progressTracker.completeDownload(
        downloadId, 
        success: false,
        message: '다운로드 중 오류 발생: ${e.toString().substring(0, math.min(e.toString().length, 100))}',
      );
      
      return false;
    }
  }

  /// 다운로드 응답 처리 (바이너리 데이터를 파일로 저장)
  Future<bool> _processDownloadResponse(
    http.Response response, {
    String? suggestedFileName, 
    String entityType = '',
    bool showErrors = true,
    String? downloadId,
    String? description,
  }) async {
    String? activeDownloadId = downloadId;
    
    try {
      if (response.statusCode != 200) {
        _logger.error('다운로드 실패', data: {
          'statusCode': response.statusCode,
          'entityType': entityType,
        });
        
        // 다운로드 ID가 있으면 실패 상태로 업데이트
        if (activeDownloadId != null) {
          _progressTracker.completeDownload(
            activeDownloadId, 
            success: false,
            message: '다운로드 실패: 서버 응답 코드 ${response.statusCode}',
          );
        }
        
        if (showErrors) {
          debugPrint('다운로드 실패: HTTP ${response.statusCode}');
        }
        return false;
      }

      final contentTypeHeader = response.headers['content-type'] ?? 'application/octet-stream';
      final contentLength = response.contentLength ?? response.bodyBytes.length;
      
      // 헤더에서 파일명 추출 (한글 파일명 처리 개선)
      String fileName = '';
      
      // 1. 헤더에서 파일명 추출 시도
      final headerFileName = FileUtilities.getFilenameFromHeaders(response.headers);
      
      // 2. 헤더에서 추출한 파일명 처리 (인코딩 문제 해결)
      if (headerFileName != null && headerFileName.isNotEmpty) {
        fileName = headerFileName;
        // 비ASCII 문자 (한글 등) 확인 및 처리
        final hasNonAscii = fileName.codeUnits.any((code) => code > 127);
        if (hasNonAscii) {
          _logger.info('비ASCII 문자가 포함된 파일명 처리', data: {'fileName': fileName});
          // 필요시 추가 디코딩 처리
          try {
            fileName = Uri.decodeComponent(fileName);
          } catch (e) {
            _logger.error('파일명 디코딩 중 오류', exception: e, data: {'fileName': fileName});
          }
        }
      } else {
        // 3. 헤더에서 추출 실패 시 대체 파일명 사용
        fileName = suggestedFileName ?? 'downloaded_file_${DateTime.now().millisecondsSinceEpoch}';
        _logger.info('대체 파일명 사용', data: {'fileName': fileName});
      }
      
      // 4. 유효하지 않은 파일명 문자 제거 (Windows 파일 시스템 호환성)
      fileName = FileUtilities.sanitizeFileName(fileName);
          
      // 5. 확장자가 없는 경우 콘텐츠 타입을 기반으로 적절한 확장자 추가
      if (!fileName.contains('.')) {
        final extension = FileUtilities.getExtensionFromMimeType(contentTypeHeader);
        fileName = '$fileName.$extension';
      }
      
      final fileSize = FileUtilities.formatFileSize(contentLength);
      _logger.info('다운로드 파일 정보', data: {
        'fileName': fileName,
        'contentType': contentTypeHeader,
        'size': fileSize,
      });
      
      // 다운로드 진행 상태 갱신
      if (activeDownloadId == null) {
        // 기존 다운로드 ID가 없으면 새로 생성
        activeDownloadId = _progressTracker.startDownload(
          fileName: fileName,
          totalBytes: contentLength,
          description: description,
        );
      } else {
        // 다운로드 정보 업데이트
        _progressTracker.updateProgress(
          activeDownloadId,
          totalBytes: contentLength,
          receivedBytes: contentLength, // 이미 전체 데이터를 받음
          message: '파일 저장 중...',
        );
      }
      
      // 웹 환경에서는 FileSaver 사용
      if (kIsWeb) {
        try {
          await FileSaver.instance.saveFile(
            name: fileName,
            bytes: response.bodyBytes,
            ext: fileName.split('.').last,
            mimeType: MimeType.other,
          );
          _logger.info('웹 환경에서 파일 저장 완료', data: {'fileName': fileName});
          
          // 다운로드 완료 상태 업데이트
          _progressTracker.completeDownload(
            activeDownloadId!,
            success: true,
            message: '다운로드 완료',
            filePath: fileName,
          );
          
          return true;
        } catch (e) {
          _logger.error('웹 환경에서 파일 저장 실패', exception: e);
          
          // 다운로드 실패 상태 업데이트
          _progressTracker.completeDownload(
            activeDownloadId!,
            success: false,
            message: '파일 저장 실패: ${e.toString()}',
          );
          
          if (showErrors) {
            debugPrint('웹 환경에서 파일 저장 실패: $e');
          }
          return false;
        }
      } else {
        // Windows 환경에서 개발자 모드 체크
        if (Platform.isWindows) {
          try {
            bool developerModeEnabled = await WindowsDownloadHelper.isDeveloperModeEnabled();
            if (!developerModeEnabled) {
              _logger.warning('Windows 개발자 모드가 비활성화됨', data: {
                'hint': '파일 다운로드 기능이 제한될 수 있습니다.'
              });
              
              _progressTracker.updateProgress(
                activeDownloadId!,
                message: 'Windows 개발자 모드가 비활성화되어 있습니다. 일부 기능이 제한될 수 있습니다.',
              );
              
              if (showErrors) {
                debugPrint('Windows 개발자 모드가 비활성화되어 있습니다. 일부 기능이 제한될 수 있습니다.');
              }
            }
          } catch (e) {
            _logger.warning('Windows 개발자 모드 확인 실패', data: {
              'error': e.toString()
            });
          }
        }
        
        // 네이티브 환경에서는 파일로 저장
        try {
          final result = await FilePicker.platform.getDirectoryPath();
          if (result == null) {
            _logger.info('파일 저장 위치 선택 취소됨');
            
            // 다운로드 취소 상태 업데이트
            _progressTracker.cancelDownload(
              activeDownloadId!,
              message: '사용자가 저장 위치 선택을 취소했습니다.',
            );
            
            return false;
          }
          
          // 다운로드 진행 상태 업데이트
          _progressTracker.updateProgress(
            activeDownloadId!,
            message: '파일 저장 중...',
          );
          
          // Windows 환경에서는 파일명 처리 추가 주의
          if (Platform.isWindows) {
            final fileBytes = response.bodyBytes;
            final savedPath = await WindowsDownloadHelper.saveWithFallbackFilename(
              fileBytes, 
              result, 
              fileName
            );
            
            if (savedPath != null) {
              _logger.info('Windows에서 파일 저장 완료', data: {'path': savedPath});
              
              // 다운로드 완료 상태 업데이트
              _progressTracker.completeDownload(
                activeDownloadId!,
                success: true,
                message: '다운로드 완료',
                filePath: savedPath,
              );
              
              return true;
            } else {
              _logger.error('Windows에서 파일 저장 실패');
              
              // 다운로드 실패 상태 업데이트
              _progressTracker.completeDownload(
                activeDownloadId!,
                success: false,
                message: '파일을 저장하는 중 오류가 발생했습니다.',
              );
              
              if (showErrors) {
                debugPrint('파일 저장에 실패했습니다.');
              }
              return false;
            }
          } else {
            // 기타 플랫폼에서의 파일 저장
            final filePath = path.join(result, fileName);
            final file = File(filePath);
            
            try {
              await file.writeAsBytes(response.bodyBytes);
              _logger.info('네이티브 환경에서 파일 저장 완료', data: {'path': filePath});
              
              // 다운로드 완료 상태 업데이트
              _progressTracker.completeDownload(
                activeDownloadId!,
                success: true,
                message: '다운로드 완료',
                filePath: filePath,
              );
              
              return true;
            } catch (fileWriteError) {
              _logger.error('파일 쓰기 오류', exception: fileWriteError, data: {
                'path': filePath, 
                'fileName': fileName
              });
              
              // 다운로드 실패 상태 업데이트
              _progressTracker.completeDownload(
                activeDownloadId!,
                success: false,
                message: '파일 쓰기 오류: ${fileWriteError.toString()}',
              );
              
              if (showErrors) {
                debugPrint('파일 쓰기 오류: $fileWriteError');
              }
              return false;
            }
          }
        } catch (pickerError) {
          // FilePicker 관련 오류 처리
          if (Platform.isWindows && (
              pickerError.toString().toLowerCase().contains('symlink') ||
              pickerError.toString().toLowerCase().contains('developer'))) {
            
            _logger.error('Windows 개발자 모드 오류', exception: pickerError, data: {
              'hint': '개발자 모드 활성화 필요'
            });
            
            // 다운로드 실패 상태 업데이트
            _progressTracker.completeDownload(
              activeDownloadId!,
              success: false,
              message: 'Windows 개발자 모드가 필요합니다. 설정을 확인해주세요.',
            );
            
            if (showErrors) {
              debugPrint('Windows 개발자 모드가 필요합니다.');
              debugPrint(WindowsDownloadHelper.getDeveloperModeInstructions());
              
              // 개발자 모드 설정 페이지 열기
              await WindowsDownloadHelper.openDeveloperModeSettings();
            }
          } else {
            _logger.error('파일 저장 위치 선택 오류', exception: pickerError);
            
            // 다운로드 실패 상태 업데이트
            _progressTracker.completeDownload(
              activeDownloadId!,
              success: false,
              message: '파일 저장 위치 선택 중 오류: ${pickerError.toString()}',
            );
            
            if (showErrors) {
              debugPrint('파일 저장 위치 선택 중 오류: $pickerError');
            }
          }
          return false;
        }
      }
    } catch (e) {
      _logger.error('다운로드 처리 중 예외 발생', exception: e, data: {
        'suggestedFileName': suggestedFileName,
        'entityType': entityType,
      });
      
      // 다운로드 ID가 있으면 실패로 마킹
      if (activeDownloadId != null) {
        _progressTracker.completeDownload(
          activeDownloadId,
          success: false,
          message: '다운로드 처리 중 오류: ${e.toString()}',
        );
      }
      
      return false;
    }
  }
  
  /// URL로부터 직접 파일 다운로드
  Future<bool> downloadFromUrl(
    String url, {
    String? suggestedFileName,
    bool showErrors = true,
    String? description,
    int maxRetries = 3,
  }) async {
    // 다운로드 진행상태 시작
    final downloadId = _progressTracker.startDownload(
      fileName: suggestedFileName ?? 'URL 다운로드',
      description: description ?? url,
    );
    
    try {
      _logger.info('URL에서 파일 다운로드', data: {'url': url});
      
      // 재시도 로직 구현
      for (int attempt = 0; attempt < maxRetries; attempt++) {
        try {
          // 다운로드 진행 상태 업데이트
          _progressTracker.updateProgress(
            downloadId,
            message: attempt > 0 ? 'URL 다운로드 재시도 중 (${attempt+1}/$maxRetries)...' : 'URL에서 다운로드 중...',
          );
          
          final response = await http.get(
            Uri.parse(url),
            headers: {'Accept': '*/*'},
          ).timeout(
            const Duration(seconds: 120),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          // 응답 본문 크기 업데이트
          _progressTracker.updateProgress(
            downloadId,
            totalBytes: response.contentLength,
            receivedBytes: response.bodyBytes.length,
          );
          
          final success = await _processDownloadResponse(
            response,
            suggestedFileName: suggestedFileName,
            showErrors: showErrors,
            downloadId: downloadId,
            description: description,
          );
          
          if (success) {
            return true; // 성공하면 재시도 중단
          }
          
          // 마지막 시도가 아니면 재시도 대기
          if (attempt < maxRetries - 1) {
            final delayMs = _retryDelays[math.min(attempt, _retryDelays.length - 1)];
            _progressTracker.updateProgress(
              downloadId,
              message: '다운로드 실패, ${delayMs ~/ 1000}초 후 재시도 예정...',
            );
            await Future.delayed(Duration(milliseconds: delayMs));
          }
        } catch (e) {
          _logger.error('URL 다운로드 시도 중 오류', exception: e, data: {
            'url': url,
            'attempt': attempt + 1,
          });
          
          // 마지막 시도가 아니면 재시도 대기
          if (attempt < maxRetries - 1) {
            final delayMs = _retryDelays[math.min(attempt, _retryDelays.length - 1)];
            _progressTracker.updateProgress(
              downloadId,
              message: '다운로드 오류, ${delayMs ~/ 1000}초 후 재시도 예정: ${e.toString()}',
            );
            await Future.delayed(Duration(milliseconds: delayMs));
          } else {
            // 최대 재시도 횟수 초과
            _progressTracker.completeDownload(
              downloadId,
              success: false,
              message: '최대 재시도 횟수($maxRetries회) 초과, 다운로드 실패',
            );
            return false;
          }
        }
      }
      
      // 모든 시도 실패
      _progressTracker.completeDownload(
        downloadId,
        success: false,
        message: '최대 재시도 횟수($maxRetries회) 초과, 다운로드 실패',
      );
      
      return false;
    } catch (e) {
      _logger.error('URL 다운로드 중 오류', exception: e, data: {'url': url});
      
      _progressTracker.completeDownload(
        downloadId,
        success: false,
        message: '다운로드 중 오류 발생: ${e.toString()}',
      );
      
      return false;
    }
  }
  
  /// 바이너리 데이터를 직접 파일로 저장
  Future<bool> saveBytes(
    List<int> bytes, 
    String fileName, {
    bool showErrors = true,
    String? description,
  }) async {
    final downloadId = _progressTracker.startDownload(
      fileName: fileName,
      totalBytes: bytes.length,
      description: description,
    );
    
    try {
      _logger.info('바이너리 데이터 저장', data: {'fileName': fileName, 'size': bytes.length});
      
      // 파일명 정리
      final sanitizedFileName = FileUtilities.sanitizeFileName(fileName);
      
      // 진행 상태 갱신
      _progressTracker.updateProgress(
        downloadId,
        receivedBytes: bytes.length,
        message: '파일 저장 중...',
      );
      
      // 웹 환경에서는 FileSaver 사용
      if (kIsWeb) {
        final extension = FileUtilities.getExtensionFromFilename(sanitizedFileName);
        await FileSaver.instance.saveFile(
          name: sanitizedFileName.replaceAll('.$extension', ''),
          bytes: Uint8List.fromList(bytes),
          ext: extension,
          mimeType: MimeType.other,
        );
        _logger.info('웹 환경에서 바이너리 데이터 저장 완료', data: {'fileName': sanitizedFileName});
        
        _progressTracker.completeDownload(
          downloadId,
          success: true,
          message: '다운로드 완료',
          filePath: sanitizedFileName,
        );
        
        return true;
      } else {
        // 네이티브 환경에서는 파일로 저장
        try {
          final result = await FilePicker.platform.getDirectoryPath();
          if (result != null) {
            String fullPath;
            bool success = false;
            
            if (Platform.isWindows) {
              // Windows 환경에서는 특수 처리
              final savedPath = await WindowsDownloadHelper.saveWithFallbackFilename(
                Uint8List.fromList(bytes),
                result,
                sanitizedFileName,
              );
              
              if (savedPath != null) {
                fullPath = savedPath;
                success = true;
              } else {
                _progressTracker.completeDownload(
                  downloadId,
                  success: false,
                  message: 'Windows에서 파일 저장 실패',
                );
                return false;
              }
            } else {
              // 다른 플랫폼에서의 저장
              fullPath = path.join(result, sanitizedFileName);
              final file = File(fullPath);
              await file.writeAsBytes(bytes);
              success = true;
            }
            
            if (success) {
              _logger.info('네이티브 환경에서 바이너리 데이터 저장 완료', data: {'path': fullPath});
              
              _progressTracker.completeDownload(
                downloadId,
                success: true,
                message: '다운로드 완료',
                filePath: fullPath,
              );
              
              return true;
            }
          } else {
            _logger.info('파일 저장 위치 선택 취소됨');
            
            _progressTracker.cancelDownload(
              downloadId,
              message: '사용자가 저장 위치 선택을 취소했습니다.',
            );
            
            return false;
          }
        } catch (e) {
          _logger.error('파일 선택기 오류', exception: e);
          
          _progressTracker.completeDownload(
            downloadId,
            success: false,
            message: '파일 저장 중 오류: ${e.toString()}',
          );
          
          if (showErrors) {
            debugPrint('파일 선택기 오류: $e');
          }
          return false;
        }
      }
      
      // 여기까지 도달하면 실패
      _progressTracker.completeDownload(
        downloadId,
        success: false,
        message: '알 수 없는 오류로 저장 실패',
      );
      
      return false;
    } catch (e) {
      _logger.error('바이너리 데이터 저장 중 오류', exception: e, data: {'fileName': fileName});
      
      _progressTracker.completeDownload(
        downloadId,
        success: false,
        message: '저장 중 오류 발생: ${e.toString()}',
      );
      
      return false;
    }
  }
  
  /// 다운로드 진행 상태 추적기 반환
  DownloadProgressTracker get progressTracker => _progressTracker;
} 