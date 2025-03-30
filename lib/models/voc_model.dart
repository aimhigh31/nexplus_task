import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class VocModel {
  final String? id; // MongoDB ID (String으로 변경)
  final int no;
  final DateTime regDate;
  final String? code; // VOC 코드 (자동 생성, 수정 불가)
  final String vocCategory;  // VOC 분류 추가
  final String requestDept;
  final String requester;
  final String systemPath;
  final String request;
  final String requestType;
  final String action;
  final String actionTeam;
  final String actionPerson;
  final String status;
  final DateTime dueDate;
  final bool isSaved; // 서버에 저장되었는지 여부
  final bool isModified; // 저장된 후 수정되었는지 여부

  const VocModel({
    this.id,
    required this.no,
    required this.regDate,
    this.code,
    required this.vocCategory,
    required this.requestDept,
    required this.requester,
    required this.systemPath,
    required this.request,
    required this.requestType,
    required this.action,
    required this.actionTeam,
    required this.actionPerson,
    required this.status,
    required this.dueDate,
    this.isSaved = true,
    this.isModified = false,
  });

  // JSON에서 VocModel로 변환
  factory VocModel.fromJson(Map<String, dynamic> json) {
    return VocModel(
      id: json['_id']?.toString(),
      no: json['no'] as int,
      regDate: json['regDate'] is String 
          ? DateTime.parse(json['regDate']) 
          : json['regDate'] as DateTime,
      code: json['code'] as String?,
      vocCategory: json['vocCategory'] as String,
      requestDept: json['requestDept'] as String,
      requester: json['requester'] as String,
      systemPath: json['systemPath'] as String,
      request: json['request'] as String,
      requestType: json['requestType'] as String,
      action: json['action'] as String,
      actionTeam: json['actionTeam'] as String,
      actionPerson: json['actionPerson'] as String,
      status: json['status'] as String,
      dueDate: json['dueDate'] is String 
          ? DateTime.parse(json['dueDate']) 
          : json['dueDate'] as DateTime,
      isSaved: true, // API에서 불러온 데이터는 저장된 상태
      isModified: false, // API에서 불러온 데이터는 수정되지 않은 상태
    );
  }

  // VocModel에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    
    final Map<String, dynamic> data = {
      'no': no,
      'regDate': formatter.format(regDate),
      'vocCategory': vocCategory,
      'requestDept': requestDept,
      'requester': requester,
      'systemPath': systemPath,
      'request': request,
      'requestType': requestType,
      'action': action,
      'actionTeam': actionTeam,
      'actionPerson': actionPerson,
      'status': status,
      'dueDate': formatter.format(dueDate),
    };
    
    // Null이 아닌 경우만 추가
    if (id != null) {
      data['_id'] = id;
    }
    
    if (code != null && code!.isNotEmpty) {
      data['code'] = code;
    }
    
    return data;
  }

  // 복사본 생성 (필드 업데이트 가능)
  VocModel copyWith({
    String? id,
    int? no,
    DateTime? regDate,
    String? code,
    String? vocCategory,
    String? requestDept,
    String? requester,
    String? systemPath,
    String? request,
    String? requestType,
    String? action,
    String? actionTeam,
    String? actionPerson,
    String? status,
    DateTime? dueDate,
    bool? isSaved,
    bool? isModified,
  }) {
    return VocModel(
      id: id ?? this.id,
      no: no ?? this.no,
      regDate: regDate ?? this.regDate,
      code: code ?? this.code,
      vocCategory: vocCategory ?? this.vocCategory,
      requestDept: requestDept ?? this.requestDept,
      requester: requester ?? this.requester,
      systemPath: systemPath ?? this.systemPath,
      request: request ?? this.request,
      requestType: requestType ?? this.requestType,
      action: action ?? this.action,
      actionTeam: actionTeam ?? this.actionTeam,
      actionPerson: actionPerson ?? this.actionPerson,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      isSaved: isSaved ?? this.isSaved,
      isModified: isModified ?? this.isModified,
    );
  }
  
  // VOC 코드 생성 (년월 + 일련번호)
  static String generateVocCode(DateTime date, int sequenceNumber) {
    final year = date.year.toString().substring(2); // 2자리 연도
    final month = date.month.toString().padLeft(2, '0'); // 2자리 월
    final sequence = sequenceNumber.toString().padLeft(3, '0'); // 3자리 일련번호
    
    return 'VOC$year$month$sequence';
  }
} 