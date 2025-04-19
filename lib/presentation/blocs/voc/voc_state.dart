import 'package:equatable/equatable.dart';
import '../../../models/voc_model.dart';

/// VOC BLoC 상태 기본 클래스
abstract class VocState extends Equatable {
  const VocState();
  
  @override
  List<Object?> get props => [];
}

/// 초기 상태
class VocInitial extends VocState {}

/// 로딩 상태
class VocLoading extends VocState {}

/// VOC 목록 로드 완료 상태
class VocsLoaded extends VocState {
  final List<VocModel> vocs;
  
  const VocsLoaded(this.vocs);
  
  @override
  List<Object> get props => [vocs];
}

/// VOC 추가 완료 상태
class VocAdded extends VocState {
  final VocModel voc;
  
  const VocAdded(this.voc);
  
  @override
  List<Object> get props => [voc];
}

/// VOC 수정 완료 상태
class VocUpdated extends VocState {
  final VocModel voc;
  
  const VocUpdated(this.voc);
  
  @override
  List<Object> get props => [voc];
}

/// VOC 삭제 완료 상태
class VocDeleted extends VocState {
  final String code;
  
  const VocDeleted(this.code);
  
  @override
  List<Object> get props => [code];
}

/// 에러 상태
class VocError extends VocState {
  final String message;
  
  const VocError(this.message);
  
  @override
  List<Object> get props => [message];
} 