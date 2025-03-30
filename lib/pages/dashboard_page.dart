import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/voc_model.dart';
import '../services/api_service.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  List<VocModel> _vocData = [];
  bool _isLoading = true;
  DateTime _selectedPeriodStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedPeriodEnd = DateTime.now();
  
  // 차트 데이터
  Map<String, int> _categoryCount = {};
  Map<String, int> _requestTypeCount = {};
  Map<String, int> _statusCount = {};
  List<MapEntry<DateTime, int>> _dailyCount = [];
  
  @override
  void initState() {
    super.initState();
    _loadVocData();
  }
  
  // VOC 데이터 로드
  Future<void> _loadVocData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final vocData = await _apiService.getVocData(
        startDate: _selectedPeriodStart,
        endDate: _selectedPeriodEnd,
      );
      
      setState(() {
        _vocData = vocData;
        _isLoading = false;
      });
      
      _processChartData();
    } catch (e) {
      debugPrint('대시보드 데이터 로드 오류: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터 로드 중 오류가 발생했습니다: $e')),
      );
    }
  }
  
  // 차트 데이터 처리
  void _processChartData() {
    if (_vocData.isEmpty) return;
    
    // 카운트 초기화
    _categoryCount = {};
    _requestTypeCount = {};
    _statusCount = {};
    Map<String, int> dailyCountMap = {};
    
    // 데이터 집계
    for (final voc in _vocData) {
      // 1. VOC 분류별 카운트
      _categoryCount[voc.vocCategory] = (_categoryCount[voc.vocCategory] ?? 0) + 1;
      
      // 2. 요청유형별 카운트
      _requestTypeCount[voc.requestType] = (_requestTypeCount[voc.requestType] ?? 0) + 1;
      
      // 3. 상태별 카운트
      _statusCount[voc.status] = (_statusCount[voc.status] ?? 0) + 1;
      
      // 4. 일별 등록 카운트
      final dateKey = DateFormat('yyyy-MM-dd').format(voc.regDate);
      dailyCountMap[dateKey] = (dailyCountMap[dateKey] ?? 0) + 1;
    }
    
    // 일별 데이터를 시계열로 정렬
    _dailyCount = dailyCountMap.entries.map((entry) {
      return MapEntry(DateFormat('yyyy-MM-dd').parse(entry.key), entry.value);
    }).toList();
    
    _dailyCount.sort((a, b) => a.key.compareTo(b.key));
    
    setState(() {});
  }
  
  // 날짜 선택 다이얼로그
  Future<void> _selectDateRange() async {
    final initialDateRange = DateTimeRange(
      start: _selectedPeriodStart,
      end: _selectedPeriodEnd,
    );
    
    // 임시로 선택된 날짜를 저장할 변수
    List<DateTime?> tempSelectedDates = [initialDateRange.start, initialDateRange.end];
    
    // 팝업 스타일로 표시할 커스텀 날짜 범위 선택 다이얼로그
    final result = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // 달력 크기에 맞게 너비와 높이 조절
        child: Container(
          width: 360, // 달력이 들어갈 적절한 너비
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 컨텐츠 크기에 맞게 최소화
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('날짜 범위 선택', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Container(
                height: 400, // 달력 높이 (2개월 표시 기준)
                child: CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                    calendarType: CalendarDatePicker2Type.range,
                    selectedDayHighlightColor: Colors.blue,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  ),
                  value: tempSelectedDates,
                  onValueChanged: (dates) {
                    // 날짜 선택 시 팝업을 닫지 않고 임시 변수에만 저장
                    if (dates.length >= 2 && dates[0] != null && dates[1] != null) {
                      tempSelectedDates = dates;
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // 확인 버튼을 클릭해야 날짜 범위를 적용하고 팝업을 닫음
                      if (tempSelectedDates.length >= 2 && 
                          tempSelectedDates[0] != null && 
                          tempSelectedDates[1] != null) {
                        Navigator.of(context).pop(
                          DateTimeRange(
                            start: tempSelectedDates[0]!, 
                            end: tempSelectedDates[1]!
                          )
                        );
                      }
                    },
                    child: const Text('확인'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _selectedPeriodStart = result.start;
        _selectedPeriodEnd = result.end;
      });
      _loadVocData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VOC 종합현황'),
        actions: [
          // 기간 선택 버튼
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: '기간 선택',
            onPressed: _selectDateRange,
          ),
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: _loadVocData,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _buildDashboard(),
    );
  }
  
  // 대시보드 빌드
  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // KPI 카드 행 (상단으로 이동)
        Row(
          children: [
            // 연간 VOC
            Expanded(
              child: _buildKpiCard(
                '연간 VOC',
                _vocData.where((voc) {
                  final now = DateTime.now();
                  final regDate = voc.regDate;
                  return regDate.year == now.year;
                }).length.toString(),
                Colors.indigo,
                Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 16),
            // 이번 달 VOC
            Expanded(
              child: _buildKpiCard(
                '이번 달 VOC',
                _vocData.where((voc) {
                  final now = DateTime.now();
                  final regDate = voc.regDate;
                  return regDate.year == now.year && regDate.month == now.month;
                }).length.toString(),
                Colors.blue,
                Icons.date_range,
              ),
            ),
            const SizedBox(width: 16),
            // 이번 주 VOC
            Expanded(
              child: _buildKpiCard(
                '이번 주 VOC',
                _vocData.where((voc) {
                  final now = DateTime.now();
                  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                  final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
                  return voc.regDate.isAfter(startOfWeekDate.subtract(const Duration(days: 1))) &&
                         voc.regDate.isBefore(now.add(const Duration(days: 1)));
                }).length.toString(),
                Colors.green,
                Icons.view_week,
              ),
            ),
            const SizedBox(width: 16),
            // 당일 VOC
            Expanded(
              child: _buildKpiCard(
                '당일 VOC',
                _vocData.where((voc) {
                  final today = DateTime.now();
                  final regDate = voc.regDate;
                  return regDate.year == today.year && 
                         regDate.month == today.month && 
                         regDate.day == today.day;
                }).length.toString(),
                Colors.orange,
                Icons.today,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 기간 정보 (KPI 카드 행 아래로 이동)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '분석 기간',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('yyyy년 MM월 dd일').format(_selectedPeriodStart)} ~ '
                      '${DateFormat('yyyy년 MM월 dd일').format(_selectedPeriodEnd)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: _selectDateRange,
                      child: const Text('기간 변경'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '총 VOC 수: ${_vocData.length}건',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 상태별 현황 파이 차트와 진행 중/보류 테이블 행
        if (_statusCount.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상태별 현황 파이 차트 (좌측 50%)
              Expanded(
                flex: 1,
                child: _buildChartCard(
                  '상태별 현황',
                  _buildCompactPieChart(_statusCount),
                  Icons.pie_chart,
                ),
              ),
              const SizedBox(width: 16),
              // 진행 중/보류 VOC 테이블 (우측 50%)
              Expanded(
                flex: 1,
                child: _buildPendingVocTable(),
              ),
            ],
          ),
        
        const SizedBox(height: 16),
        
        // VOC 분류별 현황과 요청유형별 현황 차트 배치
        if (_categoryCount.isNotEmpty && _requestTypeCount.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // VOC 분류별 현황 바 차트 (좌측 50%)
              Expanded(
                flex: 1,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bar_chart, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'VOC 분류별 현황',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200, // 높이 조정
                          child: _buildBarChart(_categoryCount),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 요청유형별 현황 바 차트 (우측 50%)
              Expanded(
                flex: 1,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bar_chart, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              '요청유형별 현황',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200, // 높이 조정
                          child: _buildBarChart(_requestTypeCount),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        else if (_categoryCount.isNotEmpty)
          _buildChartCard(
            'VOC 분류별 현황',
            _buildBarChart(_categoryCount),
            Icons.bar_chart,
          )
        else if (_requestTypeCount.isNotEmpty)
          _buildChartCard(
            '요청유형별 현황',
            _buildBarChart(_requestTypeCount),
            Icons.bar_chart,
          ),
        
        const SizedBox(height: 16),
        
        // 일별 VOC 추이 라인 차트
        if (_dailyCount.isNotEmpty)
          _buildChartCard(
            '일별 VOC 등록 추이',
            _buildLineChart(),
            Icons.show_chart,
          ),
      ],
    );
  }
  
  // KPI 카드 위젯
  Widget _buildKpiCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 차트 카드 위젯
  Widget _buildChartCard(String title, Widget chart, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // 이전에는 250이었지만 200으로 수정하여 VOC 분류별 현황과 동일하게 맞춤
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
  
  // 파이 차트 위젯 (축소 버전)
  Widget _buildCompactPieChart(Map<String, int> data) {
    // 차트 데이터 색상 (상태별 색상 지정)
    Map<String, Color> statusColors = {
      '진행중': Colors.orange,
      '보류': Colors.red,
      '완료': Colors.green,
      '접수': Colors.blue,
      '취소': Colors.purple,
    };
    
    // 기본 색상 리스트
    final List<Color> chartColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    
    // 전체 데이터 합계 계산
    final int totalCount = data.values.fold(0, (sum, value) => sum + value);
    
    // '접수' 값 찾기
    final int receiptCount = data['접수'] ?? 0;
    
    return Column(
      mainAxisSize: MainAxisSize.min, // 최소 크기로 제한
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬로 변경
          children: [
            // 파이 차트 (크기 조정)
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 200, // 이전에는 180이었지만 VOC 분류별 현황과 동일하게 200으로 수정
                child: PieChart(
                  PieChartData(
                    sections: List.generate(data.keys.length, (index) {
                      final key = data.keys.elementAt(index);
                      final value = data[key] ?? 0;
                      final total = data.values.fold(0, (sum, value) => sum + value);
                      final percentage = total > 0 ? (value / total * 100) : 0;
                      
                      // 상태에 따른 색상 지정
                      final color = statusColors[key] ?? chartColors[index % chartColors.length];
                      
                      return PieChartSectionData(
                        color: color,
                        value: value.toDouble(),
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 56, // 이전값 70에서 20% 감소시켜 56으로 수정
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13, // 크기가 줄었으므로 폰트 크기도 약간 감소
                        ),
                      );
                    }),
                    centerSpaceRadius: 24, // 이전값 30에서 20% 감소시켜 24로 수정
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ),
            
            // 범례
            Expanded(
              flex: 2,
              child: Container(
                height: 200, // 이전에는 180이었지만 VOC 분류별 현황과 동일하게 200으로 수정
                child: SingleChildScrollView( // 스크롤 가능하게 만들어 오버플로우 방지
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 수직 방향으로 중앙 정렬 유지
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start, // 중앙 정렬에서 왼쪽 정렬로 변경
                    children: [
                      // 전체 VOC 총 건수 먼저 표시
                      Container(
                        padding: const EdgeInsets.only(bottom: 10, top: 8, left: 20), // 왼쪽 여백 추가
                        width: double.infinity, // 너비를 최대로 설정
                        child: Text(
                          '총 ${totalCount}건',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                          textAlign: TextAlign.left, // 중앙 정렬에서 왼쪽 정렬로 변경
                        ),
                      ),
                      // 상태별 항목 표시
                      ...List.generate(data.keys.length, (index) {
                        final key = data.keys.elementAt(index);
                        final value = data[key] ?? 0;
                        
                        // 상태에 따른 색상 지정
                        final color = statusColors[key] ?? chartColors[index % chartColors.length];
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // 중앙 정렬에서 왼쪽 정렬로 변경
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 6, bottom: 6), // 좌측 여백 추가 및 상하 여백 증가
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start, // 중앙 정렬에서 왼쪽 정렬로 변경
                                children: [
                                  Container(
                                    width: 14, // 크기 유지
                                    height: 14, // 크기 유지
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12), // 간격 증가
                                  Text(
                                    key,
                                    style: const TextStyle(fontSize: 14), // 폰트 크기 유지
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 10), // 간격 증가
                                  Text(
                                    '$value건',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14, // 폰트 크기 유지
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // 진행 중/보류 VOC 테이블 위젯
  Widget _buildPendingVocTable() {
    // 진행 중이거나 보류 상태인 VOC만 필터링
    final pendingVocs = _vocData.where((voc) => 
      voc.status == '진행중' || voc.status == '보류').toList();
    
    // 페이지네이션 관련 상태 변수
    final int rowsPerPage = 5; // 한 페이지당 표시할 행 수를 5로 고정
    final int totalPages = (pendingVocs.length / rowsPerPage).ceil();
    final ValueNotifier<int> currentPage = ValueNotifier<int>(0);
    
    // 현재 페이지의 데이터만 가져오기
    List<VocModel> getPaginatedData() {
      if (pendingVocs.isEmpty) return [];
      
      final startIndex = currentPage.value * rowsPerPage;
      final endIndex = (startIndex + rowsPerPage > pendingVocs.length) 
          ? pendingVocs.length 
          : startIndex + rowsPerPage;
      
      return pendingVocs.sublist(startIndex, endIndex);
    }
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // 패딩 유지
        child: Column(
          mainAxisSize: MainAxisSize.min, // 크기 제한 유지
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 제목과 총 건수 같이 표시
                Row(
                  children: [
                    Icon(Icons.pending_actions, color: Colors.orange, size: 22), // 아이콘 크기 유지
                    const SizedBox(width: 8),
                    Text(
                      '진행 중/보류 VOC',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16, // 글자 크기 유지
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '총 ${pendingVocs.length}건',
                      style: TextStyle(
                        fontSize: 13, // 폰트 크기 유지
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                // 페이지네이션 컨트롤 
                if (pendingVocs.length > rowsPerPage)
                  ValueListenableBuilder<int>(
                    valueListenable: currentPage,
                    builder: (context, page, _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left, size: 20),
                            onPressed: page > 0
                                ? () => currentPage.value--
                                : null,
                            iconSize: 20,
                            padding: EdgeInsets.all(4),
                            constraints: BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                          ),
                          Text(
                            '${page + 1}/$totalPages',
                            style: TextStyle(fontSize: 13),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right, size: 20),
                            onPressed: page < totalPages - 1
                                ? () => currentPage.value++
                                : null,
                            iconSize: 20, 
                            padding: EdgeInsets.all(4),
                            constraints: BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10), // 간격 유지
            // 테이블 높이를 상태별 현황 차트와 동일하게 맞춤
            SizedBox(
              height: 200, // 이전에는 275였지만 VOC 분류별 현황과 동일한 높이로 수정
              child: pendingVocs.isEmpty
                ? const Center(
                    child: Text('진행 중이거나 보류 중인 VOC가 없습니다.', style: TextStyle(fontSize: 13)),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min, // 최소 크기로 제한
                    children: [
                      // 테이블 헤더
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14), // 패딩 유지
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                '등록일',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // 폰트 크기 유지
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '상태',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // 폰트 크기 유지
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '요청내용',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // 폰트 크기 유지
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '완료일정',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // 폰트 크기 유지
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 테이블 본문
                      Expanded(
                        child: ValueListenableBuilder<int>(
                          valueListenable: currentPage,
                          builder: (context, page, _) {
                            final paginatedVocs = getPaginatedData();
                            // 항상 5개 행의 높이를 가진 영역 유지 (빈 행도 표시)
                            return ListView.builder( // Column 대신 ListView 사용
                              shrinkWrap: true, // 내부 콘텐츠에 맞게 크기 조정
                              physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                              itemCount: rowsPerPage,
                              itemBuilder: (context, i) {
                                return i < paginatedVocs.length
                                  ? _buildVocRow(paginatedVocs[i])
                                  : _buildEmptyRow(); // 비어 있는 행도 공간 차지하도록
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
  
  // VOC 행 항목 위젯 (코드 재사용을 위해 분리)
  Widget _buildVocRow(VocModel voc) {
    // 상태에 따른 색상 지정
    final Map<String, Color> statusColors = {
      '진행중': Colors.orange,
      '보류': Colors.red,
      '완료': Colors.green,
      '접수': Colors.blue,
      '취소': Colors.purple,
    };
    
    // 상태별 배경색과 텍스트 색상
    final backgroundColor = statusColors[voc.status]?.withOpacity(0.15) ?? Colors.grey.shade100;
    final textColor = statusColors[voc.status] ?? Colors.grey.shade800;
    
    return Container(
      height: 32, // 행 높이 증가
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14), // 패딩 증가
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('yyyy-MM-dd').format(voc.regDate),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13), // 폰트 크기 증가
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2), // 패딩 증가
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                voc.status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13, // 폰트 크기 증가
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              voc.request,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13), // 폰트 크기 증가
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              voc.dueDate != null 
                ? DateFormat('yyyy-MM-dd').format(voc.dueDate!)
                : '-',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13), // 폰트 크기 증가
            ),
          ),
        ],
      ),
    );
  }
  
  // 빈 행 위젯
  Widget _buildEmptyRow() {
    return Container(
      height: 32, // 행 높이 증가
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14), // 패딩 증가
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
    );
  }
  
  // 바 차트 위젯
  Widget _buildBarChart(Map<String, int> data) {
    // 데이터 정렬 (값 기준 내림차순)
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final entry = sortedEntries[groupIndex];
              return BarTooltipItem(
                '${entry.key}: ${entry.value}건',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= sortedEntries.length) {
                  return const SizedBox();
                }
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    sortedEntries[value.toInt()].key,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == value.roundToDouble()) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: List.generate(sortedEntries.length, (index) {
          final entry = sortedEntries[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: Colors.blue.withOpacity(0.7),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  // 라인 차트 위젯
  Widget _buildLineChart() {
    if (_dailyCount.isEmpty) {
      return const Center(child: Text('데이터가 없습니다'));
    }
    
    // x축 간격 계산 (최소 7일)
    final daysCount = _dailyCount.length;
    int interval = (daysCount / 7).ceil();
    if (interval == 0) interval = 1;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: interval.toDouble(),
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= _dailyCount.length) {
                  return const SizedBox();
                }
                
                final date = _dailyCount[value.toInt()].key;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        minX: 0,
        maxX: (_dailyCount.length - 1).toDouble(),
        minY: 0,
        maxY: _dailyCount.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(_dailyCount.length, (index) {
              return FlSpot(
                index.toDouble(),
                _dailyCount[index].value.toDouble(),
              );
            }),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blue,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final date = _dailyCount[spot.x.toInt()].key;
                final count = spot.y.toInt();
                return LineTooltipItem(
                  '${DateFormat('yyyy-MM-dd').format(date)}\n$count건',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
} 