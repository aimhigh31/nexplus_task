import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SystemUpdateModel {
  String? id; // MongoDB ObjectId
  final int no;
  final DateTime regDate;
  final String? updateCode;
  final String targetSystem;
  final String developer; // 개발사 추가
  final String description;
  final String updateType;
  final String assignee;
  final String status;
  final DateTime? completionDate;
  final String remarks;
  bool isSaved;
  bool isModified;

  SystemUpdateModel({
    this.id,
    required this.no,
    required this.regDate,
    this.updateCode,
    required this.targetSystem,
    required this.developer, // 개발사 필드 추가
    required this.description,
    required this.updateType,
    required this.assignee,
    required this.status,
    this.completionDate,
    required this.remarks,
    this.isSaved = false,
    this.isModified = false,
  });

  // JSON 직렬화 메서드
  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return {
      'no': no,
      'regDate': dateFormat.format(regDate),
      'updateCode': updateCode,
      'targetSystem': targetSystem,
      'developer': developer, // 개발사 필드 추가
      'description': description.isEmpty ? '내용 없음' : description, // 빈 description 처리
      'updateType': updateType,
      'assignee': assignee.isEmpty ? '미지정' : assignee, // 빈 assignee 처리
      'status': status,
      'completionDate': completionDate != null ? dateFormat.format(completionDate!) : null,
      'remarks': remarks,
      'isSaved': isSaved,
      'isModified': isModified,
    };
  }

  // JSON 역직렬화 팩토리 메서드
  factory SystemUpdateModel.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return SystemUpdateModel(
      id: json['_id'] ?? json['id'],
      no: json['no'],
      regDate: json['regDate'] is String
          ? dateFormat.parse(json['regDate'])
          : DateTime.parse(json['regDate'].toString()),
      updateCode: json['updateCode'],
      targetSystem: json['targetSystem'],
      developer: json['developer'] ?? '건솔루션', // 개발사 필드 기본값 설정
      description: json['description'] ?? '내용 없음', // description 기본값 설정
      updateType: json['updateType'],
      assignee: json['assignee'] ?? '미지정', // assignee 기본값 설정
      status: json['status'],
      completionDate: json['completionDate'] == null
          ? null
          : json['completionDate'] is String
              ? dateFormat.parse(json['completionDate'])
              : DateTime.parse(json['completionDate'].toString()),
      remarks: json['remarks'] ?? '',
      isSaved: json['isSaved'] ?? false,
      isModified: json['isModified'] ?? false,
    );
  }

  // 복사 객체 생성 메서드
  SystemUpdateModel copyWith({
    String? id,
    int? no,
    DateTime? regDate,
    String? updateCode,
    String? targetSystem,
    String? developer, // 개발사 필드 추가
    String? description,
    String? updateType,
    String? assignee,
    String? status,
    DateTime? completionDate,
    String? remarks,
    bool? isSaved,
    bool? isModified,
    bool clearCompletionDate = false,
  }) {
    return SystemUpdateModel(
      id: id ?? this.id,
      no: no ?? this.no,
      regDate: regDate ?? this.regDate,
      updateCode: updateCode ?? this.updateCode,
      targetSystem: targetSystem ?? this.targetSystem,
      developer: developer ?? this.developer, // 개발사 필드 추가
      description: description ?? this.description,
      updateType: updateType ?? this.updateType,
      assignee: assignee ?? this.assignee,
      status: status ?? this.status,
      completionDate: clearCompletionDate ? null : completionDate ?? this.completionDate,
      remarks: remarks ?? this.remarks,
      isSaved: isSaved ?? this.isSaved,
      isModified: isModified ?? this.isModified,
    );
  }
} 