import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart' hide Border;
import 'package:excel/excel.dart' hide Border;

import '../models/equipment_connection_model.dart';
import '../services/api_service.dart';
import '../widgets/data_table_widget.dart';

// 설비 연동관리 페이지
class EquipmentConnectionPage extends StatefulWidget {
  const EquipmentConnectionPage({Key? key}) : super(key: key);

  @override
  State<EquipmentConnectionPage> createState() => _EquipmentConnectionPageState();
}

class _EquipmentConnectionPageState extends State<EquipmentConnectionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _connectionTabs = ['데이터 관리', '종합현황'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _connectionTabs.length, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설비 연동관리'),
        titleSpacing: 16.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _connectionTabs.map((tabName) => Tab(text: tabName)).toList(),
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          padding: const EdgeInsets.only(left: 16.0),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Theme.of(context).primaryColor,
          dividerColor: Colors.transparent,
        ),
        elevation: 1,
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          EquipmentConnectionDataPage(),
          EquipmentConnectionDashboardPage(),
        ],
      ),
    );
  }
}

// 설비 연동관리 데이터 페이지
class EquipmentConnectionDataPage extends StatefulWidget {
  const EquipmentConnectionDataPage({Key? key}) : super(key: key);

  @override
  State<EquipmentConnectionDataPage> createState() => _EquipmentConnectionDataPageState();
}

class _EquipmentConnectionDataPageState extends State<EquipmentConnectionDataPage> {
  // API 서비스
  final ApiService _apiService = ApiService();
  
  // 설비 연동 데이터
  List<EquipmentConnectionModel> _connectionData = [];
  
  // 선택된 항목 코드 목록
  final Set<String> _selectedConnectionCodes = <String>{};
  
  // 그리드 상태 관리자
  PlutoGridStateManager? _gridStateManager;
  
  // 페이지네이션 및 필터 상태
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _rowsPerPage = 20;
  
  // 필터 상태
  final TextEditingController _searchController = TextEditingController();
  String? _selectedLine;
  String? _selectedEquipment;
  String? _selectedWorkType;
  String? _selectedDataType;
  String? _selectedConnectionType;
  String? _selectedStatus;
  
  // 데이터 테이블 관련
  List<PlutoColumn> _columns = [];
  
  // 필터링을 위한 리스트
  List<String> _lines = [];
  List<String> _equipments = [];
  
  // 디바운서
  Timer? _debounce;
  Timer? _debounceTimer;
  
  // 로딩 상태 및 기타 플래그
  bool _isLoading = false;
  bool _hasSelectedItems = false;
  bool _unsavedChanges = false;
  
  // 행 키로 설비 연동 데이터 찾기
  EquipmentConnectionModel? _findEquipmentConnectionByRowKey(String rowKey) {
    final index = _connectionData.indexWhere((item) => item.code == rowKey);
    if (index >= 0) {
      return _connectionData[index];
    }
    return null;
  }
  
