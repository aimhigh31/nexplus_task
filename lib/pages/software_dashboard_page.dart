import 'package:flutter/material.dart';
import '../models/software_model.dart';

class SoftwareDashboardPage extends StatelessWidget {
  final List<SoftwareModel> softwareData;
  
  const SoftwareDashboardPage({super.key, required this.softwareData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.desktop_windows, size: 80, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            '소프트웨어 대시보드',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '등록된 소프트웨어: ${softwareData.length}개',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
} 