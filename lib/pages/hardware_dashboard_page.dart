import 'package:flutter/material.dart';
import '../models/hardware_model.dart';

class HardwareDashboardPage extends StatelessWidget {
  final List<HardwareModel> hardwareData;

  const HardwareDashboardPage({super.key, required this.hardwareData});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '하드웨어 종합현황 (구현 예정)',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
} 