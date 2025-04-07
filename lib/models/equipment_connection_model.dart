import 'package:flutter/material.dart';

class EquipmentConnectionModel {
  final int no;
  final DateTime regDate;
  final String? code;
  final String line;
  final String equipment;
  final String workType;
  final String dataType;
  final String connectionType;
  final String status;
  final String detail;
  final DateTime? startDate;
  final DateTime? completionDate;
  final String remarks;
  final bool isModified;
  final bool isNew;

  EquipmentConnectionModel({
    required this.no,
    required this.regDate,
    this.code,
    required this.line,
    required this.equipment,
    required this.workType,
    required this.dataType,
    required this.connectionType,
    required this.status,
    required this.detail,
    this.startDate,
    this.completionDate,
    this.remarks = '',
    this.isModified = false,
    this.isNew = false,
  });

  EquipmentConnectionModel copyWith({
    int? no,
    DateTime? regDate,
    String? code,
    String? line,
    String? equipment,
    String? workType,
    String? dataType,
    String? connectionType,
    String? status,
    String? detail,
    DateTime? startDate,
    DateTime? completionDate,
    String? remarks,
    bool? isModified,
    bool? isNew,
  }) {
    return EquipmentConnectionModel(
      no: no ?? this.no,
      regDate: regDate ?? this.regDate,
      code: code ?? this.code,
      line: line ?? this.line,
      equipment: equipment ?? this.equipment,
      workType: workType ?? this.workType,
      dataType: dataType ?? this.dataType,
      connectionType: connectionType ?? this.connectionType,
      status: status ?? this.status,
      detail: detail ?? this.detail,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      remarks: remarks ?? this.remarks,
      isModified: isModified ?? this.isModified,
      isNew: isNew ?? this.isNew,
    );
  }

  factory EquipmentConnectionModel.fromJson(Map<String, dynamic> json) {
    return EquipmentConnectionModel(
      no: json['no'] ?? 0,
      regDate: json['regDate'] != null ? DateTime.parse(json['regDate']) : DateTime.now(),
      code: json['code'],
      line: json['line'] ?? '',
      equipment: json['equipment'] ?? '',
      workType: json['workType'] ?? '',
      dataType: json['dataType'] ?? '',
      connectionType: json['connectionType'] ?? '',
      status: json['status'] ?? '',
      detail: json['detail'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate']) : null,
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'regDate': regDate.toIso8601String(),
      'code': code,
      'line': line,
      'equipment': equipment,
      'workType': workType,
      'dataType': dataType,
      'connectionType': connectionType,
      'status': status,
      'detail': detail,
      'startDate': startDate?.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'remarks': remarks,
    };
  }

  // 작업유형 목록
  static List<String> workTypes = [
    'MES자동실적',
    'MES자동투입',
    'SPC',
    '설비조건데이터',
  ];

  // 데이터유형 목록
  static List<String> dataTypes = [
    'CSV',
    'PLC',
  ];

  // 연동유형 목록
  static List<String> connectionTypes = [
    'DataAgent',
    'X-DAS',
    'X-SCADA',
  ];

  // 상태 목록
  static List<String> statusTypes = [
    '대기',
    '진행중',
    '완료',
    '중단',
  ];
} 