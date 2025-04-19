import '../../models/voc_model.dart';
import '../../domain/repositories/voc_repository.dart';
import '../data_sources/remote/voc_api.dart';

/// VOC 레포지토리 구현체
class VocRepositoryImpl implements VocRepository {
  final VocApi _vocApi;
  
  /// 생성자
  VocRepositoryImpl(this._vocApi);
  
  @override
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
  }) async {
    return await _vocApi.getVocData(
      search: search,
      detailSearch: detailSearch,
      vocCategory: vocCategory,
      requestType: requestType,
      status: status,
      startDate: startDate,
      endDate: endDate,
      dueDateStart: dueDateStart,
      dueDateEnd: dueDateEnd,
    );
  }
  
  @override
  Future<VocModel?> addVoc(VocModel voc) async {
    return await _vocApi.addVoc(voc);
  }
  
  @override
  Future<VocModel?> updateVoc(String code, VocModel voc) async {
    return await _vocApi.updateVoc(code, voc);
  }
  
  @override
  Future<bool> deleteVoc(String code) async {
    return await _vocApi.deleteVoc(code);
  }
} 