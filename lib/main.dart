import 'package:flutter/material.dart';
import 'pages/system_voc_page.dart';
import 'services/api_service.dart';
import 'widgets/sidebar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // API 연결 테스트
  final apiService = ApiService();
  try {
    final isConnected = await apiService.testConnection();
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
    return MaterialApp(
      title: '시스템 VOC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
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
        // 시스템 업데이트 페이지는 아직 미구현
        return const Center(
          child: Text('시스템 업데이트 페이지 (준비 중)', style: TextStyle(fontSize: 24)),
        );
      default:
        return const SystemVocPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
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
    );
  }
}