  // 설비 연동 데이터 저장
  Future<bool> _saveEquipmentConnection(EquipmentConnectionModel connection) async {
    try {
      final result = connection.isNew
          ? await _apiService.addEquipmentConnection(connection)
          : await _apiService.updateEquipmentConnection(connection);
      
      if (result != null) {
        final index = _connectionData.indexWhere((item) => item.code == connection.code);
        if (index >= 0) {
          setState(() {
            _connectionData[index] = result.copyWith(
              isModified: false, 
              isNew: false
            );
            _unsavedChanges = _connectionData.any((item) => item.isModified || item.isNew);
          });
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('설비 연동 데이터 저장 오류: $e');
      return false;
    }
  }
  
  @override
  void initState() {
    super.initState();
    _initColumns();
    _loadConnectionData();
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    _debounceTimer?.cancel();
    _searchController.dispose();
    _gridStateManager = null;
    super.dispose();
  }
  
  // 초기 컬럼 설정
  void _initColumns() {
    final workTypes = [
      'MES 자동투입',
      'SPC',
      '설비조건데이터',
      '기타'
    ];
    
    final dataTypes = [
      'PLC',
      'CSV',
      '기타'
    ];
    
    final connectionTypes = [
      'DataAgent',
      'X-DAS',
      'X-SCADA',
      '기타'
    ];
    
    final statusTypes = [
      '대기',
      '진행중',
      '완료',
      '보류'
    ];
    
    _columns = [
      PlutoColumn(
        title: '',
        field: 'selected',
        type: PlutoColumnType.text(),
        width: 40,
        enableSorting: false,
        enableFilterMenuItem: false,
        renderer: (rendererContext) {
          return Checkbox(
            value: rendererContext.cell.value == 'true',
            onChanged: (bool? value) {
              final code = rendererContext.row.cells['code']!.value.toString();
              setState(() {
                if (value ?? false) {
                  _selectedConnectionCodes.add(code);
                } else {
                  _selectedConnectionCodes.remove(code);
                }
                _hasSelectedItems = _selectedConnectionCodes.isNotEmpty;
                
                // 셀 값 업데이트
                rendererContext.cell.value = value.toString();
                _gridStateManager?.notifyListeners();
              });
            },
          );
        },
      ),
      PlutoColumn(
        title: 'NO',
        field: 'no',
        type: PlutoColumnType.number(),
        width: 60,
        enableEditingMode: false,
        sort: PlutoColumnSort.descending,
      ),
      PlutoColumn(
        title: '등록일',
        field: 'regDate',
        type: PlutoColumnType.date(format: 'yyyy-MM-dd'),
        width: 100,
      ),
      PlutoColumn(
        title: '코드',
        field: 'code',
        type: PlutoColumnType.text(),
        width: 130,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: '라인',
        field: 'line',
        type: PlutoColumnType.text(),
        width: 100,
      ),
      PlutoColumn(
        title: '설비',
        field: 'equipment',
        type: PlutoColumnType.text(),
        width: 120,
      ),
      PlutoColumn(
        title: '작업유형',
        field: 'workType',
        type: PlutoColumnType.select(workTypes),
        width: 120,
      ),
      PlutoColumn(
        title: '데이터유형',
        field: 'dataType',
        type: PlutoColumnType.select(dataTypes),
        width: 100,
      ),
      PlutoColumn(
        title: '연동유형',
        field: 'connectionType',
        type: PlutoColumnType.select(connectionTypes),
        width: 120,
      ),
      PlutoColumn(
        title: '상태',
        field: 'status',
        type: PlutoColumnType.select(statusTypes),
        width: 100,
      ),
      PlutoColumn(
        title: '세부내용',
        field: 'detail',
        type: PlutoColumnType.text(),
        width: 200,
      ),
      PlutoColumn(
        title: '시작일',
        field: 'startDate',
        type: PlutoColumnType.date(format: 'yyyy-MM-dd'),
        width: 120,
        renderer: (rendererContext) {
          dynamic cellValue = rendererContext.cell.value;
          DateTime? date;
          
          if (cellValue is DateTime) {
            date = cellValue;
          } else if (cellValue is String && cellValue.isNotEmpty) {
            try {
              date = DateTime.parse(cellValue);
            } catch (e) {
              date = null;
            }
          }
          
          final displayText = date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              displayText,
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      ),
      PlutoColumn(
        title: '완료일',
        field: 'completionDate',
        type: PlutoColumnType.date(format: 'yyyy-MM-dd'),
        width: 120,
        renderer: (rendererContext) {
          dynamic cellValue = rendererContext.cell.value;
          DateTime? date;
          
          if (cellValue is DateTime) {
            date = cellValue;
          } else if (cellValue is String && cellValue.isNotEmpty) {
            try {
              date = DateTime.parse(cellValue);
            } catch (e) {
              date = null;
            }
          }
          
          final displayText = date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              displayText,
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      ),
      PlutoColumn(
        title: '비고',
        field: 'remarks',
        type: PlutoColumnType.text(),
        width: 200,
      ),
    ];
  }
  
  // 설비 연동 데이터 로드
  Future<void> _loadConnectionData() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        setState(() { _isLoading = true; });
        
        // API 호출
        final data = await _apiService.fetchEquipmentConnections(
          search: _searchController.text.isNotEmpty ? _searchController.text : null,
          line: _selectedLine,
          equipment: _selectedEquipment,
          workType: _selectedWorkType,
          dataType: _selectedDataType,
          connectionType: _selectedConnectionType,
          status: _selectedStatus,
        );
        
        if (mounted) {
          setState(() {
            _connectionData.clear();
            _connectionData.addAll(data);
            _totalPages = math.max(1, (_connectionData.length / _rowsPerPage).ceil());
            
            if (_currentPage > _totalPages) {
              _currentPage = _totalPages;
            }
            
            // 라인과 설비 목록 추출
            _lines = _extractUniqueValues(data, (item) => item.line);
            _equipments = _extractUniqueValues(data, (item) => item.equipment);
            
            _isLoading = false;
          });
          
          _refreshGrid();
        }
      } catch (e) {
        if (mounted) {
          setState(() { _isLoading = false; });
          debugPrint('설비 연동 데이터 로드 오류: $e');
        }
      }
    });
  }
  
