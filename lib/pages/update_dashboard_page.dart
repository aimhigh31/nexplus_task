// lib/pages/update_dashboard_page.dart (임시 Placeholder)

import 'package:flutter/material.dart';
import '../models/system_update_model.dart'; // 모델 import는 유지

class UpdateDashboardPage extends StatelessWidget {
  final List<SystemUpdateModel> updateData;

  const UpdateDashboardPage({super.key, required this.updateData});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 대시보드 UI 구현
    return const Center(
      child: Text(
        '시스템 업데이트 종합현황 (구현 예정)',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
} 