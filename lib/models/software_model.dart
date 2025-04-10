import 'package:flutter/material.dart';

class SoftwareModel {
  final int no;
  final String? code;
  final DateTime regDate;
  final String assetCode;
  final String assetType; // 자산분류: AutoCAD, ZWCAD 등
  final String assetName;
  final String specification;
  final double setupPrice; // 구축금액
  final double annualMaintenancePrice; // 연유지비
  final String costType; // 비용형태: 연구독, 월구독, 영구
  final String vendor; // 거래업체
  final String licenseKey; // 라이센스키
  final String user; // 사용자
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String lotCode;
  final String detail;
  final DateTime? startDate; // 시작일
  final DateTime? endDate; // 종료일
  final String remarks;
  final bool isModified;
  final bool isSaved;

  SoftwareModel({
    required this.no,
    this.code,
    required this.regDate,
    required this.assetCode,
    required this.assetType,
    required this.assetName,
    required this.specification,
    required this.setupPrice,
    required this.annualMaintenancePrice,
    required this.costType,
    required this.vendor,
    required this.licenseKey,
    required this.user,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.lotCode,
    required this.detail,
    this.startDate,
    this.endDate,
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
      assetType: json['assetType'] ?? '',
      assetName: json['assetName'] ?? '',
      specification: json['specification'] ?? '',
      setupPrice: json['setupPrice'] != null
          ? double.parse(json['setupPrice'].toString())
          : 0.0,
      annualMaintenancePrice: json['annualMaintenancePrice'] != null
          ? double.parse(json['annualMaintenancePrice'].toString())
          : 0.0,
      costType: json['costType'] ?? '',
      vendor: json['vendor'] ?? '',
      licenseKey: json['licenseKey'] ?? '',
      user: json['user'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: json['unitPrice'] != null
          ? double.parse(json['unitPrice'].toString())
          : 0.0,
      totalPrice: json['totalPrice'] != null
          ? double.parse(json['totalPrice'].toString())
          : 0.0,
      lotCode: json['lotCode'] ?? '',
      detail: json['detail'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
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
      'assetType': assetType,
      'assetName': assetName,
      'specification': specification,
      'setupPrice': setupPrice,
      'annualMaintenancePrice': annualMaintenancePrice,
      'costType': costType,
      'vendor': vendor,
      'licenseKey': licenseKey,
      'user': user,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'lotCode': lotCode,
      'detail': detail,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
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
    String? assetType,
    String? assetName,
    String? specification,
    double? setupPrice,
    double? annualMaintenancePrice,
    String? costType,
    String? vendor,
    String? licenseKey,
    String? user,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? lotCode,
    String? detail,
    DateTime? startDate,
    DateTime? endDate,
    String? remarks,
    bool? isModified,
    bool? isSaved,
  }) {
    return SoftwareModel(
      no: no ?? this.no,
      code: code ?? this.code,
      regDate: regDate ?? this.regDate,
      assetCode: assetCode ?? this.assetCode,
      assetType: assetType ?? this.assetType,
      assetName: assetName ?? this.assetName,
      specification: specification ?? this.specification,
      setupPrice: setupPrice ?? this.setupPrice,
      annualMaintenancePrice: annualMaintenancePrice ?? this.annualMaintenancePrice,
      costType: costType ?? this.costType,
      vendor: vendor ?? this.vendor,
      licenseKey: licenseKey ?? this.licenseKey,
      user: user ?? this.user,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      lotCode: lotCode ?? this.lotCode,
      detail: detail ?? this.detail,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      remarks: remarks ?? this.remarks,
      isModified: isModified ?? this.isModified,
      isSaved: isSaved ?? this.isSaved,
    );
  }
  
  // 코드 생성 메서드
  static String generateSoftwareCode(DateTime date, int no) {
    final yearMonth = '${date.year.toString().substring(2)}${date.month.toString().padLeft(2, '0')}';
    final seq = no.toString().padLeft(3, '0');
    return 'SWM-$yearMonth-$seq';
  }
} 