  // 고유한 값 추출 헬퍼 함수
  List<String> _extractUniqueValues(List<EquipmentConnectionModel> data, String Function(EquipmentConnectionModel) selector) {
    final values = data.map(selector).toSet().toList();
    values.sort();
    return values;
  }
  
  // 그리드 행 데이터 생성
  List<PlutoRow> _getGridRows() {
    final startIdx = (_currentPage - 1) * _rowsPerPage;
    final endIdx = math.min(startIdx + _rowsPerPage, _connectionData.length);
    
    if (startIdx >= _connectionData.length) {
      return [];
    }
    
    final displayData = _connectionData.sublist(startIdx, endIdx);
    
    return displayData.map((item) => PlutoRow(cells: {
      'selected': PlutoCell(value: _selectedConnectionCodes.contains(item.code) ? 'true' : 'false'),
      'no': PlutoCell(value: item.no),
      'regDate': PlutoCell(value: item.regDate),
      'code': PlutoCell(value: item.code ?? ''),
      'line': PlutoCell(value: item.line),
      'equipment': PlutoCell(value: item.equipment),
      'workType': PlutoCell(value: item.workType),
      'dataType': PlutoCell(value: item.dataType),
      'connectionType': PlutoCell(value: item.connectionType),
      'status': PlutoCell(value: item.status),
      'detail': PlutoCell(value: item.detail),
      'startDate': PlutoCell(value: item.startDate),
      'completionDate': PlutoCell(value: item.completionDate),
      'remarks': PlutoCell(value: item.remarks),
    })).toList();
  }
  
  // 셀 값 변경 처리
  Future<void> _handleCellChanged(PlutoGridOnChangedEvent event) async {
    // 셀 값을 즉시 UI에 반영
    event.row.cells[event.column.field]!.value = event.value;
    
    // 변경된 행 데이터 찾기
    final rowKey = event.row.cells['code']!.value.toString();
    final connectionIndex = _connectionData.indexWhere((item) => item.code == rowKey);
    if (connectionIndex < 0) return;
    
    final rowData = _connectionData[connectionIndex];

    // 변경된 필드에 따라 데이터 업데이트 (copyWith 사용)
    EquipmentConnectionModel updatedData;
    switch (event.column.field) {
      case 'line':
        updatedData = rowData.copyWith(line: event.value.toString(), isModified: true);
        break;
      case 'equipment':
        updatedData = rowData.copyWith(equipment: event.value.toString(), isModified: true);
        break;
      case 'workType':
        updatedData = rowData.copyWith(workType: event.value.toString(), isModified: true);
        break;
      case 'dataType':
        updatedData = rowData.copyWith(dataType: event.value.toString(), isModified: true);
        break;
      case 'connectionType':
        updatedData = rowData.copyWith(connectionType: event.value.toString(), isModified: true);
        break;
      case 'status':
        updatedData = rowData.copyWith(status: event.value.toString(), isModified: true);
        break;
      case 'detail':
        updatedData = rowData.copyWith(detail: event.value.toString(), isModified: true);
        break;
      case 'startDate':
        updatedData = rowData.copyWith(startDate: event.value is DateTime ? event.value : null, isModified: true);
        break;
      case 'completionDate':
        updatedData = rowData.copyWith(completionDate: event.value is DateTime ? event.value : null, isModified: true);
        break;
      case 'remarks':
        updatedData = rowData.copyWith(remarks: event.value.toString(), isModified: true);
        break;
      default:
        return; // 수정 가능한 필드가 아니면 무시
    }

    // 업데이트된 데이터로 배열 갱신
    setState(() {
      _connectionData[connectionIndex] = updatedData;
      _unsavedChanges = true;
    });

    // 그리드 상태 관리자에게 변경 알림 (UI 새로고침)
    _gridStateManager?.notifyListeners();
  }
  
