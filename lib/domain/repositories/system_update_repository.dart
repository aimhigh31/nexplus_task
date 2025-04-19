import '../../models/system_update_model.dart';

/// 시스템 업데이트 관련 데이터 접근을 위한 레포지토리 인터페이스
abstract class SystemUpdateRepository {
  /// 시스템 업데이트 목록 조회
  /// 
  /// [search] 검색어
  /// [targetSystem] 대상 시스템
  /// [updateType] 업데이트 유형
  /// [status] 상태
  /// [startDate] 시작일
  /// [endDate] 종료일
  Future<List<SystemUpdateModel>> getSystemUpdates({
    String? search,
    String? targetSystem,
    String? updateType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// 시스템 업데이트 추가
  /// 
  /// [updateModel] 추가할 시스템 업데이트 모델
  Future<SystemUpdateModel?> addSystemUpdate(SystemUpdateModel updateModel);
  
  /// 시스템 업데이트 수정
  /// 
  /// [code] 업데이트 코드
  /// [updateModel] 수정된 시스템 업데이트 모델
  Future<SystemUpdateModel?> updateSystemUpdate(String code, SystemUpdateModel updateModel);
  
  /// 시스템 업데이트 삭제
  /// 
  /// [code] 삭제할 업데이트 코드
  Future<bool> deleteSystemUpdate(String code);
} 