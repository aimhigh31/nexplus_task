import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HardwareModel {
  final int no;
  final DateTime regDate;
  final String? code;
  final String assetCode;
  final String assetName;
  final String specification;
  final String executionType;
  final int quantity;
  final String lotCode;
  final String detail;
  final String remarks;
  final bool isSaved;
  final bool isModified;
  final String? id;

  HardwareModel({
    required this.no,
    required this.regDate,
    this.code,
    required this.assetCode,
    required this.assetName,
    required this.specification,
    required this.executionType,
    required this.quantity,
    required this.lotCode,
    required this.detail,
    required this.remarks,
    this.isSaved = false,
    this.isModified = false,
    this.id,
  });

  // JSON 변환 메소드
  factory HardwareModel.fromJson(Map<String, dynamic> json) {
    return HardwareModel(
      id: json['_id'] as String?,
      no: json['no'] as int,
      regDate: DateTime.parse(json['regDate'] as String),
      code: json['code'] as String?,
      assetCode: json['assetCode'] as String,
      assetName: json['assetName'] as String,
      specification: json['specification'] as String,
      executionType: json['executionType'] as String,
      quantity: json['quantity'] as int,
      lotCode: json['lotCode'] as String,
      detail: json['detail'] as String,
      remarks: json['remarks'] as String,
      isSaved: json['isSaved'] as bool? ?? false,
      isModified: json['isModified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'no': no,
      'regDate': DateFormat('yyyy-MM-dd').format(regDate),
      'code': code,
      'assetCode': assetCode,
      'assetName': assetName,
      'specification': specification,
      'executionType': executionType,
      'quantity': quantity,
      'lotCode': lotCode,
      'detail': detail,
      'remarks': remarks,
      'isSaved': isSaved,
      'isModified': isModified,
    };
    
    if (id != null) {
      data['_id'] = id;
    }
    
    return data;
  }

  // 하드웨어 코드 생성
  static String generateHardwareCode(DateTime date, int no) {
    final dateStr = DateFormat('yyMMdd').format(date);
    final numStr = no.toString().padLeft(4, '0');
    return 'HW$dateStr-$numStr';
  }

  // 복사본 생성 (필드 수정용)
  HardwareModel copyWith({
    int? no,
    DateTime? regDate,
    String? code,
    String? assetCode,
    String? assetName,
    String? specification,
    String? executionType,
    int? quantity,
    String? lotCode,
    String? detail,
    String? remarks,
    bool? isSaved,
    bool? isModified,
    String? id,
  }) {
    return HardwareModel(
      no: no ?? this.no,
      regDate: regDate ?? this.regDate,
      code: code ?? this.code,
      assetCode: assetCode ?? this.assetCode,
      assetName: assetName ?? this.assetName,
      specification: specification ?? this.specification,
      executionType: executionType ?? this.executionType,
      quantity: quantity ?? this.quantity,
      lotCode: lotCode ?? this.lotCode,
      detail: detail ?? this.detail,
      remarks: remarks ?? this.remarks,
      isSaved: isSaved ?? this.isSaved,
      isModified: isModified ?? this.isModified,
      id: id ?? this.id,
    );
  }
} 