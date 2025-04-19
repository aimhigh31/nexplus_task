import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart' as di;
import 'pages/system_voc_page.dart';
import 'pages/system_update_page.dart';
import 'pages/hardware_management_page.dart';
import 'pages/software_management_page.dart';
import 'pages/equipment_connection_page.dart';
import 'services/service_locator.dart';
import 'services/api/api_client.dart';
import 'services/download/download_progress_tracker.dart';
import 'widgets/sidebar.dart';
import 'widgets/download_progress_widget.dart';
import 'widgets/download_notification_icon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 서비스 로케이터 설정
  setupServiceLocator();
  
  // 의존성 주입 초기화
  await di.init();
  
  // API 연결 테스트 (수정된 방식)
  final apiClient = serviceLocator<ApiClient>();
  try {
    final uri = Uri.parse('${apiClient.baseUrl}/health');
    final response = await apiClient.safeGet(uri);
    final isConnected = response.statusCode == 200;
    debugPrint('API 연결 ${isConnected ? '성공' : '실패'}');
  } catch (e) {
    debugPrint('API 연결 테스트 실패: $e');
    // API 연결 실패해도 계속 진행
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 다운로드 상태 관리를 위한 Provider 등록
        ChangeNotifierProvider.value(
          value: serviceLocator<DownloadProgressTracker>(),
        ),
      ],
      child: MaterialApp(
        title: '시스템 VOC',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MainLayout(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // 현재 선택된 메뉴 항목
  String _currentPage = 'system_voc';
  
  // 페이지 변경 핸들러
  void _changePage(String page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  // 현재 선택된 페이지에 따라 내용 표시
  Widget _getPageContent() {
    switch (_currentPage) {
      case 'system_voc':
        return const SystemVocPage();
      case 'system_update':
        return const SystemUpdatePage();
      case 'hardware_management':
        return const HardwareManagementPage();
      case 'software_management':
        return const SoftwareManagementPage();
      case 'equipment_connection':
        return const EquipmentConnectionPage();
      default:
        return const SystemVocPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // 사이드바
              SideBar(
                currentPage: _currentPage,
                onPageChanged: _changePage,
              ),
              
              // 메인 콘텐츠
              Expanded(
                child: _getPageContent(),
              ),
            ],
          ),
          
          // 다운로드 상태 표시 위젯
          const Positioned(
            bottom: 16,
            right: 16,
            child: DownloadProgressWidget(),
          ),
          
          // 다운로드 알림 아이콘 (우측 상단)
          const Positioned(
            top: 16,
            right: 16,
            child: DownloadNotificationIcon(),
          ),
        ],
      ),
    );
  }
}