  // 그리드 새로고침
  void _refreshGrid() {
    if (!mounted || _gridStateManager == null) return;
    
    try {
      _gridStateManager!.removeAllRows();
      _gridStateManager!.appendRows(_getGridRows());
      
      // 스크롤을 맨 위로 이동 (안전하게 처리)
      if (_gridStateManager!.scroll.vertical != null) {
        _gridStateManager!.scroll.vertical!.jumpTo(0);
      }
      
      // 그리드 상태 관리자에 변경 알림
      _gridStateManager!.notifyListeners();
    } catch (e) {
      debugPrint('그리드 새로고침 오류: $e');
    }
  }
  
  // 새 항목 추가
  void _addNewConnection() {
    final now = DateTime.now();
    int newNo = 1;
    
    if (_connectionData.isNotEmpty) {
      newNo = _connectionData.map((e) => e.no).reduce((value, element) => value > element ? value : element) + 1;
    }
    
    final String code = 'EQC-${now.year.toString().substring(2)}${(now.month).toString().padLeft(2, '0')}-${newNo.toString().padLeft(3, '0')}';
    
    final newConnection = EquipmentConnectionModel(
      no: newNo,
      regDate: now,
      code: code,
      line: '',
      equipment: '',
      workType: 'MES 자동투입',
      dataType: 'PLC',
      connectionType: 'DataAgent',
      status: '대기',
      detail: '',
      startDate: now,
      remarks: '',
      isNew: true,
      isModified: true,
    );
    
    setState(() {
      _connectionData.insert(0, newConnection);
      _currentPage = 1; // 첫 페이지로 이동
      _totalPages = math.max(1, (_connectionData.length / _rowsPerPage).ceil());
      _unsavedChanges = true;
    });
    
    _refreshGrid();
  }
  
