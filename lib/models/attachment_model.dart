import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 첨부파일 모델 클래스
class AttachmentModel {
  final String? id;
  final String fileName;
  final String originalFilename;
  final int size;
  final String mimeType;
  final DateTime uploadDate;
  final String? uploaderId;
  final String? uploaderName;
  final String relatedEntityId; // 연결된 항목의 ID (ex: 시스템 업데이트의 ID)
  final String relatedEntityType; // 관련 엔티티 유형 (ex: 'system_update')

  AttachmentModel({
    this.id,
    required this.fileName,
    required this.originalFilename,
    required this.size,
    required this.mimeType,
    required this.uploadDate,
    this.uploaderId,
    this.uploaderName,
    required this.relatedEntityId,
    required this.relatedEntityType,
  });

  // JSON 직렬화 메서드
  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    return {
      'id': id,
      'fileName': fileName,
      'originalFilename': originalFilename,
      'size': size,
      'mimeType': mimeType,
      'uploadDate': dateFormat.format(uploadDate),
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
    };
  }

  // JSON 역직렬화 팩토리 메서드
  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    return AttachmentModel(
      id: json['_id'] ?? json['id'],
      fileName: json['fileName'] ?? json['filename'] ?? 'unknown',
      originalFilename: json['originalFilename'] ?? json['fileName'] ?? json['filename'] ?? 'unknown',
      size: _parseSize(json),
      mimeType: json['mimeType'] ?? 'application/octet-stream',
      uploadDate: _parseDate(json, dateFormat),
      uploaderId: json['uploaderId'],
      uploaderName: json['uploaderName'],
      relatedEntityId: json['relatedEntityId'] ?? '',
      relatedEntityType: json['relatedEntityType'] ?? '',
    );
  }

  // 크기 파싱 헬퍼 메서드
  static int _parseSize(Map<String, dynamic> json) {
    if (json.containsKey('size')) {
      return json['size'] is int ? json['size'] : int.tryParse(json['size'].toString()) ?? 0;
    } else if (json.containsKey('fileSize')) {
      return json['fileSize'] is int ? json['fileSize'] : int.tryParse(json['fileSize'].toString()) ?? 0;
    }
    return 0;
  }

  // 날짜 파싱 헬퍼 메서드
  static DateTime _parseDate(Map<String, dynamic> json, DateFormat dateFormat) {
    try {
      if (json.containsKey('uploadDate')) {
        if (json['uploadDate'] is String) {
          try {
            return dateFormat.parse(json['uploadDate']);
          } catch (e) {
            return DateTime.parse(json['uploadDate']);
          }
        } else {
          return DateTime.parse(json['uploadDate'].toString());
        }
      }
    } catch (e) {
      debugPrint('날짜 파싱 오류: $e');
    }
    return DateTime.now();
  }

  // 파일 크기 포맷팅
  String getFormattedSize() {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // 파일 타입에 따른 아이콘 반환
  IconData getFileIcon() {
    if (mimeType.startsWith('image/')) {
      return Icons.image;
    } else if (mimeType.startsWith('video/')) {
      return Icons.video_file;
    } else if (mimeType.startsWith('audio/')) {
      return Icons.audio_file;
    } else if (mimeType == 'application/pdf') {
      return Icons.picture_as_pdf;
    } else if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) {
      return Icons.table_chart;
    } else if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description;
    } else if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) {
      return Icons.slideshow;
    } else if (mimeType.contains('zip') || mimeType.contains('rar') || mimeType.contains('tar') || mimeType.contains('gz')) {
      return Icons.folder_zip;
    } else {
      return Icons.insert_drive_file;
    }
  }

  // 파일 확장자 반환
  String getFileExtension() {
    return originalFilename.contains('.')
        ? originalFilename.split('.').last.toUpperCase()
        : '';
  }
} 