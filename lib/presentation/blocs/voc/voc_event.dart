import 'package:equatable/equatable.dart';
import '../../../models/voc_model.dart';

/// VOC BLoC 이벤트 기본 클래스
abstract class VocEvent extends Equatable {
  const VocEvent();
  
  @override
  List<Object?> get props => [];
}

/// VOC 목록 로드 이벤트
class LoadVocsEvent extends VocEvent {
  final String? search;
  final String? detailSearch;
  final String? vocCategory;
  final String? requestType;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? dueDateStart;
  final DateTime? dueDateEnd;
  
  const LoadVocsEvent({
    this.search,
    this.detailSearch,
    this.vocCategory,
    this.requestType,
    this.status,
    this.startDate,
    this.endDate,
    this.dueDateStart,
    this.dueDateEnd,
  });
  
  @override
  List<Object?> get props => [
    search, 
    detailSearch, 
    vocCategory, 
    requestType, 
    status, 
    startDate, 
    endDate, 
    dueDateStart, 
    dueDateEnd
  ];
}

/// VOC 추가 이벤트
class AddVocEvent extends VocEvent {
  final VocModel voc;
  
  const AddVocEvent(this.voc);
  
  @override
  List<Object> get props => [voc];
}

/// VOC 수정 이벤트
class UpdateVocEvent extends VocEvent {
  final String code;
  final VocModel voc;
  
  const UpdateVocEvent(this.code, this.voc);
  
  @override
  List<Object> get props => [code, voc];
}

/// VOC 삭제 이벤트
class DeleteVocEvent extends VocEvent {
  final String code;
  
  const DeleteVocEvent(this.code);
  
  @override
  List<Object> get props => [code];
} 