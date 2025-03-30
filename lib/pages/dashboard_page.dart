import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/voc_model.dart';
import '../services/api_service.dart';

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
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _selectedPeriodStart,
        end: _selectedPeriodEnd,
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedPeriodStart = picked.start;
        _selectedPeriodEnd = picked.end;
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
        // 기간 정보
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
        
        // KPI 카드 행
        Row(
          children: [
            // 미처리 VOC
            Expanded(
              child: _buildKpiCard(
                '미처리 VOC',
                _vocData.where((voc) => voc.status != '완료').length.toString(),
                Colors.orange,
                Icons.pending_actions,
              ),
            ),
            const SizedBox(width: 16),
            // 당일 등록 VOC
            Expanded(
              child: _buildKpiCard(
                '당일 등록 VOC',
                _vocData.where((voc) {
                  final today = DateTime.now();
                  final regDate = voc.regDate;
                  return regDate.year == today.year && 
                         regDate.month == today.month && 
                         regDate.day == today.day;
                }).length.toString(),
                Colors.green,
                Icons.today,
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
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 상태별 현황 파이 차트
        if (_statusCount.isNotEmpty)
          _buildChartCard(
            '상태별 현황',
            _buildPieChart(_statusCount),
            Icons.pie_chart,
          ),
        
        const SizedBox(height: 16),
        
        // VOC 분류별 현황 바 차트
        if (_categoryCount.isNotEmpty)
          _buildChartCard(
            'VOC 분류별 현황',
            _buildBarChart(_categoryCount),
            Icons.bar_chart,
          ),
        
        const SizedBox(height: 16),
        
        // 요청유형별 현황 바 차트
        if (_requestTypeCount.isNotEmpty)
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
              height: 250,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
  
  // 파이 차트 위젯
  Widget _buildPieChart(Map<String, int> data) {
    // 차트 데이터 색상
    final List<Color> chartColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    
    return Row(
      children: [
        // 파이 차트
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: List.generate(data.keys.length, (index) {
                final key = data.keys.elementAt(index);
                final value = data[key] ?? 0;
                final total = data.values.fold(0, (sum, value) => sum + value);
                final percentage = total > 0 ? (value / total * 100) : 0;
                
                return PieChartSectionData(
                  color: chartColors[index % chartColors.length],
                  value: value.toDouble(),
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        
        // 범례
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(data.keys.length, (index) {
              final key = data.keys.elementAt(index);
              final value = data[key] ?? 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: chartColors[index % chartColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        key,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$value건',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
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