import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HardwareModel {
  final int no;
  final DateTime regDate;
  final String? code;
  final String assetCode;
  final String? assetType;
  final String assetName;
  final String specification;
  final double? unitPrice;
  final int quantity;
  final String? lotCode;
  final String? detail;
  final String executionType;
  final DateTime? purchaseDate;
  final String? serialNumber;
  final DateTime? warrantyDate;
  final String? currentUser;
  final String remarks;
  final bool isSaved;
  final bool isModified;
  final String? id;

  HardwareModel({
    required this.no,
    required this.regDate,
    this.code,
    required this.assetCode,
    this.assetType,
    required this.assetName,
    required this.specification,
    this.unitPrice,
    required this.quantity,
    this.lotCode,
    this.detail,
    required this.executionType,
    this.purchaseDate,
    this.serialNumber,
    this.warrantyDate,
    this.currentUser,
    required this.remarks,
    this.isSaved = false,
    this.isModified = false,
    this.id,
  });

  // JSON 변환 메소드
  factory HardwareModel.fromJson(Map<String, dynamic> json) {
    // 날짜 처리 - 문자열이나 ISO 형식 모두 지원
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          debugPrint('날짜 변환 오류 (null 반환): $e');
          return null;
        }
      } else if (value is DateTime) {
        return value;
      }
      return null;
    }
    
    // MongoDB의 _id 필드 처리
    String? id = json['id'] as String?;
    if (id == null && json['_id'] != null) {
      if (json['_id'] is Map && json['_id']['\$oid'] != null) {
        // MongoDB ObjectId 형식 처리
        id = json['_id']['\$oid'] as String;
      } else {
        // 일반 문자열 형식
        id = json['_id'].toString();
      }
    }
    
    // 코드 필드 처리
    String? code = json['code'] as String?;
    
    // 번호 필드 처리
    int no;
    if (json['no'] is int) {
      no = json['no'] as int;
    } else if (json['no'] is String) {
      no = int.tryParse(json['no'] as String) ?? 0;
    } else {
      no = 0;
    }
    
    // 날짜 필드 처리
    DateTime regDate;
    if (json['regDate'] != null) {
      DateTime? parsedDate = parseDate(json['regDate']);
      regDate = parsedDate ?? DateTime.now();
    } else {
      regDate = DateTime.now();
    }
    
    // 수량 필드 처리
    int quantity;
    if (json['quantity'] is int) {
      quantity = json['quantity'] as int;
    } else if (json['quantity'] is String) {
      quantity = int.tryParse(json['quantity'] as String) ?? 1;
    } else {
      quantity = 1;
    }
    
    // 단가 필드 처리
    double? unitPrice;
    if (json['unitPrice'] != null) {
      if (json['unitPrice'] is double) {
        unitPrice = json['unitPrice'] as double;
      } else if (json['unitPrice'] is int) {
        unitPrice = (json['unitPrice'] as int).toDouble();
      } else if (json['unitPrice'] is String) {
        unitPrice = double.tryParse(json['unitPrice'] as String);
      }
    }
    
    // 추가 날짜 필드 처리
    DateTime? purchaseDate = parseDate(json['purchaseDate']);
    DateTime? warrantyDate = parseDate(json['warrantyDate']);
    
    // 저장 및 수정 상태 필드 처리
    bool isSaved = false;
    bool isModified = false;
    
    if (json['isSaved'] is bool) {
      isSaved = json['isSaved'] as bool;
    } else if (json['saveStatus'] is bool) {
      isSaved = json['saveStatus'] as bool;
    }
    
    if (json['isModified'] is bool) {
      isModified = json['isModified'] as bool;
    } else if (json['modifiedStatus'] is bool) {
      isModified = json['modifiedStatus'] as bool;
    }
    
    return HardwareModel(
      id: id,
      no: no,
      regDate: regDate,
      code: code,
      assetCode: json['assetCode'] as String? ?? '',
      assetType: json['assetType'] as String?,
      assetName: json['assetName'] as String? ?? '',
      specification: json['specification'] as String? ?? '',
      unitPrice: unitPrice,
      executionType: json['executionType'] as String? ?? '신규구매',
      quantity: quantity,
      lotCode: json['lotCode'] as String?,
      detail: json['detail'] as String?,
      purchaseDate: purchaseDate,
      serialNumber: json['serialNumber'] as String?,
      warrantyDate: warrantyDate,
      currentUser: json['currentUser'] as String?,
      remarks: json['remarks'] as String? ?? '',
      isSaved: isSaved,
      isModified: isModified,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'no': no,
      'assetCode': assetCode,
      'assetName': assetName,
      'specification': specification,
      'executionType': executionType,
      'quantity': quantity,
      'remarks': remarks,
      'saveStatus': isSaved,
      'modifiedStatus': isModified,
      'isSaved': isSaved,
      'isModified': isModified,
    };
    
    // 날짜 변환 (ISO 문자열)
    data['regDate'] = regDate.toIso8601String();
    
    // 선택적 필드 추가
    if (code != null) {
      data['code'] = code;
    }
    
    if (id != null) {
      data['id'] = id;
      data['_id'] = id;
    }
    
    // 새로 추가된 필드들
    if (assetType != null) {
      data['assetType'] = assetType;
    }
    
    if (unitPrice != null) {
      data['unitPrice'] = unitPrice;
    }
    
    if (lotCode != null) {
      data['lotCode'] = lotCode;
    }
    
    if (detail != null) {
      data['detail'] = detail;
    }
    
    if (purchaseDate != null) {
      data['purchaseDate'] = purchaseDate?.toIso8601String();
    }
    
    if (serialNumber != null) {
      data['serialNumber'] = serialNumber;
    }
    
    if (warrantyDate != null) {
      data['warrantyDate'] = warrantyDate?.toIso8601String();
    }
    
    if (currentUser != null) {
      data['currentUser'] = currentUser;
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
    String? assetType,
    String? assetName,
    String? specification,
    double? unitPrice,
    int? quantity,
    String? lotCode,
    String? detail,
    String? executionType,
    DateTime? purchaseDate,
    String? serialNumber,
    DateTime? warrantyDate,
    String? currentUser,
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
      assetType: assetType ?? this.assetType,
      assetName: assetName ?? this.assetName,
      specification: specification ?? this.specification,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      lotCode: lotCode ?? this.lotCode,
      detail: detail ?? this.detail,
      executionType: executionType ?? this.executionType,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      serialNumber: serialNumber ?? this.serialNumber,
      warrantyDate: warrantyDate ?? this.warrantyDate,
      currentUser: currentUser ?? this.currentUser,
      remarks: remarks ?? this.remarks,
      isSaved: isSaved ?? this.isSaved,
      isModified: isModified ?? this.isModified,
      id: id ?? this.id,
    );
  }
} 