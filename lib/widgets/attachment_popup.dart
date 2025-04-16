import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../models/attachment_model.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show latin1;

/// 첨부파일 팝업 위젯
class AttachmentPopup extends StatefulWidget {
  final String entityId; // 연결된 항목 ID (시스템 업데이트 ID 등)
  final String entityType; // 엔티티 타입 (예: 'system_update')
  final String entityName; // 엔티티 이름 (예: '시스템 업데이트')

  const AttachmentPopup({
    Key? key,
    required this.entityId,
    required this.entityType,
    required this.entityName,
  }) : super(key: key);

  @override
  State<AttachmentPopup> createState() => _AttachmentPopupState();
}

class _AttachmentPopupState extends State<AttachmentPopup> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isUploading = false;
  List<AttachmentModel> _attachments = [];
  List<PlatformFile> _selectedFiles = [];
  String? _errorMessage;
  final Set<String> _selectedAttachments = {};
  bool _hasSelectedAttachments = false;

  final RegExp filenameRegex = RegExp(r'filename[^;=\n]*=([\"]?)([^\";]*)\1');

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  // 첨부파일 목록 로드
  Future<void> _loadAttachments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('첨부파일 목록 로드 시작 - 엔티티ID: ${widget.entityId}, 엔티티타입: ${widget.entityType}');
      final attachments = await _apiService.getAttachments(
        entityId: widget.entityId,
        entityType: widget.entityType,
      );

      if (mounted) {
        // 첨부파일 모델의 originalFilename 필드를 최대한 그대로 사용
        setState(() {
          _attachments = attachments; // 서버에서 받은 데이터를 그대로 사용
          _isLoading = false;
        });
        debugPrint('첨부파일 목록 로드 완료 - ${attachments.length}개 항목');
        // 디버깅을 위해 로드된 파일명 출력
        for (var att in attachments) {
           debugPrint('로드된 파일명: ${att.originalFilename} (ID: ${att.id})');
        }
      }
    } catch (e) {
      debugPrint('첨부파일 목록 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '첨부파일을 로드하는 중 오류가 발생했습니다: $e';
          _isLoading = false;
          _attachments = [];
        });
      }
    }
  }

  // Mojibake (깨진 한글) 복구 시도 함수 (실패 시 표시 추가)
  String _tryDecodeMojibake(String input) {
    final mojibakePattern = RegExp(r'[âãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ]{2,}');
    const replacementChar = '\uFFFD'; // 유니코드 대체 문자

    if (mojibakePattern.hasMatch(input)) {
      try {
        final bytes = latin1.encode(input);
        // UTF-8 디코딩 (allowMalformed: false 로 설정하여 깨진 문자가 있으면 에러 발생 또는 대체 문자로 변환되도록 유도)
        final decoded = utf8.decode(bytes, allowMalformed: true); 

        // 복구 시도 후에도 여전히 패턴이 존재하거나, 대체 문자가 포함된 경우
        if (decoded == input || // 변환이 안 됐거나
            mojibakePattern.hasMatch(decoded) || // 변환 후에도 패턴이 있거나
            decoded.contains(replacementChar)) { // 대체 문자가 포함된 경우
              
          debugPrint('Mojibake 복구 실패 또는 불완전: "$input" -> "$decoded"');
          // 원본 문자열에 오류 표시 추가하여 반환
          return '$input (표시 오류)'; 
        } else {
          // 성공적으로 복구된 것으로 간주
          debugPrint('Mojibake 복구 성공: "$input" -> "$decoded"');
          return decoded;
        }
      } catch (e) {
        debugPrint('Mojibake 디코딩 중 오류: $e, 원본 반환: "$input"');
        // 디코딩 자체에서 오류 발생 시 원본에 오류 표시 추가
         return '$input (표시 오류)';
      }
    }
    // Mojibake 패턴이 없으면 원본 그대로 반환
    return input;
  }

  // 파일 선택
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('파일 선택 취소됨');
        return;
      }

      setState(() {
        _selectedFiles = result.files;
      });
      
      debugPrint('${_selectedFiles.length}개 파일 선택됨:');
      for (var file in _selectedFiles) {
        debugPrint('- ${file.name} (${(file.size / 1024).toStringAsFixed(2)} KB)');
      }
    } catch (e) {
      debugPrint('파일 선택 중 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 선택한 파일 업로드
  Future<void> _uploadSelectedFiles() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택된 파일이 없습니다. 파일을 먼저 선택해주세요.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      int successCount = 0;
      List<String> failedFiles = [];
      
      for (var file in _selectedFiles) {
        try {
          debugPrint('파일 업로드 시도: ${file.name}'); // 원본 파일명 로그 제거 또는 단순화
          
          // 파일명 인코딩 확인 로직 제거
          // final String originalFilename = file.name;
          // if (_isLikelyKorean(originalFilename)) {
          //   debugPrint('한글 포함 파일명 감지: $originalFilename');
          // }
          
          if (file.bytes != null) {
            // 웹 환경에서는 바이트로 접근
            // 용량 체크 추가
            final fileSizeInMB = file.bytes!.length / (1024 * 1024);
            if (fileSizeInMB > 10) {
              debugPrint('파일 크기 초과: ${file.name}, ${fileSizeInMB.toStringAsFixed(2)}MB (최대 10MB)');
              failedFiles.add('${file.name} (크기 초과: ${fileSizeInMB.toStringAsFixed(2)}MB)');
              continue;
            }
            
            // 파일 업로드 시 원본 파일명 전달 명시
            final result = await _uploadFile(
              fileName: file.name,
              fileBytes: file.bytes!,
            );
            
            if (result != null) {
              successCount++;
              debugPrint('파일 업로드 성공: ${file.name} (ID: ${result.id})');
            } else {
              failedFiles.add(file.name);
              debugPrint('파일 업로드 실패: ${file.name}');
            }
          } else if (file.path != null) {
            // 네이티브 환경에서는 경로로 접근
            // 파일 용량 확인
            final fileObj = File(file.path!);
            final fileSize = await fileObj.length();
            final fileSizeInMB = fileSize / (1024 * 1024);
            
            if (fileSizeInMB > 10) {
              debugPrint('파일 크기 초과: ${file.name}, ${fileSizeInMB.toStringAsFixed(2)}MB (최대 10MB)');
              failedFiles.add('${file.name} (크기 초과: ${fileSizeInMB.toStringAsFixed(2)}MB)');
              continue;
            }
            
            // 원본 파일명도 함께 전달
            final result = await _apiService.uploadFileFromPath(
              filePath: file.path!,
              fileName: file.name,
              entityId: widget.entityId,
              entityType: widget.entityType,
            );
            
            if (result != null) {
              successCount++;
              debugPrint('파일 업로드 성공: ${file.name} (ID: ${result.id})');
            } else {
              failedFiles.add(file.name);
              debugPrint('파일 업로드 실패: ${file.name}');
            }
          } else {
            failedFiles.add('${file.name} (파일 데이터 없음)');
            debugPrint('파일 데이터 누락: ${file.name}');
          }
        } catch (fileError) {
          failedFiles.add('${file.name} (${fileError.toString().split('\n').first})');
          debugPrint('파일 업로드 중 오류: $fileError');
        }
      }

      // 파일 목록 초기화
      setState(() {
        _selectedFiles = [];
      });

      // 업로드 결과 메시지 생성
      String resultMessage;
      if (successCount > 0) {
        resultMessage = '$successCount개 파일 업로드 완료';
        if (failedFiles.isNotEmpty) {
          resultMessage += ', ${failedFiles.length}개 파일 실패';
          
          // 실패 세부 정보 에러 메시지에 표시
          setState(() {
            _errorMessage = '업로드 실패한 파일:\n${failedFiles.join('\n')}';
          });
        }
      } else if (failedFiles.isNotEmpty) {
        resultMessage = '모든 파일 업로드 실패';
        setState(() {
          _errorMessage = '업로드 실패한 파일:\n${failedFiles.join('\n')}';
        });
      } else {
        resultMessage = '업로드 실패: 알 수 없는 오류';
        setState(() {
          _errorMessage = '업로드 처리 중 오류가 발생했습니다.';
        });
      }

      // 업로드 완료 후 목록 새로고침 (성공 여부와 관계없이)
      await _loadAttachments();

      // 완료 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultMessage)),
        );
      }
    } catch (e) {
      debugPrint('업로드 프로세스 중 오류 발생: $e');
      setState(() {
        _errorMessage = '파일 업로드 중 오류가 발생했습니다: $e';
      });
      // 오류 발생 시에도 목록 새로고침
      await _loadAttachments();
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // 바이트 데이터로 파일 업로드
  Future<AttachmentModel?> _uploadFile({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      debugPrint('파일 업로드 시작: $fileName - 크기: ${(fileBytes.length / 1024).toStringAsFixed(2)} KB');
      
      // 업로드 제한사항 체크 (10MB)
      final fileSizeInMB = fileBytes.length / (1024 * 1024);
      if (fileSizeInMB > 10) {
        debugPrint('파일 크기 제한 초과: ${fileSizeInMB.toStringAsFixed(2)}MB (최대 10MB)');
        throw Exception('파일 크기가 10MB를 초과합니다: ${fileSizeInMB.toStringAsFixed(2)}MB');
      }
      
      // 이미 같은 이름의 파일이 있는지 확인
      final existingFile = _attachments.where((attachment) => 
        attachment.originalFilename.toLowerCase() == fileName.toLowerCase()).toList();
      
      if (existingFile.isNotEmpty) {
        // 기존 파일이 있으면 경고
        debugPrint('동일한 이름의 파일이 이미 존재함: $fileName');
        
        // 확인 대화상자 표시
        final shouldReplace = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('파일 중복'),
            content: Text('$fileName 파일이 이미 존재합니다. 덮어쓰시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('덮어쓰기', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ?? false;
        
        if (!shouldReplace) {
          debugPrint('사용자가 파일 덮어쓰기를 취소함');
          return existingFile.first; // 기존 파일 정보 반환
        }
        
        // 덮어쓰기 선택 시 기존 파일 삭제 후 진행
        if (existingFile.first.id != null) {
          debugPrint('기존 파일 삭제 후 덮어쓰기: ${existingFile.first.id}');
          await _apiService.deleteAttachment(existingFile.first.id!);
        }
      }
      
      // 원본 파일명을 명시적으로 전달
      final result = await _apiService.uploadFile(
        fileBytes: fileBytes,
        fileName: fileName,
        entityId: widget.entityId,
        entityType: widget.entityType,
      );
      
      if (result != null) {
        debugPrint('파일 업로드 성공: ${result.originalFilename} (ID: ${result.id})');
        return result;
      } else {
        debugPrint('파일 업로드 실패: API에서 null 반환');
        return null;
      }
    } catch (e) {
      debugPrint('파일 업로드 실패: $e');
      rethrow; // 상위 메서드에서 오류 처리하도록 다시 던짐
    }
  }

  // 파일 확장자로부터 MIME 타입 추론
  String _getMimeTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  // 파일 다운로드 처리
  Future<void> _downloadFile(AttachmentModel attachment) async {
    try {
      setState(() => _isLoading = true);
      
      if (attachment.id == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('파일 ID가 없어 다운로드할 수 없습니다'))
          );
        }
        return;
      }

      // 복구 시도된 파일명
      final displayFilename = _tryDecodeMojibake(attachment.originalFilename);

      // 로컬 또는 임시 첨부파일 확인
      if (attachment.id!.startsWith('local_') || attachment.id!.startsWith('temp_')) {
        setState(() => _isLoading = false);
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('다운로드 불가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$displayFilename 파일은 로컬에만 저장된 임시 파일입니다.'),
                  const SizedBox(height: 12),
                  const Text('항목을 저장한 후에 다운로드가 가능합니다.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        }
        return;
      }
      
      // 다운로드 시작 안내
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                Text('$displayFilename 다운로드 중...'),
              ],
            ),
            duration: const Duration(seconds: 1),
          )
        );
      }
      
      // 파일명 처리 - 복구 시도된 파일명을 사용
      String suggestedFilename = displayFilename;
      
      debugPrint('첨부파일 다운로드 시작: ${attachment.id} - suggestedFileName: $suggestedFilename');
      final success = await _apiService.downloadAttachment(
        attachment.id!,
        suggestedFileName: suggestedFilename, // 복구 시도된 파일명 전달
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        if (success) {
          // 다운로드 성공 안내
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$suggestedFilename 다운로드 완료'))
          );
        } else {
          // 다운로드 실패 시 사용자에게 상세 안내
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('다운로드 실패'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$suggestedFilename 파일을 다운로드하지 못했습니다.'),
                  const SizedBox(height: 12),
                  const Text('가능한 해결 방법:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('• 인터넷 연결을 확인해주세요'),
                  const Text('• 서버 관리자에게 파일 유효성을 확인해주세요'),
                  const Text('• 잠시 후 다시 시도해주세요'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _downloadFile(attachment); // 다시 시도
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('첨부파일 다운로드 처리 중 예외 발생: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('다운로드 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }

  // 선택된 파일 삭제
  Future<void> _deleteSelectedFiles() async {
    if (_selectedAttachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제할 파일을 선택해주세요')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('파일 삭제 확인'),
        content: Text('선택한 ${_selectedAttachments.length}개 파일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      int successCount = 0;
      List<String> failedFilesDisplay = []; // 복구 시도된 파일명 저장용

      for (final attachmentId in _selectedAttachments) {
        AttachmentModel? attachment;
        try {
          attachment = _attachments.firstWhere((a) => a.id == attachmentId);
          final success = await _apiService.deleteAttachment(attachmentId);
          if (success) {
            successCount++;
          } else {
            failedFilesDisplay.add(_tryDecodeMojibake(attachment.originalFilename));
          }
        } catch (e) {
          debugPrint('파일 삭제 중 오류: $e');
          if (attachment != null) {
             failedFilesDisplay.add(_tryDecodeMojibake(attachment.originalFilename));
          }
        }
      }

      setState(() {
        _selectedAttachments.clear();
        _hasSelectedAttachments = false;
      });

      await _loadAttachments();

      String message = '파일 삭제 완료: $successCount개 삭제됨';
      if (failedFilesDisplay.isNotEmpty) {
        message += '\n삭제 실패: ${failedFilesDisplay.join(', ')}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '파일 삭제 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 개별 파일 삭제
  Future<void> _deleteFile(AttachmentModel attachment) async {
    final displayFilename = _tryDecodeMojibake(attachment.originalFilename);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('파일 삭제'),
        content: Text('$displayFilename 파일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (attachment.id == null) {
        throw Exception('파일 ID가 없습니다');
      }
      
      await _apiService.deleteAttachment(attachment.id!);
      await _loadAttachments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$displayFilename 삭제 완료')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '파일 삭제 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 체크박스 상태 변경 처리
  void _handleCheckboxChanged(String attachmentId, bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedAttachments.add(attachmentId);
      } else {
        _selectedAttachments.remove(attachmentId);
      }
      _hasSelectedAttachments = _selectedAttachments.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 700,
          maxHeight: 700,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${widget.entityName} 첨부파일',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              
              // 파일 업로드 섹션
              Row(
                children: [
                  // 파일 선택 버튼
                  ElevatedButton.icon(
                    icon: const Icon(Icons.file_upload),
                    label: const Text('파일 선택'),
                    onPressed: _isUploading ? null : _pickFiles,
                  ),
                  const SizedBox(width: 12),
                  
                  // 업로드 버튼
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('업로드'),
                    onPressed: _isUploading || _selectedFiles.isEmpty ? null : _uploadSelectedFiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 파일 삭제 버튼
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: Text('선택 삭제${_hasSelectedAttachments ? ' (${_selectedAttachments.length})' : ''}'),
                    onPressed: _hasSelectedAttachments ? _deleteSelectedFiles : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // 로딩 인디케이터
                  if (_isUploading)
                    Row(
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('업로드 중...'),
                      ],
                    ),
                ],
              ),
              
              // 선택된 파일 목록
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '선택된 파일 (${_selectedFiles.length}개)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 80),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _selectedFiles.length,
                          itemBuilder: (context, index) {
                            final file = _selectedFiles[index];
                            return Text(
                              '${index + 1}. ${file.name} (${_formatFileSize(file.size)})',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              Text(
                '최대 파일 크기: 10MB, 허용 형식: 모든 파일',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              
              // 오류 메시지 영역
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _errorMessage = null),
                      ),
                    ],
                  ),
                ),
              
              // 첨부파일 목록 헤더
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '첨부파일 목록',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_attachments.isNotEmpty)
                      Text(
                        '총 ${_attachments.length}개 파일',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              
              // 첨부파일 목록
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _attachments.isEmpty
                        ? _buildEmptyState()
                        : _buildAttachmentList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attachment, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '첨부된 파일이 없습니다',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentList() {
    return ListView.separated(
      itemCount: _attachments.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final attachment = _attachments[index];
        final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
        final isSelected = attachment.id != null && _selectedAttachments.contains(attachment.id);
        
        // Mojibake 복구 시도 및 오류 표시 적용
        final displayFilename = _tryDecodeMojibake(attachment.originalFilename);
        
        // 오류 표시가 포함된 경우 텍스트 색상 변경
        final bool hasDisplayError = displayFilename.endsWith('(표시 오류)');
        final TextStyle titleStyle = TextStyle(
          fontSize: 14,
          color: hasDisplayError ? Colors.red : null, // 오류 시 빨간색
          fontStyle: hasDisplayError ? FontStyle.italic : null,
        );

        return ListTile(
          leading: Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              if (attachment.id != null) {
                 _handleCheckboxChanged(attachment.id!, value);
              }
            },
          ),
          title: Text(
            displayFilename, // 복구 시도/오류 표시된 파일명
            style: titleStyle, // 스타일 적용
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${attachment.getFormattedSize()}  ·  ${dateFormat.format(attachment.uploadDate)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.download, color: Colors.blue),
                tooltip: '다운로드',
                onPressed: () => _downloadFile(attachment),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                tooltip: '삭제',
                onPressed: () => _deleteFile(attachment),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 파일 크기 형식화
  String _formatFileSize(int sizeInBytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = sizeInBytes.toDouble();
    
    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }
} 