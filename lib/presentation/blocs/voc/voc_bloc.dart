import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/voc_model.dart';
import '../../../domain/repositories/voc_repository.dart';
import 'voc_event.dart';
import 'voc_state.dart';

/// VOC 관리를 위한 BLoC
class VocBloc extends Bloc<VocEvent, VocState> {
  final VocRepository _vocRepository;
  
  /// 생성자
  VocBloc({required VocRepository vocRepository})
      : _vocRepository = vocRepository,
        super(VocInitial()) {
    on<LoadVocsEvent>(_onLoadVocs);
    on<AddVocEvent>(_onAddVoc);
    on<UpdateVocEvent>(_onUpdateVoc);
    on<DeleteVocEvent>(_onDeleteVoc);
  }
  
  /// VOC 목록 로드 처리
  Future<void> _onLoadVocs(LoadVocsEvent event, Emitter<VocState> emit) async {
    emit(VocLoading());
    
    try {
      final vocs = await _vocRepository.getVocs(
        search: event.search,
        detailSearch: event.detailSearch,
        vocCategory: event.vocCategory,
        requestType: event.requestType,
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
        dueDateStart: event.dueDateStart,
        dueDateEnd: event.dueDateEnd,
      );
      
      emit(VocsLoaded(vocs));
    } catch (e) {
      emit(VocError('VOC 목록 로드 실패: $e'));
    }
  }
  
  /// VOC 추가 처리
  Future<void> _onAddVoc(AddVocEvent event, Emitter<VocState> emit) async {
    emit(VocLoading());
    
    try {
      final addedVoc = await _vocRepository.addVoc(event.voc);
      
      if (addedVoc != null) {
        emit(VocAdded(addedVoc));
      } else {
        emit(const VocError('VOC 추가 실패: 응답이 null입니다.'));
      }
    } catch (e) {
      emit(VocError('VOC 추가 실패: $e'));
    }
  }
  
  /// VOC 수정 처리
  Future<void> _onUpdateVoc(UpdateVocEvent event, Emitter<VocState> emit) async {
    emit(VocLoading());
    
    try {
      final updatedVoc = await _vocRepository.updateVoc(event.code, event.voc);
      
      if (updatedVoc != null) {
        emit(VocUpdated(updatedVoc));
      } else {
        emit(const VocError('VOC 수정 실패: 응답이 null입니다.'));
      }
    } catch (e) {
      emit(VocError('VOC 수정 실패: $e'));
    }
  }
  
  /// VOC 삭제 처리
  Future<void> _onDeleteVoc(DeleteVocEvent event, Emitter<VocState> emit) async {
    emit(VocLoading());
    
    try {
      final isDeleted = await _vocRepository.deleteVoc(event.code);
      
      if (isDeleted) {
        emit(VocDeleted(event.code));
      } else {
        emit(const VocError('VOC 삭제 실패'));
      }
    } catch (e) {
      emit(VocError('VOC 삭제 실패: $e'));
    }
  }
} 