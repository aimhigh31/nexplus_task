import 'package:flutter/material.dart';

class SoftwareDashboardPage extends StatelessWidget {
  const SoftwareDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '소프트웨어 관리 종합 현황 페이지입니다.\n(개발 예정)',
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
} 