import '../../models/system_update_model.dart';
import '../../domain/repositories/system_update_repository.dart';
import '../data_sources/remote/system_update_api.dart';

/// 시스템 업데이트 레포지토리 구현체
class SystemUpdateRepositoryImpl implements SystemUpdateRepository {
  final SystemUpdateApi _systemUpdateApi;
  
  /// 생성자
  SystemUpdateRepositoryImpl(this._systemUpdateApi);
  
  @override
  Future<List<SystemUpdateModel>> getSystemUpdates({
    String? search,
    String? targetSystem,
    String? updateType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _systemUpdateApi.getSystemUpdates(
      search: search,
      targetSystem: targetSystem,
      updateType: updateType,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }
  
  @override
  Future<SystemUpdateModel?> addSystemUpdate(SystemUpdateModel updateModel) async {
    return await _systemUpdateApi.addSystemUpdate(updateModel);
  }
  
  @override
  Future<SystemUpdateModel?> updateSystemUpdate(String code, SystemUpdateModel updateModel) async {
    return await _systemUpdateApi.updateSystemUpdate(code, updateModel);
  }
  
  @override
  Future<bool> deleteSystemUpdate(String code) async {
    return await _systemUpdateApi.deleteSystemUpdate(code);
  }
} 