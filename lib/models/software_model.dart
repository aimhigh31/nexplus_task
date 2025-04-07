import 'package:flutter/material.dart';

class SoftwareModel {
  final int no;
  final String? code;
  final DateTime regDate;
  final String assetCode;
  final String assetName;
  final String specification;
  final String executionType;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String lotCode;
  final String detail;
  final DateTime? contractStartDate;
  final DateTime? contractEndDate;
  final String remarks;
  final bool isModified;
  final bool isSaved;

  SoftwareModel({
    required this.no,
    this.code,
    required this.regDate,
    required this.assetCode,
    required this.assetName,
    required this.specification,
    required this.executionType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.lotCode,
    required this.detail,
    this.contractStartDate,
    this.contractEndDate,
    required this.remarks,
    this.isModified = false,
    this.isSaved = false,
  });

  // JSON 변환 메서드
  factory SoftwareModel.fromJson(Map<String, dynamic> json) {
    return SoftwareModel(
      no: json['no'] ?? 0,
      code: json['code'],
      regDate: json['regDate'] != null
          ? DateTime.parse(json['regDate'])
          : DateTime.now(),
      assetCode: json['assetCode'] ?? '',
      assetName: json['assetName'] ?? '',
      specification: json['specification'] ?? '',
      executionType: json['executionType'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: json['unitPrice'] != null
          ? double.parse(json['unitPrice'].toString())
          : 0.0,
      totalPrice: json['totalPrice'] != null
          ? double.parse(json['totalPrice'].toString())
          : 0.0,
      lotCode: json['lotCode'] ?? '',
      detail: json['detail'] ?? '',
      contractStartDate: json['contractStartDate'] != null
          ? DateTime.parse(json['contractStartDate'])
          : null,
      contractEndDate: json['contractEndDate'] != null
          ? DateTime.parse(json['contractEndDate'])
          : null,
      remarks: json['remarks'] ?? '',
      isSaved: json['isSaved'] ?? true,
      isModified: json['isModified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'code': code,
      'regDate': regDate.toIso8601String(),
      'assetCode': assetCode,
      'assetName': assetName,
      'specification': specification,
      'executionType': executionType,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'lotCode': lotCode,
      'detail': detail,
      'contractStartDate': contractStartDate?.toIso8601String(),
      'contractEndDate': contractEndDate?.toIso8601String(),
      'remarks': remarks,
      'isSaved': isSaved,
      'isModified': isModified,
    };
  }

  // 복사본 생성 메서드
  SoftwareModel copyWith({
    int? no,
    String? code,
    DateTime? regDate,
    String? assetCode,
    String? assetName,
    String? specification,
    String? executionType,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? lotCode,
    String? detail,
    DateTime? contractStartDate,
    DateTime? contractEndDate,
    String? remarks,
    bool? isModified,
    bool? isSaved,
  }) {
    return SoftwareModel(
      no: no ?? this.no,
      code: code ?? this.code,
      regDate: regDate ?? this.regDate,
      assetCode: assetCode ?? this.assetCode,
      assetName: assetName ?? this.assetName,
      specification: specification ?? this.specification,
      executionType: executionType ?? this.executionType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      lotCode: lotCode ?? this.lotCode,
      detail: detail ?? this.detail,
      contractStartDate: contractStartDate ?? this.contractStartDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      remarks: remarks ?? this.remarks,
      isModified: isModified ?? this.isModified,
      isSaved: isSaved ?? this.isSaved,
    );
  }
} 