  // 데이터 저장
  Future<void> _saveChanges() async {
    if (!_unsavedChanges) return;
    
    final modifiedData = _connectionData.where((item) => item.isModified || item.isNew).toList();
    if (modifiedData.isEmpty) return;
    
    setState(() { _isLoading = true; });
    
    int savedCount = 0;
    int failedCount = 0;
    
    for (final item in modifiedData) {
      try {
        if (item.isNew) {
          final result = await _apiService.addEquipmentConnection(item);
          if (result != null) {
            final index = _connectionData.indexWhere((e) => e.code == item.code);
            if (index != -1) {
              _connectionData[index] = result.copyWith(isModified: false, isNew: false);
              savedCount++;
            }
          } else {
            failedCount++;
          }
        } else {
          final result = await _apiService.updateEquipmentConnection(item);
          if (result != null) {
            final index = _connectionData.indexWhere((e) => e.code == item.code);
            if (index != -1) {
              _connectionData[index] = result.copyWith(isModified: false);
              savedCount++;
            }
          } else {
            failedCount++;
          }
        }
      } catch (e) {
        debugPrint('설비 연동 데이터 저장 오류: $e');
        failedCount++;
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _unsavedChanges = failedCount > 0;
      });
      
      if (savedCount > 0) {
        debugPrint('설비 연동 데이터 저장 성공: $savedCount개');
      }
      
      if (failedCount > 0) {
        debugPrint('설비 연동 데이터 저장 실패: $failedCount개');
      }
      
      _refreshGrid();
    }
  }
  
  // 선택 항목 삭제
  Future<void> _deleteSelectedItems() async {
    if (_selectedConnectionCodes.isEmpty) return;
    
    // 삭제 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('${_selectedConnectionCodes.length}개 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() { _isLoading = true; });
    
    int deletedCount = 0;
    int failedCount = 0;
    
    for (final code in _selectedConnectionCodes.toList()) {
      try {
        final success = await _apiService.deleteEquipmentConnection(code);
        if (success) {
          _connectionData.removeWhere((item) => item.code == code);
          _selectedConnectionCodes.remove(code);
          deletedCount++;
        } else {
          failedCount++;
        }
      } catch (e) {
        debugPrint('설비 연동 데이터 삭제 오류: $e');
        failedCount++;
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasSelectedItems = _selectedConnectionCodes.isNotEmpty;
        _totalPages = math.max(1, (_connectionData.length / _rowsPerPage).ceil());
        if (_currentPage > _totalPages && _totalPages > 0) {
          _currentPage = _totalPages;
        }
      });
      
      if (deletedCount > 0) {
        debugPrint('설비 연동 데이터 삭제 성공: $deletedCount개');
      }
      
      if (failedCount > 0) {
        debugPrint('설비 연동 데이터 삭제 실패: $failedCount개');
      }
      
      _refreshGrid();
    }
  }

  // 관리자 비밀번호 입력 다이얼로그 표시
  Future<void> _showAdminPasswordDialog() async {
    // 현재는 파일 가져오기를 직접 호출합니다
    // 실제 환경에서는 비밀번호 검증을 구현할 수 있습니다
    _importFromExcel();
  }
  
  // 엑셀 파일에서 데이터 가져오기
  Future<void> _importFromExcel() async {
    try {
      setState(() { _isLoading = true; });
      
      // 파일 선택 대화상자 열기
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      
      if (result == null) {
        setState(() { _isLoading = false; });
        return;
      }
      
      // 파일 바이트 가져오기
      Uint8List bytes;
      if (kIsWeb) {
        bytes = result.files.first.bytes!;
      } else {
        bytes = File(result.files.first.path!).readAsBytesSync();
      }
      
      // 엑셀 파일 파싱
      final excel = Excel.decodeBytes(bytes);
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;
      
      // 헤더 확인 (첫 번째 행 기준)
      List<String> headers = [];
      for (var cell in sheet.rows[0]) {
        headers.add(cell?.value?.toString() ?? '');
      }
      
      // 필수 헤더 확인
      final requiredHeaders = ['라인', '설비', '작업유형', '데이터유형', '연동유형', '상태'];
      final missingHeaders = requiredHeaders.where((header) => !headers.contains(header)).toList();
      
      if (missingHeaders.isNotEmpty) {
        debugPrint('필수 헤더 누락: ${missingHeaders.join(', ')}');
        setState(() { _isLoading = false; });
        return;
      }
      
      // 데이터 행 파싱
      final List<EquipmentConnectionModel> importedData = [];
      int maxNo = _connectionData.isEmpty ? 0 : _connectionData.map((e) => e.no).reduce((a, b) => a > b ? a : b);
      
      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty || row.length < headers.length) continue;
        
        // 빈 셀이 있는 행은 건너뛰기
        if (row.any((cell) => cell == null || cell.value == null)) continue;
        
        // 필드 매핑
        String? line, equipment, workType, dataType, connectionType, status, detail, remarks;
        DateTime? regDate, startDate, completionDate;
        
        for (var j = 0; j < headers.length; j++) {
          final header = headers[j];
          final cellValue = row[j]?.value?.toString() ?? '';
          
          switch (header) {
            case '라인':
              line = cellValue;
              break;
            case '설비':
              equipment = cellValue;
              break;
            case '작업유형':
              workType = cellValue;
              break;
            case '데이터유형':
              dataType = cellValue;
              break;
            case '연동유형':
              connectionType = cellValue;
              break;
            case '상태':
              status = cellValue;
              break;
            case '세부내용':
              detail = cellValue;
              break;
            case '비고':
              remarks = cellValue;
              break;
            case '등록일':
              try {
                regDate = row[j]?.value is DateTime 
                    ? row[j]?.value as DateTime
                    : DateFormat('yyyy-MM-dd').parse(cellValue);
              } catch (e) {
                // 날짜 파싱 오류
              }
              break;
            case '시작일':
              try {
                startDate = row[j]?.value is DateTime 
                    ? row[j]?.value as DateTime
                    : DateFormat('yyyy-MM-dd').parse(cellValue);
              } catch (e) {
                // 날짜 파싱 오류
              }
              break;
            case '완료일':
              try {
                completionDate = row[j]?.value is DateTime 
                    ? row[j]?.value as DateTime
                    : DateFormat('yyyy-MM-dd').parse(cellValue);
              } catch (e) {
                // 날짜 파싱 오류
              }
              break;
          }
        }
        
        // 필수 필드 검증
        if (line == null || equipment == null || workType == null || 
            dataType == null || connectionType == null || status == null) {
          continue;
        }
        
        // 새 모델 생성
        maxNo++;
        final now = DateTime.now();
        final code = 'EQC-${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}-${maxNo.toString().padLeft(3, '0')}';
        
        importedData.add(EquipmentConnectionModel(
          no: maxNo,
          regDate: regDate ?? now,
          code: code,
          line: line,
          equipment: equipment,
          workType: workType,
          dataType: dataType,
          connectionType: connectionType,
          status: status,
          detail: detail ?? '',
          startDate: startDate ?? now,
          completionDate: completionDate,
          remarks: remarks ?? '',
          isNew: true,
          isModified: true,
        ));
      }
      
      // 가져온 데이터가 없는 경우
      if (importedData.isEmpty) {
        debugPrint('가져올 데이터가 없습니다');
        setState(() { _isLoading = false; });
        return;
      }
      
      // 데이터 추가
      setState(() {
        _connectionData.insertAll(0, importedData);
        _currentPage = 1;
        _totalPages = math.max(1, (_connectionData.length / _rowsPerPage).ceil());
        _unsavedChanges = true;
        _isLoading = false;
      });
      
      _refreshGrid();
      debugPrint('${importedData.length}개 항목 가져오기 완료');
      
    } catch (e) {
      debugPrint('엑셀 가져오기 오류: $e');
      setState(() { _isLoading = false; });
    }
  }

  // 데이터 탭 UI 빌드 (컴포넌트 사용)
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. 필터 위젯
        EquipmentFilterWidget(
          searchController: _searchController,
          selectedLine: _selectedLine,
          selectedEquipment: _selectedEquipment,
          selectedStatus: _selectedStatus,
          lines: _lines,
          equipments: _equipments,
          onLineChanged: (value) {
            setState(() {
              _selectedLine = value;
              _currentPage = 1;
              _loadConnectionData();
            });
          },
          onEquipmentChanged: (value) {
            setState(() {
              _selectedEquipment = value;
              _currentPage = 1;
              _loadConnectionData();
            });
          },
          onStatusChanged: (value) {
            setState(() {
              _selectedStatus = value;
              _currentPage = 1;
              _loadConnectionData();
            });
          },
          onSearchChanged: () {
            setState(() {
              _currentPage = 1;
              _loadConnectionData();
            });
          },
        ),
        
        // 2. 실행 버튼 위젯
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ActionButtonsWidget(
                  hasSelection: _hasSelectedItems,
                  hasUnsavedChanges: _unsavedChanges,
                  isAdmin: true,
                  onAddRow: _addNewConnection,
                  onSaveChanges: _saveChanges,
                  onDeleteSelected: _deleteSelectedItems,
                  onExportExcel: _exportToExcel,
                  onImportExcel: _showAdminPasswordDialog,
                  totalItems: _connectionData.length,
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                ),
              ),
            ],
          ),
        ),
        
        // 3. 데이터 테이블 및 범례
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _connectionData.isEmpty
              ? _buildEmptyDataView() // 데이터가 없을 때 빈 데이터 화면 표시
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CommonDataTableWidget(
                    columns: _columns,
                    rows: _getGridRows(),
                    currentPage: _currentPage - 1, // CommonDataTableWidget은 0부터 시작하므로 1을 빼줍니다
                    totalPages: _totalPages,
                    hasUnsavedChanges: _unsavedChanges,
                    onChanged: _handleCellChanged,
                    onPageChanged: (page) => _changePage(page + 1), // 페이지 번호에 1을 더해 _changePage 호출
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      _gridStateManager = event.stateManager;
                      event.stateManager.setSelectingMode(PlutoGridSelectingMode.row);
                    },
                    onRowChecked: (PlutoGridOnRowCheckedEvent event) {
                      if (event.row != null) {
                        _toggleRowSelection(event.row!);
                      }
                    },
                    legendItems: [
                      LegendItem(label: '작업 중', color: Colors.yellow.shade100),
                      LegendItem(label: '완료', color: Colors.green.shade100),
                      LegendItem(label: '보류', color: Colors.red.shade100),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // 데이터가 없을 때 표시할 뷰
  Widget _buildEmptyDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings_ethernet_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '데이터가 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아래 버튼을 클릭하여 새 설비 연동 데이터를 추가해보세요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewConnection,
            icon: const Icon(Icons.add),
            label: const Text('첫 데이터 추가하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // EquipmentConnectionDataPage 클래스에서 _toggleRowSelection 함수 추가
  void _toggleRowSelection(PlutoRow row) {
    final code = row.cells['code']?.value as String?;
    if (code != null) {
      setState(() {
        if (_selectedConnectionCodes.contains(code)) {
          _selectedConnectionCodes.remove(code);
        } else {
          _selectedConnectionCodes.add(code);
        }
      });
    }
  }

  // 페이지 변경
  void _changePage(int page) {
    if (page < 0 || (_totalPages > 0 && page >= _totalPages)) return;
    
    setState(() {
      _currentPage = page;
    });
    
    _refreshGrid();
  }

  // 엑셀 내보내기
  Future<void> _exportToExcel() async {
    if (_connectionData.isEmpty) {
      debugPrint('내보낼 데이터가 없습니다');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 엑셀 생성
      final excel = Excel.createExcel();
      final sheet = excel['설비 연동관리'];

      // 헤더 설정
      final headers = [
        '등록일', '코드', '라인', '설비', '작업유형', '데이터유형', 
        '연동유형', '상태', '세부내용', '시작일', '완료일', '비고'
      ];

      // 헤더 스타일 생성
      final headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );

      // 헤더 추가
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // 데이터 포맷터
      final dateFormat = DateFormat('yyyy-MM-dd');

      // 데이터 추가
      for (var i = 0; i < _connectionData.length; i++) {
        final data = _connectionData[i];
        final rowIndex = i + 1;
        
        // 등록일
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(dateFormat.format(data.regDate));
        
        // 코드
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(data.code ?? '');
        
        // 라인
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(data.line);
        
        // 설비
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(data.equipment);
        
        // 작업유형
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = TextCellValue(data.workType);
        
        // 데이터유형
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(data.dataType);
        
        // 연동유형
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = TextCellValue(data.connectionType);
        
        // 상태
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = TextCellValue(data.status);
        
        // 세부내용
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = TextCellValue(data.detail);
        
        // 시작일
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = data.startDate != null 
                ? TextCellValue(dateFormat.format(data.startDate!))
                : TextCellValue('');
        
        // 완료일
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
            .value = data.completionDate != null 
                ? TextCellValue(dateFormat.format(data.completionDate!))
                : TextCellValue('');
        
        // 비고
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex))
            .value = TextCellValue(data.remarks);
      }

      // 열 너비 자동 조정
      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15);
      }

      // 엑셀 파일 내보내기
      final excelBytes = excel.encode();
      if (excelBytes == null) {
        throw Exception('엑셀 파일 생성 실패');
      }

      // 파일명 생성
      final now = DateTime.now();
      final fileName = '설비연동관리_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.xlsx';

      // 파일 저장
      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: Uint8List.fromList(excelBytes),
          ext: 'xlsx',
          mimeType: MimeType.microsoftExcel
        );
      } else {
        // 데스크톱/모바일용 구현 (파일 다이얼로그 열기)
        final result = await FilePicker.platform.saveFile(
          dialogTitle: '엑셀 파일 저장',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (result != null) {
          final file = File(result);
          await file.writeAsBytes(excelBytes);
        }
      }

      debugPrint('엑셀 파일 내보내기 완료');
    } catch (e) {
      debugPrint('엑셀 내보내기 오류: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }
}

// 설비 연동관리 대시보드 페이지
class EquipmentConnectionDashboardPage extends StatefulWidget {
  const EquipmentConnectionDashboardPage({Key? key}) : super(key: key);

  @override
  State<EquipmentConnectionDashboardPage> createState() => _EquipmentConnectionDashboardPageState();
}

class _EquipmentConnectionDashboardPageState extends State<EquipmentConnectionDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('설비 연동관리 대시보드 (개발 중)'),
    );
  }
}

