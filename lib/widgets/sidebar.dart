import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  final String currentPage;
  final Function(String) onPageChanged;

  const SideBar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey.shade900,
      child: Column(
        children: [
          // 로고 및 앱 제목
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            color: Colors.blue.shade800,
            child: Row(
              children: [
                Icon(
                  Icons.computer,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 16),
                Text(
                  'IT 관리 시스템',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // 메뉴 항목
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // IT 카테고리
                  _buildCategory('IT'),
                  
                  // IT 하위 메뉴 항목들
                  _buildMenuItem(
                    'system_voc',
                    'VOC 관리',
                    Icons.feedback_outlined,
                    currentPage == 'system_voc',
                  ),
                  _buildMenuItem(
                    'system_update',
                    '솔루션 개발',
                    Icons.update,
                    currentPage == 'system_update',
                  ),
                  _buildMenuItem(
                    'hardware_management',
                    '하드웨어 관리',
                    Icons.computer,
                    currentPage == 'hardware_management',
                  ),
                  _buildMenuItem(
                    'software_management',
                    '소프트웨어 관리',
                    Icons.apps,
                    currentPage == 'software_management',
                  ),
                  _buildMenuItem(
                    'equipment_connection',
                    '설비연동 관리',
                    Icons.wifi_tethering,
                    currentPage == 'equipment_connection',
                  ),
                ],
              ),
            ),
          ),
          
          // 하단 영역
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade700,
                  child: Text(
                    'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '관리자',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    // 로그아웃 기능 (미구현)
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 카테고리 위젯 (헤더)
  Widget _buildCategory(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      alignment: Alignment.centerLeft,
      color: Colors.grey.shade800,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // 메뉴 항목 위젯
  Widget _buildMenuItem(
    String id,
    String title,
    IconData icon,
    bool isSelected,
  ) {
    return Material(
      color: isSelected ? Colors.blue.shade700 : Colors.transparent,
      child: InkWell(
        onTap: () => onPageChanged(id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          margin: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey.shade400,
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 