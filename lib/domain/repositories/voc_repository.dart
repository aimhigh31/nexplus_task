import '../../models/voc_model.dart';

/// VOC 관련 데이터 접근을 위한 레포지토리 인터페이스
abstract class VocRepository {
  /// VOC 목록 조회
  /// 
  /// [search] 검색어
  /// [detailSearch] 상세 검색어
  /// [vocCategory] VOC 분류
  /// [requestType] 요청 유형
  /// [status] 상태
  /// [startDate] 시작일
  /// [endDate] 종료일
  /// [dueDateStart] 처리 예정일 시작
  /// [dueDateEnd] 처리 예정일 종료
  Future<List<VocModel>> getVocs({
    String? search,
    String? detailSearch,
    String? vocCategory,
    String? requestType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueDateStart,
    DateTime? dueDateEnd,
  });
  
  /// VOC 추가
  /// 
  /// [voc] 추가할 VOC 모델
  Future<VocModel?> addVoc(VocModel voc);
  
  /// VOC 수정
  /// 
  /// [code] 수정할 VOC 코드
  /// [voc] 수정된 VOC 모델
  Future<VocModel?> updateVoc(String code, VocModel voc);
  
  /// VOC 삭제
  /// 
  /// [code] 삭제할 VOC 코드
  Future<bool> deleteVoc(String code);
} 