// 설비 필터 위젯
class EquipmentFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedLine;
  final String? selectedEquipment;
  final String? selectedStatus;
  final List<String> lines;
  final List<String> equipments;
  final ValueChanged<String?> onLineChanged;
  final ValueChanged<String?> onEquipmentChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onSearchChanged;

  const EquipmentFilterWidget({
    Key? key,
    required this.searchController,
    required this.selectedLine,
    required this.selectedEquipment,
    required this.selectedStatus,
    required this.lines,
    required this.equipments,
    required this.onLineChanged,
    required this.onEquipmentChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // 상태분류 필터
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '상태분류',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: selectedStatus,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ...['대기', '진행중', '완료', '보류'].map((status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                )),
              ],
              onChanged: onStatusChanged,
            ),
          ),
          const SizedBox(width: 12),
          
          // 비용형태 필터 (라인 필드를 재활용)
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '비용형태',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: selectedLine,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ...lines.map((line) => DropdownMenuItem<String>(
                  value: line,
                  child: Text(line),
                )),
              ],
              onChanged: onLineChanged,
            ),
          ),
          const SizedBox(width: 12),
          
          // 통합검색
          Expanded(
            flex: 3,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: '통합검색',
                hintText: '검색어 입력',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: (_) {
                onSearchChanged();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 실행 버튼 위젯
class ActionButtonsWidget extends StatelessWidget {
  final bool hasSelection;
  final bool hasUnsavedChanges;
  final bool isAdmin;
  final VoidCallback onAddRow;
  final VoidCallback onSaveChanges;
  final VoidCallback onDeleteSelected;
  final VoidCallback onExportExcel;
  final VoidCallback onImportExcel;
  final int totalItems;
  final int currentPage;
  final int totalPages;

  const ActionButtonsWidget({
    Key? key,
    required this.hasSelection,
    required this.hasUnsavedChanges,
    this.isAdmin = false,
    required this.onAddRow,
    required this.onSaveChanges,
    required this.onDeleteSelected,
    required this.onExportExcel,
    required this.onImportExcel,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 제목과 정보
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '설비 연동관리',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '전체 ${totalItems}개 항목, ${currentPage}/${totalPages} 페이지',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        
        // 버튼 그룹
        Row(
          children: [
            // 행 추가 버튼
            ElevatedButton.icon(
              onPressed: onAddRow,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text('행 추가', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            
            // 데이터 저장 버튼
            ElevatedButton.icon(
              onPressed: hasUnsavedChanges ? onSaveChanges : null,
              icon: Icon(Icons.save, color: hasUnsavedChanges ? Colors.yellow : Colors.white),
              label: Text(
                '데이터 저장${hasUnsavedChanges ? ' *' : ''}',
                style: TextStyle(
                  fontWeight: hasUnsavedChanges ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasUnsavedChanges ? Colors.blue.shade700 : null,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            
            // 행 삭제 버튼
            ElevatedButton.icon(
              onPressed: hasSelection ? onDeleteSelected : null,
              icon: const Icon(Icons.delete_outline),
              label: const Text('행 삭제'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.red.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 8),
            
            // 엑셀 내보내기 버튼
            ElevatedButton.icon(
              onPressed: onExportExcel,
              icon: const Icon(Icons.file_download),
              label: const Text('엑셀 다운로드'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(width: 8),
              
              // 엑셀 가져오기 버튼 (관리자만)
              ElevatedButton.icon(
                onPressed: onImportExcel,
                icon: const Icon(Icons.file_upload),
                label: const Text('엑셀 업로드'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
} 