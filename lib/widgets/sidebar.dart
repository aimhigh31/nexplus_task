import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class SideBar extends StatefulWidget {
  final String currentPage;
  final Function(String) onPageChanged;

  const SideBar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late Timer _timer;
  late String _currentTime;
  late String _currentDate;
  final TextEditingController _searchController = TextEditingController();
  
  // 메뉴 펼침/닫힘 상태 변수 추가
  bool _isMainMenuExpanded = true;
  bool _isITMenuExpanded = true;
  bool _isPlanningMenuExpanded = true;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('h:mm a').format(now);
      _currentDate = DateFormat('MMM dd, yyyy').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // 로고 영역
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                // 회사 로고 (기어 아이콘)
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: Colors.teal.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                // 회사명
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'CONSTRUCTION',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'SERVICE',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 검색 영역
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: 'Search',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          
          // 메뉴 영역 - Expanded와 SingleChildScrollView로 감싸서 스크롤 가능하게 함
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 메인 메뉴 카테고리
                  _buildMenuCategory('MAIN MENU', _isMainMenuExpanded, () {
                    setState(() {
                      _isMainMenuExpanded = !_isMainMenuExpanded;
                    });
                  }),
                  
                  // 메인 메뉴 항목들 (펼침/닫힘 상태에 따라 표시)
                  if (_isMainMenuExpanded) ...[
                    _buildMenuItem('work', '업무', Icons.business_center_outlined, widget.currentPage == 'work', true),
                    _buildMenuItem('cost', '비용', Icons.monetization_on_outlined, widget.currentPage == 'cost', true),
                    _buildMenuItem('kpi', 'KPI', Icons.stacked_line_chart, widget.currentPage == 'kpi', true),
                    _buildMenuItem('education', '교육', Icons.school_outlined, widget.currentPage == 'education', true),
                  ],
                  
                  // IT 메뉴 카테고리
                  _buildMenuCategory('IT 메뉴', _isITMenuExpanded, () {
                    setState(() {
                      _isITMenuExpanded = !_isITMenuExpanded;
                    });
                  }),
                  
                  // IT 메뉴 항목들 (펼침/닫힘 상태에 따라 표시)
                  if (_isITMenuExpanded) ...[
                    _buildMenuItem('system_voc', 'VOC', Icons.feedback_outlined, widget.currentPage == 'system_voc', true),
                    _buildMenuItem('system_update', '솔루션 개발', Icons.update, widget.currentPage == 'system_update', true),
                    _buildMenuItem('hardware_management', '하드웨어 관리', Icons.computer_outlined, widget.currentPage == 'hardware_management', true),
                    _buildMenuItem('software_management', '소프트웨어 관리', Icons.apps_outlined, widget.currentPage == 'software_management', true),
                    _buildMenuItem('equipment_connection', '설비연동 관리', Icons.wifi_tethering_outlined, widget.currentPage == 'equipment_connection', true),
                  ],
                  
                  // 기획 메뉴 카테고리
                  _buildMenuCategory('기획 메뉴', _isPlanningMenuExpanded, () {
                    setState(() {
                      _isPlanningMenuExpanded = !_isPlanningMenuExpanded;
                    });
                  }),
                  
                  // 기획 메뉴 항목들 (펼침/닫힘 상태에 따라 표시)
                  if (_isPlanningMenuExpanded) ...[
                    _buildMenuItem('investment', '투자관리', Icons.trending_up, widget.currentPage == 'investment', true),
                    _buildMenuItem('sales', '매출관리', Icons.attach_money, widget.currentPage == 'sales', true),
                    _buildMenuItem('inventory', '재고관리', Icons.inventory_2_outlined, widget.currentPage == 'inventory', true),
                    _buildMenuItem('personnel', '인원관리', Icons.people_outline, widget.currentPage == 'personnel', true),
                  ],
                ],
              ),
            ),
          ),
          
          // 하단 프로필 및 시간 영역
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // 프로필 정보
                Row(
                  children: [
                    // 프로필 아바타
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        'J',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 사용자 이름
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jacob Jones',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _currentTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            _currentDate,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 프로필로 이동 아이콘
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 메뉴 카테고리 위젯 (펼침/닫힘 기능 포함)
  Widget _buildMenuCategory(String title, bool isExpanded, VoidCallback onToggle) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            // 펼침/닫힘 아이콘
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.grey.shade500,
            ),
          ],
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
    bool isSubMenu, // 하위 메뉴 여부
  ) {
    return Material(
      color: isSelected ? Colors.teal.shade50 : Colors.transparent,
      child: InkWell(
        onTap: () => widget.onPageChanged(id),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSubMenu ? 32.0 : 16.0, // 하위 메뉴일 경우 더 들여쓰기
            vertical: 12.0,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.teal.shade600 : Colors.grey.shade700,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.teal.shade600 : Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 