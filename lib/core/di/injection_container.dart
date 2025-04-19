import 'package:get_it/get_it.dart';

import '../../data/data_sources/remote/system_update_api.dart';
import '../../data/data_sources/remote/voc_api.dart';
import '../../data/repositories/system_update_repository_impl.dart';
import '../../data/repositories/voc_repository_impl.dart';
import '../../domain/repositories/system_update_repository.dart';
import '../../domain/repositories/voc_repository.dart';
import '../../presentation/blocs/voc/voc_bloc.dart';
import '../network/http_client.dart';

/// 전역 GetIt 인스턴스
final GetIt sl = GetIt.instance;

/// 의존성 주입 초기화
Future<void> init() async {
  // 핵심 서비스
  sl.registerLazySingleton(() => HttpClient());
  
  // API 서비스
  sl.registerLazySingleton(() => VocApi(sl()));
  sl.registerLazySingleton(() => SystemUpdateApi(sl()));
  
  // 레포지토리
  sl.registerLazySingleton<VocRepository>(() => VocRepositoryImpl(sl()));
  sl.registerLazySingleton<SystemUpdateRepository>(() => SystemUpdateRepositoryImpl(sl()));
  
  // BLoC
  sl.registerFactory(() => VocBloc(vocRepository: sl()));
  
  // 유스케이스 (아직 구현되지 않음)
} 