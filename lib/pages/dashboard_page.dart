import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/voc_model.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class DashboardPage extends StatefulWidget {
  final List<VocModel> vocData; // 전달받을 VOC 데이터

  const DashboardPage({Key? key, required this.vocData}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<VocModel> _filteredVocData = []; // 필터링된 데이터 저장
  bool _isLoading = false; // 로딩 상태는 외부에서 관리하므로 false로 초기화
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
    // initState에서 데이터 로드 대신, 전달받은 데이터로 초기 필터링 및 차트 처리
    _filterAndProcessData();
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 상위 위젯에서 데이터가 변경되면 다시 필터링 및 차트 처리
    if (widget.vocData != oldWidget.vocData) {
      _filterAndProcessData();
    }
  }
  
  // 전달받은 데이터 필터링 및 차트 데이터 처리
  void _filterAndProcessData() {
    setState(() {
      _isLoading = true; // 처리 시작 시 로딩 표시
    });

    // 선택된 기간으로 데이터 필터링
    _filteredVocData = widget.vocData.where((voc) {
      return !voc.regDate.isBefore(_selectedPeriodStart) && 
             !voc.regDate.isAfter(_selectedPeriodEnd.add(const Duration(days: 1))); // endDate 포함
    }).toList();

    _processChartData();

    setState(() {
      _isLoading = false; // 처리 완료 시 로딩 해제
    });
  }

  // VOC 데이터 로드 함수 제거 또는 주석 처리
  /*
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
  */
  
  // 차트 데이터 처리 (필터링된 데이터 사용)
  void _processChartData() {
    if (_filteredVocData.isEmpty) {
      // 데이터가 없으면 차트 초기화
      _categoryCount = {};
      _requestTypeCount = {};
      _statusCount = {};
      _dailyCount = [];
      setState(() {});
      return;
    }
    
    // 카운트 초기화
    _categoryCount = {};
    _requestTypeCount = {};
    _statusCount = {};
    Map<String, int> dailyCountMap = {};
    
    // 데이터 집계 (_filteredVocData 사용)
    for (final voc in _filteredVocData) {
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
    
    setState(() {}); // 차트 업데이트
  }
  
  // 날짜 선택 다이얼로그 (선택 후 _filterAndProcessData 호출)
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
      _filterAndProcessData(); // 날짜 변경 후 데이터 다시 필터링 및 처리
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
          // 새로고침 버튼 제거 또는 다른 기능으로 대체 가능
          /*IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () => _filterAndProcessData(), // 전달받은 데이터로 다시 처리
          ),*/
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _buildDashboard(),
    );
  }
  
  // 대시보드 빌드 (필터링된 데이터 사용)
  Widget _buildDashboard() {
    // _vocData 대신 _filteredVocData 사용하도록 KPI 카드 등 수정 필요
    int totalVocInPeriod = _filteredVocData.length;
    int completedVoc = _filteredVocData.where((voc) => voc.status == '완료').length;
    double completionRate = totalVocInPeriod > 0 ? (completedVoc / totalVocInPeriod) * 100 : 0;
    double avgProcessingDays = 0;
    if (completedVoc > 0) {
      final processingDays = _filteredVocData
          .where((voc) => voc.status == '완료')
          .map((voc) => voc.dueDate.difference(voc.regDate).inDays)
          .toList();
      avgProcessingDays = processingDays.reduce((a, b) => a + b) / completedVoc;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // KPI 카드 행 (데이터 소스를 _filteredVocData로 변경)
        Row(
          children: [
            // 기간 내 총 VOC
            Expanded(
              child: _buildKpiCard(
                '기간 내 총 VOC',
                totalVocInPeriod.toString(),
                Colors.blue,
                Icons.list_alt,
              ),
            ),
            const SizedBox(width: 16),
            // 완료 건수
            Expanded(
              child: _buildKpiCard(
                '완료 건수',
                completedVoc.toString(),
                Colors.green,
                Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 16),
            // 처리율
            Expanded(
              child: _buildKpiCard(
                '처리율',
                '${completionRate.toStringAsFixed(1)}%',
                Colors.orange,
                Icons.donut_large,
              ),
            ),
            const SizedBox(width: 16),
            // 평균 처리일
            Expanded(
              child: _buildKpiCard(
                '평균 처리일',
                '${avgProcessingDays.toStringAsFixed(1)}일',
                Colors.red,
                Icons.timelapse,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 차트 행 1 (분류별, 요청유형별)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VOC 분류별 현황 (원형 차트)
            Expanded(
              child: _buildChartCard(
                'VOC 분류별 현황',
                _buildPieChart(_categoryCount, _getVocCategoryColors()),
              ),
            ),
            const SizedBox(width: 16),
            // 요청 유형별 현황 (막대 차트)
            Expanded(
              child: _buildChartCard(
                '요청 유형별 현황',
                _buildBarChart(_requestTypeCount, _getRequestTypeColors()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 차트 행 2 (상태별, 일별 등록)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상태별 현황 (원형 차트)
            Expanded(
              child: _buildChartCard(
                '상태별 현황',
                _buildPieChart(_statusCount, _getStatusColors()),
              ),
            ),
            const SizedBox(width: 16),
            // 일별 등록 현황 (라인 차트)
            Expanded(
              child: _buildChartCard(
                '일별 등록 현황',
                _buildLineChart(_dailyCount),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // KPI 카드 위젯
  Widget _buildKpiCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: color
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 차트 카드 위젯
  Widget _buildChartCard(String title, Widget chartWidget) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250, // 차트 높이 고정
              child: chartWidget,
            ),
          ],
        ),
      ),
    );
  }

  // 원형 차트 빌드
  Widget _buildPieChart(Map<String, int> data, Map<String, Color> colors) {
    if (data.isEmpty) {
      return const Center(child: Text('데이터 없음'));
    }
    
    int total = data.values.fold(0, (sum, item) => sum + item);
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.entries.map((entry) {
          final percentage = total > 0 ? (entry.value / total) * 100 : 0;
          return PieChartSectionData(
            color: colors[entry.key] ?? Colors.grey,
            value: entry.value.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: Colors.white,
            ),
            badgeWidget: Text(entry.key, style: const TextStyle(fontSize: 10)),
            badgePositionPercentageOffset: .98,
          );
        }).toList(),
      ),
    );
  }

  // 막대 차트 빌드
  Widget _buildBarChart(Map<String, int> data, Map<String, Color> colors) {
    if (data.isEmpty) {
      return const Center(child: Text('데이터 없음'));
    }
    
    final maxValue = data.values.isNotEmpty ? data.values.reduce((a, b) => a > b ? a : b).toDouble() : 10.0;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2, // 상단 여유 공간 확보
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String category = data.keys.elementAt(group.x.toInt());
              return BarTooltipItem(
                '$category\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.toY - 1).toString(), // toY는 1부터 시작하므로 1 빼기?
                    style: const TextStyle(color: Colors.yellow, fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.keys.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4.0,
                    child: Text(data.keys.elementAt(index), style: const TextStyle(fontSize: 10)),
                  );
                }
                return Container();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        barGroups: data.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final dataEntry = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: dataEntry.value.toDouble(),
                color: colors[dataEntry.key] ?? Colors.grey,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 라인 차트 빌드
  Widget _buildLineChart(List<MapEntry<DateTime, int>> data) {
    if (data.isEmpty) {
      return const Center(child: Text('데이터 없음'));
    }
    
    final maxValue = data.isNotEmpty ? data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble() : 10.0;
    
    return LineChart(
      LineChartData(
        maxY: maxValue * 1.2,
        minY: 0,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: data.length > 10 ? (data.length / 5).roundToDouble() * Duration.millisecondsPerDay : Duration.millisecondsPerDay.toDouble(), // 데이터 개수에 따라 간격 조절
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                // 첫 번째, 중간, 마지막 날짜만 표시하거나 간격 조절
                if (value == data.first.key.millisecondsSinceEpoch.toDouble() || 
                    value == data.last.key.millisecondsSinceEpoch.toDouble() ||
                    (data.length > 10 && (value - data.first.key.millisecondsSinceEpoch.toDouble()) % (Duration.millisecondsPerDay * (data.length / 5).round()) == 0)) {
                   return SideTitleWidget(
                     axisSide: meta.axisSide,
                     space: 8.0,
                     child: Text(DateFormat('MM/dd').format(date), style: const TextStyle(fontSize: 10)),
                   );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
        lineBarsData: [
          LineChartBarData(
            spots: data.map((entry) => FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value.toDouble())).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
  
  // 색상 맵 (필요에 따라 추가)
  Map<String, Color> _getVocCategoryColors() {
    return {
      'MES 본사': Colors.blue,
      'QMS 본사': Colors.green,
      'MES 베트남': Colors.orange,
      'QMS 베트남': Colors.red,
      '하드웨어': Colors.purple,
      '소프트웨어': Colors.teal,
      '그룹웨어': Colors.pink,
      '통신': Colors.brown,
      '기타': Colors.grey,
    };
  }

  Map<String, Color> _getRequestTypeColors() {
    return {
      '단순문의': Colors.cyan,
      '전산오류': Colors.redAccent,
      '시스템 개발': Colors.lightGreen,
      '업무협의': Colors.amber,
      '데이터수정': Colors.deepPurpleAccent,
      '기타': Colors.blueGrey,
    };
  }

  Map<String, Color> _getStatusColors() {
    return {
      '접수': Colors.grey,
      '진행중': Colors.blue,
      '완료': Colors.green,
      '보류': Colors.orange,
    };
  }
} 