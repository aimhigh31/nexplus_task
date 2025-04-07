import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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
  final ApiService _apiService = ApiService();
  final List<EquipmentConnectionModel> _connectionData = [];
  final Set<String> _selectedConnectionCodes = <String>{};
  final TextEditingController _searchController = TextEditingController();
  
  String? _selectedLine;
  String? _selectedEquipment;
  String? _selectedWorkType;
  String? _selectedDataType;
  String? _selectedConnectionType;
  String? _selectedStatus;
  
  bool _isLoading = true;
  bool _unsavedChanges = false;
  bool _hasSelectedItems = false;
  
  // 페이지네이션 상태
  int _currentPage = 1;
  int _rowsPerPage = 20;
  int _totalPages = 1;
  
  // 데이터 테이블 관련
  PlutoGridStateManager? _gridStateManager;
  List<PlutoColumn> _columns = [];
  
  // 필터링을 위한 리스트
  List<String> _lines = [];
  List<String> _equipments = [];
  
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initColumns();
    _loadConnectionData();
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
  
  // 초기 컬럼 설정
  void _initColumns() {
    _columns = [
      PlutoColumn(
        title: '선택',
        field: 'selected',
        type: PlutoColumnType.text(),
        width: 60,
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
        title: 'No',
        field: 'no',
        type: PlutoColumnType.number(),
        width: 60,
        enableRowChecked: true,
        enableEditingMode: false,
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
        type: PlutoColumnType.text(),
        width: 120,
      ),
      PlutoColumn(
        title: '데이터유형',
        field: 'dataType',
        type: PlutoColumnType.text(),
        width: 100,
      ),
      PlutoColumn(
        title: '연동유형',
        field: 'connectionType',
        type: PlutoColumnType.text(),
        width: 120,
      ),
      PlutoColumn(
        title: '상태',
        field: 'status',
        type: PlutoColumnType.text(),
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
      ),
      PlutoColumn(
        title: '완료일',
        field: 'completionDate',
        type: PlutoColumnType.date(format: 'yyyy-MM-dd'),
        width: 120,
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
          search: _searchController.text,
          line: _selectedLine,
          equipment: _selectedEquipment,
          workType: _selectedWorkType,
          dataType: _selectedDataType,
          connectionType: _selectedConnectionType,
          status: _selectedStatus,
        );
        
        // 필터링 옵션 업데이트
        final lines = data.map((e) => e.line).toSet().toList();
        final equipments = data.map((e) => e.equipment).toSet().toList();
        
        lines.sort();
        equipments.sort();
        
        setState(() {
          _connectionData.clear();
          _connectionData.addAll(data);
          _totalPages = (_connectionData.length / _rowsPerPage).ceil();
          _isLoading = false;
          _lines = lines;
          _equipments = equipments;
          
          // 페이지 번호 조정
          if (_totalPages == 0) {
            _currentPage = 0;
          } else if (_currentPage >= _totalPages) {
            _currentPage = _totalPages - 1;
          }
        });
        
        _refreshPlutoGrid();
      } catch (e) {
        setState(() { _isLoading = false; });
        debugPrint('설비 연동 데이터 로드 실패: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('데이터를 불러오는 중 오류가 발생했습니다: $e'))
          );
        }
      }
    });
  }
  
  // 데이터 필터링
  List<EquipmentConnectionModel> _filterData(List<EquipmentConnectionModel> data) {
    final searchTerm = _searchController.text.toLowerCase();
    
    return data.where((item) {
      // 검색어 필터링
      bool matchesSearch = searchTerm.isEmpty || 
        item.line.toLowerCase().contains(searchTerm) ||
        item.equipment.toLowerCase().contains(searchTerm) ||
        item.code?.toLowerCase().contains(searchTerm) == true ||
        item.workType.toLowerCase().contains(searchTerm) ||
        item.dataType.toLowerCase().contains(searchTerm) ||
        item.connectionType.toLowerCase().contains(searchTerm) ||
        item.status.toLowerCase().contains(searchTerm) ||
        item.detail.toLowerCase().contains(searchTerm);
      
      // 라인 필터링
      bool matchesLine = _selectedLine == null || 
        _selectedLine!.isEmpty ||
        item.line == _selectedLine;
      
      // 설비 필터링
      bool matchesEquipment = _selectedEquipment == null || 
        _selectedEquipment!.isEmpty ||
        item.equipment == _selectedEquipment;

      // 작업유형 필터링
      bool matchesWorkType = _selectedWorkType == null || 
        _selectedWorkType!.isEmpty ||
        item.workType == _selectedWorkType;
      
      // 데이터유형 필터링
      bool matchesDataType = _selectedDataType == null || 
        _selectedDataType!.isEmpty ||
        item.dataType == _selectedDataType;
      
      // 연동유형 필터링
      bool matchesConnectionType = _selectedConnectionType == null || 
        _selectedConnectionType!.isEmpty ||
        item.connectionType == _selectedConnectionType;
      
      // 상태 필터링
      bool matchesStatus = _selectedStatus == null || 
        _selectedStatus!.isEmpty ||
        item.status == _selectedStatus;
      
      return matchesSearch && matchesLine && matchesEquipment 
        && matchesWorkType && matchesDataType 
        && matchesConnectionType && matchesStatus;
    }).toList();
  }
  
  // 페이지네이션된 데이터 가져오기
  List<EquipmentConnectionModel> _paginatedData() {
    if (_connectionData.isEmpty) return [];
    
    final startIndex = _currentPage * _rowsPerPage;
    if (startIndex >= _connectionData.length) return [];
    
    final endIndex = startIndex + _rowsPerPage;
    if (endIndex > _connectionData.length) {
      return _connectionData.sublist(startIndex);
    } else {
      return _connectionData.sublist(startIndex, endIndex);
    }
  }
  
  // 페이지 변경
  void _changePage(int page) {
    if (page < 0 || (_totalPages > 0 && page >= _totalPages)) return;
    
    setState(() {
      _currentPage = page;
    });
    
    _refreshPlutoGrid();
  }
  
  // PlutoGrid 행 데이터 가져오기
  List<PlutoRow> _getPlutoRows() {
    final rows = <PlutoRow>[];
    final paginatedData = _paginatedData();
    
    for (var i = 0; i < paginatedData.length; i++) {
      final item = paginatedData[i];
      final dateFormat = DateFormat('yyyy-MM-dd');
      
      rows.add(PlutoRow(cells: {
        'selected': PlutoCell(value: _selectedConnectionCodes.contains(item.code).toString()),
        'no': PlutoCell(value: item.no),
        'regDate': PlutoCell(value: dateFormat.format(item.regDate)),
        'code': PlutoCell(value: item.code ?? ''),
        'line': PlutoCell(value: item.line),
        'equipment': PlutoCell(value: item.equipment),
        'workType': PlutoCell(value: item.workType),
        'dataType': PlutoCell(value: item.dataType),
        'connectionType': PlutoCell(value: item.connectionType),
        'status': PlutoCell(value: item.status),
        'detail': PlutoCell(value: item.detail),
        'startDate': PlutoCell(
          value: item.startDate != null ? dateFormat.format(item.startDate!) : null
        ),
        'completionDate': PlutoCell(
          value: item.completionDate != null ? dateFormat.format(item.completionDate!) : null
        ),
        'remarks': PlutoCell(value: item.remarks),
      }));
    }
    
    return rows;
  }
  
  // PlutoGrid 새로고침
  void _refreshPlutoGrid() {
    if (_gridStateManager != null) {
      _gridStateManager!.refRows.clear();
      _gridStateManager!.refRows.addAll(_getPlutoRows());
      _gridStateManager!.notifyListeners();
    }
  }
  
  // 셀 변경 처리
  void _handleCellChanged(PlutoGridOnChangedEvent event) {
    try {
      final String? code = event.row?.cells['code']?.value as String?;
      if (code == null) return;
      
      final column = event.column;
      final field = column.field;
      final value = event.value;
      
      setState(() {
        final connectionIndex = _connectionData.indexWhere((c) => c.code == code);
        if (connectionIndex >= 0) {
          var connection = _connectionData[connectionIndex];
          
          switch (field) {
            case 'line':
              _connectionData[connectionIndex] = connection.copyWith(line: value.toString(), isModified: true);
              break;
            case 'equipment':
              _connectionData[connectionIndex] = connection.copyWith(equipment: value.toString(), isModified: true);
              break;
            case 'workType':
              _connectionData[connectionIndex] = connection.copyWith(workType: value.toString(), isModified: true);
              break;
            case 'dataType':
              _connectionData[connectionIndex] = connection.copyWith(dataType: value.toString(), isModified: true);
              break;
            case 'connectionType':
              _connectionData[connectionIndex] = connection.copyWith(connectionType: value.toString(), isModified: true);
              break;
            case 'status':
              _connectionData[connectionIndex] = connection.copyWith(status: value.toString(), isModified: true);
              break;
            case 'detail':
              _connectionData[connectionIndex] = connection.copyWith(detail: value.toString(), isModified: true);
              break;
            case 'regDate':
              try {
                final newDate = DateTime.parse(value.toString());
                _connectionData[connectionIndex] = connection.copyWith(regDate: newDate, isModified: true);
              } catch (e) {
                debugPrint('날짜 형식 오류: $e');
              }
              break;
            case 'startDate':
              try {
                final newDate = value != null && value.toString().isNotEmpty
                  ? DateTime.parse(value.toString())
                  : null;
                _connectionData[connectionIndex] = connection.copyWith(startDate: newDate, isModified: true);
              } catch (e) {
                debugPrint('날짜 형식 오류: $e');
              }
              break;
            case 'completionDate':
              try {
                final newDate = value != null && value.toString().isNotEmpty
                  ? DateTime.parse(value.toString())
                  : null;
                _connectionData[connectionIndex] = connection.copyWith(completionDate: newDate, isModified: true);
              } catch (e) {
                debugPrint('날짜 형식 오류: $e');
              }
              break;
            case 'remarks':
              _connectionData[connectionIndex] = connection.copyWith(remarks: value.toString(), isModified: true);
              break;
          }
          
          _unsavedChanges = true;
        }
      });
    } catch (e) {
      debugPrint('셀 변경 오류: $e');
    }
  }
  
  // 새 행 추가
  void _addEmptyRow() {
    try {
      final now = DateTime.now();
      final maxNo = _connectionData.isEmpty ? 0 : _connectionData.map((e) => e.no).reduce((a, b) => a > b ? a : b);
      
      final newConnection = EquipmentConnectionModel(
        no: maxNo + 1,
        regDate: now,
        code: 'EC-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(maxNo + 1).toString().padLeft(3, '0')}',
        line: '',
        equipment: '',
        workType: EquipmentConnectionModel.workTypes.first,
        dataType: EquipmentConnectionModel.dataTypes.first,
        connectionType: EquipmentConnectionModel.connectionTypes.first,
        status: EquipmentConnectionModel.statusTypes.first,
        detail: '',
        startDate: now,
        completionDate: null,
        remarks: '',
        isModified: true,
        isNew: true,
      );
      
      setState(() {
        _connectionData.add(newConnection);
        _unsavedChanges = true;
        _totalPages = (_connectionData.length / _rowsPerPage).ceil();
        _currentPage = _totalPages - 1; // 마지막 페이지로 이동
      });
      
      _refreshPlutoGrid();
    } catch (e) {
      debugPrint('행 추가 오류: $e');
    }
  }
  
  // 모든 데이터 저장
  Future<void> _saveAllData() async {
    try {
      if (!_unsavedChanges) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장할 변경 사항이 없습니다'))
        );
        return;
      }
      
      setState(() { _isLoading = true; });
      
      // 변경된 항목만 필터링
      final modifiedItems = _connectionData.where((item) => item.isModified).toList();
      if (modifiedItems.isEmpty) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장할 항목이 없습니다'))
        );
        return;
      }
      
      int successCount = 0;
      
      // 각 항목 저장
      for (final item in modifiedItems) {
        if (item.isNew) {
          // 새 항목 생성
          final success = await _apiService.createEquipmentConnection(item);
          if (success) successCount++;
        } else {
          // 기존 항목 업데이트
          final success = await _apiService.updateEquipmentConnection(item);
          if (success) successCount++;
        }
      }
      
      // API에서 최신 데이터 다시 로드
      await _loadConnectionData();
      
      setState(() {
        _unsavedChanges = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 완료 ($successCount/${modifiedItems.length} 항목)'))
      );
    } catch (e) {
      debugPrint('저장 오류: $e');
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류가 발생했습니다: $e'))
      );
    }
  }
  
  // 선택한 행 삭제
  void _deleteSelectedRows() async {
    if (_selectedConnectionCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제할 항목을 선택하세요'))
      );
      return;
    }
    
    // 삭제 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: Text('선택한 ${_selectedConnectionCodes.length}개 항목을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // 선택한 항목 삭제
    final codesToDelete = _selectedConnectionCodes.toList();
    _deleteCodesSequentially(codesToDelete);
  }
  
  void _deleteCodesSequentially(List<String> codes) async {
    int successCount = 0;
    int failCount = 0;
    
    for (final code in codes) {
      try {
        final success = await _apiService.deleteEquipmentConnectionByCode(code);
        if (success) {
          successCount++;
          _connectionData.removeWhere((d) => d.code == code);
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
        debugPrint('설비 연동 데이터 삭제 실패: $e');
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false; 
        _selectedConnectionCodes.clear(); 
        _hasSelectedItems = false;
        _totalPages = (_connectionData.length / _rowsPerPage).ceil();
        if (_totalPages == 0) _currentPage = 0;
        else if (_currentPage >= _totalPages) _currentPage = _totalPages - 1;
      });
      _refreshPlutoGrid();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('선택 항목 삭제 완료 (성공: $successCount, 실패: $failCount)')));
    }
  }

  // 엑셀 내보내기
  Future<void> _exportToExcel() async {
    if (_connectionData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내보낼 데이터가 없습니다.'))
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 엑셀 생성
      final excel = Excel.createExcel();
      final sheet = excel['설비 연동관리'];

      // 헤더 설정
      final headers = [
        'No', '등록일', '코드', '라인', '설비', '작업유형', '데이터유형', 
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

        // No
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(data.no.toString());
        
        // 등록일
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(dateFormat.format(data.regDate));
        
        // 코드
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(data.code ?? '');
        
        // 라인
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(data.line);
        
        // 설비
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = TextCellValue(data.equipment);
        
        // 작업유형
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(data.workType);
        
        // 데이터유형
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = TextCellValue(data.dataType);
        
        // 연동유형
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = TextCellValue(data.connectionType);
        
        // 상태
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = TextCellValue(data.status);
        
        // 세부내용
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = TextCellValue(data.detail);
        
        // 시작일
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
            .value = data.startDate != null 
                ? TextCellValue(dateFormat.format(data.startDate!))
                : TextCellValue('');
        
        // 완료일
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex))
            .value = data.completionDate != null 
                ? TextCellValue(dateFormat.format(data.completionDate!))
                : TextCellValue('');
        
        // 비고
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: rowIndex))
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
      final fileName = '설비연동관리_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.xlsx';

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('엑셀 파일 내보내기 완료'))
      );
    } catch (e) {
      debugPrint('엑셀 내보내기 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('엑셀 내보내기 실패: $e'))
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // 관리자 비밀번호 확인 다이얼로그
  void _showAdminPasswordDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('관리자 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('데이터 가져오기는 관리자 권한이 필요합니다.\n비밀번호를 입력하세요.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '비밀번호 입력',
                border: OutlineInputBorder(),
              ),
            ),
          ]
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소')
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (passwordController.text == 'admin1234') {
                _importExcel();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('비밀번호가 일치하지 않습니다.'))
                );
              }
            },
            child: const Text('확인')
          )
        ]
      )
    );
  }

  // 엑셀 가져오기
  Future<void> _importExcel() async {
    try {
      setState(() { _isLoading = true; });

      // 파일 선택
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() { _isLoading = false; });
        return;
      }

      final file = result.files.first;
      Uint8List bytes;
      
      if (kIsWeb) {
        bytes = file.bytes!;
      } else {
        final filePath = file.path!;
        bytes = await File(filePath).readAsBytes();
      }

      // 엑셀 파일 로드
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        throw Exception('엑셀 파일에 시트가 없습니다.');
      }

      // 첫 번째 시트 사용
      final sheet = excel.tables.entries.first.value;
      final rows = sheet.rows;
      if (rows.isEmpty) {
        throw Exception('엑셀 파일에 데이터가 없습니다.');
      }

      // 헤더 확인
      final headerRow = rows[0];
      final requiredHeaders = [
        'No', '등록일', '코드', '라인', '설비', '작업유형', '데이터유형', 
        '연동유형', '상태', '세부내용', '시작일', '완료일', '비고'
      ];

      if (headerRow.length < requiredHeaders.length) {
        throw Exception('엑셀 파일의 열이 부족합니다.');
      }

      for (var i = 0; i < requiredHeaders.length; i++) {
        if (headerRow[i]?.value.toString().trim() != requiredHeaders[i]) {
          throw Exception('열 헤더가 예상과 다릅니다. 템플릿을 확인하세요.');
        }
      }

      // 데이터 파싱
      final newItems = <EquipmentConnectionModel>[];
      final dateFormat = DateFormat('yyyy-MM-dd');

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || row.length < requiredHeaders.length) continue;

        try {
          final noCell = row[0]?.value?.toString() ?? '';
          if (noCell.isEmpty) continue;

          final no = int.tryParse(noCell) ?? 0;
          final regDateStr = row[1]?.value?.toString() ?? '';
          final code = row[2]?.value?.toString() ?? '';
          final line = row[3]?.value?.toString() ?? '';
          final equipment = row[4]?.value?.toString() ?? '';
          final workType = row[5]?.value?.toString() ?? '';
          final dataType = row[6]?.value?.toString() ?? '';
          final connectionType = row[7]?.value?.toString() ?? '';
          final status = row[8]?.value?.toString() ?? '';
          final detail = row[9]?.value?.toString() ?? '';
          final startDateStr = row[10]?.value?.toString() ?? '';
          final completionDateStr = row[11]?.value?.toString() ?? '';
          final remarks = row[12]?.value?.toString() ?? '';

          // 필수 값 확인
          if (regDateStr.isEmpty || line.isEmpty || equipment.isEmpty) {
            continue;
          }

          // 날짜 파싱
          DateTime regDate;
          try {
            regDate = DateTime.parse(regDateStr);
          } catch (e) {
            try {
              regDate = dateFormat.parse(regDateStr);
            } catch (e) {
              regDate = DateTime.now();
            }
          }

          // 시작일
          DateTime? startDate;
          if (startDateStr.isNotEmpty) {
            try {
              startDate = DateTime.parse(startDateStr);
            } catch (e) {
              try {
                startDate = dateFormat.parse(startDateStr);
              } catch (e) {
                startDate = null;
              }
            }
          }

          // 완료일
          DateTime? completionDate;
          if (completionDateStr.isNotEmpty) {
            try {
              completionDate = DateTime.parse(completionDateStr);
            } catch (e) {
              try {
                completionDate = dateFormat.parse(completionDateStr);
              } catch (e) {
                completionDate = null;
              }
            }
          }
          
          // 코드 생성 (비어있는 경우)
          final finalCode = code.isNotEmpty ? 
                         code : 
                         'EC-${regDate.year}${regDate.month.toString().padLeft(2, '0')}${regDate.day.toString().padLeft(2, '0')}-${no.toString().padLeft(3, '0')}';

          newItems.add(EquipmentConnectionModel(
            no: no,
            regDate: regDate,
            code: finalCode,
            line: line,
            equipment: equipment,
            workType: workType,
            dataType: dataType,
            connectionType: connectionType,
            status: status,
            detail: detail,
            startDate: startDate,
            completionDate: completionDate,
            remarks: remarks,
            isModified: true,
            isNew: true,
          ));
        } catch (e) {
          debugPrint('행 $i 파싱 오류: $e');
          // 오류가 있어도 계속 진행
        }
      }

      // 데이터 추가
      if (newItems.isNotEmpty) {
        setState(() {
          // 기존 데이터와 충돌 검사
          for (final newItem in newItems) {
            final existingIdx = _connectionData.indexWhere(
              (item) => item.code == newItem.code
            );
            
            if (existingIdx >= 0) {
              // 기존 항목 업데이트
              _connectionData[existingIdx] = newItem.copyWith(
                isModified: true,
              );
            } else {
              // 새 항목 추가
              _connectionData.add(newItem);
            }
          }
          
          _unsavedChanges = true;
          _currentPage = 0;
          _totalPages = (_connectionData.length / _rowsPerPage).ceil();
        });
        
        _refreshPlutoGrid();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${newItems.length}개 항목 가져오기 완료. 저장 버튼을 클릭하여 변경 사항을 적용하세요.'))
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('가져올 유효한 데이터가 없습니다.'))
          );
        }
      }
    } catch (e) {
      debugPrint('엑셀 가져오기 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('엑셀 가져오기 실패: $e'))
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // EquipmentConnectionDataPage 클래스에 새로운 _handleCellChangedForTable 함수 추가
  void _handleCellChangedForTable(PlutoRow? row, int columnIdx, dynamic value) {
    if (row == null) return;
    
    final code = row.cells['code']?.value as String?;
    if (code == null) return;
    
    final column = _columns[columnIdx];
    final field = column.field;
    
    setState(() {
      final connectionIndex = _connectionData.indexWhere((c) => c.code == code);
      if (connectionIndex != -1) {
        var connection = _connectionData[connectionIndex];
        
        if (field == 'line') {
          connection = connection.copyWith(line: value);
        } else if (field == 'equipment') {
          connection = connection.copyWith(equipment: value);
        } else if (field == 'workType') {
          connection = connection.copyWith(workType: value);
        } else if (field == 'dataType') {
          connection = connection.copyWith(dataType: value);
        } else if (field == 'connectionType') {
          connection = connection.copyWith(connectionType: value);
        } else if (field == 'status') {
          connection = connection.copyWith(status: value);
        } else if (field == 'details') {
          connection = connection.copyWith(detail: value);
        } else if (field == 'startDate') {
          connection = connection.copyWith(startDate: value);
        } else if (field == 'completionDate') {
          connection = connection.copyWith(completionDate: value);
        } else if (field == 'note') {
          connection = connection.copyWith(remarks: value);
        }
        
        _connectionData[connectionIndex] = connection;
        _unsavedChanges = true;
      }
    });
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
          selectedWorkType: _selectedWorkType,
          selectedDataType: _selectedDataType,
          selectedConnectionType: _selectedConnectionType,
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
          onWorkTypeChanged: (value) {
            setState(() {
              _selectedWorkType = value;
              _currentPage = 1;
              _loadConnectionData();
            });
          },
          onDataTypeChanged: (value) {
            setState(() {
              _selectedDataType = value;
              _currentPage = 1;
              _loadConnectionData();
            });
          },
          onConnectionTypeChanged: (value) {
            setState(() {
              _selectedConnectionType = value;
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
                  onAddRow: _addEmptyRow,
                  onSaveChanges: _saveAllData,
                  onDeleteSelected: _deleteSelectedRows,
                  onExportExcel: _exportToExcel,
                  onImportExcel: _showAdminPasswordDialog,
                ),
              ),
            ],
          ),
        ),
        
        // 3. 데이터 테이블 및 범례
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: CommonDataTableWidget(
                  columns: _columns,
                  rows: _getPlutoRows(),
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
}

// 설비 연동 필터 위젯
class EquipmentFilterWidget extends StatefulWidget {
  final TextEditingController searchController;
  final String? selectedLine;
  final String? selectedEquipment;
  final String? selectedWorkType;
  final String? selectedDataType;
  final String? selectedConnectionType;
  final String? selectedStatus;
  final List<String> lines;
  final List<String> equipments;
  final Function(String?) onLineChanged;
  final Function(String?) onEquipmentChanged;
  final Function(String?) onWorkTypeChanged;
  final Function(String?) onDataTypeChanged;
  final Function(String?) onConnectionTypeChanged;
  final Function(String?) onStatusChanged;
  final VoidCallback onSearchChanged;

  const EquipmentFilterWidget({
    Key? key,
    required this.searchController,
    required this.selectedLine,
    required this.selectedEquipment,
    required this.selectedWorkType,
    required this.selectedDataType,
    required this.selectedConnectionType,
    required this.selectedStatus,
    required this.lines,
    required this.equipments,
    required this.onLineChanged,
    required this.onEquipmentChanged,
    required this.onWorkTypeChanged,
    required this.onDataTypeChanged,
    required this.onConnectionTypeChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  State<EquipmentFilterWidget> createState() => _EquipmentFilterWidgetState();
}

class _EquipmentFilterWidgetState extends State<EquipmentFilterWidget> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleSearchChange() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 첫 번째 행: 라인, 설비, 검색
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  hint: const Text('전체 라인'),
                  value: widget.selectedLine,
                  isExpanded: true,
                  onChanged: widget.onLineChanged,
                  items: [null, ...widget.lines].map((s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(s ?? '전체 라인')
                  )).toList()
                )
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  hint: const Text('전체 설비'),
                  value: widget.selectedEquipment,
                  isExpanded: true,
                  onChanged: widget.onEquipmentChanged,
                  items: [null, ...widget.equipments].map((t) => DropdownMenuItem<String>(
                    value: t,
                    child: Text(t ?? '전체 설비')
                  )).toList()
                )
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: widget.searchController,
                  decoration: const InputDecoration(
                    hintText: '통합 검색...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder()
                  ),
                  onChanged: (v) => _handleSearchChange()
                )
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 두 번째 행: 작업유형, 데이터유형, 연동유형, 상태
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  hint: const Text('전체 작업유형'),
                  value: widget.selectedWorkType,
                  isExpanded: true,
                  onChanged: widget.onWorkTypeChanged,
                  items: [null, ...EquipmentConnectionModel.workTypes].map((s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(s ?? '전체 작업유형')
                  )).toList()
                )
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  hint: const Text('전체 데이터유형'),
                  value: widget.selectedDataType,
                  isExpanded: true,
                  onChanged: widget.onDataTypeChanged,
                  items: [null, ...EquipmentConnectionModel.dataTypes].map((t) => DropdownMenuItem<String>(
                    value: t,
                    child: Text(t ?? '전체 데이터유형')
                  )).toList()
                )
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  hint: const Text('전체 연동유형'),
                  value: widget.selectedConnectionType,
                  isExpanded: true,
                  onChanged: widget.onConnectionTypeChanged,
                  items: [null, ...EquipmentConnectionModel.connectionTypes].map((t) => DropdownMenuItem<String>(
                    value: t,
                    child: Text(t ?? '전체 연동유형')
                  )).toList()
                )
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  hint: const Text('전체 상태'),
                  value: widget.selectedStatus,
                  isExpanded: true,
                  onChanged: widget.onStatusChanged,
                  items: [null, ...EquipmentConnectionModel.statusTypes].map((t) => DropdownMenuItem<String>(
                    value: t,
                    child: Text(t ?? '전체 상태')
                  )).toList()
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 액션 버튼 위젯
class ActionButtonsWidget extends StatelessWidget {
  final bool hasSelection;
  final bool hasUnsavedChanges;
  final bool isAdmin;
  final VoidCallback onAddRow;
  final VoidCallback onSaveChanges;
  final VoidCallback onDeleteSelected;
  final VoidCallback onExportExcel;
  final VoidCallback onImportExcel;

  const ActionButtonsWidget({
    Key? key,
    required this.hasSelection,
    required this.hasUnsavedChanges,
    required this.isAdmin,
    required this.onAddRow,
    required this.onSaveChanges,
    required this.onDeleteSelected,
    required this.onExportExcel,
    required this.onImportExcel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // 행 추가 버튼
          ElevatedButton.icon(
            onPressed: isAdmin ? onAddRow : null,
            icon: const Icon(Icons.add),
            label: const Text('행 추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 8),
          
          // 저장 버튼
          ElevatedButton.icon(
            onPressed: hasUnsavedChanges && isAdmin ? onSaveChanges : null,
            icon: const Icon(Icons.save),
            label: const Text('저장'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 8),
          
          // 삭제 버튼
          ElevatedButton.icon(
            onPressed: hasSelection && isAdmin ? onDeleteSelected : null,
            icon: const Icon(Icons.delete),
            label: const Text('삭제'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 8),
          
          // 엑셀 내보내기 버튼
          ElevatedButton.icon(
            onPressed: onExportExcel,
            icon: const Icon(Icons.file_download),
            label: const Text('엑셀 내보내기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          
          // 엑셀 가져오기 버튼
          ElevatedButton.icon(
            onPressed: isAdmin ? onImportExcel : null,
            icon: const Icon(Icons.file_upload),
            label: const Text('엑셀 가져오기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// 설비 연동관리 대시보드 페이지
class EquipmentConnectionDashboardPage extends StatefulWidget {
  const EquipmentConnectionDashboardPage({Key? key}) : super(key: key);

  @override
  State<EquipmentConnectionDashboardPage> createState() => _EquipmentConnectionDashboardPageState();
}

class _EquipmentConnectionDashboardPageState extends State<EquipmentConnectionDashboardPage> {
  bool _isLoading = true;
  final List<EquipmentConnectionModel> _connectionData = [];
  final ApiService _apiService = ApiService();

  // 차트 데이터
  final Map<String, int> _workTypeData = {};
  final Map<String, int> _connectionTypeData = {};
  final Map<String, List<EquipmentConnectionModel>> _statusData = {};
  final Map<String, int> _lineData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _apiService.fetchEquipmentConnections();
      
      // 작업 유형별 분류
      final workTypeMap = <String, int>{};
      for (final item in data) {
        final type = item.workType.isNotEmpty ? item.workType : '미지정';
        workTypeMap[type] = (workTypeMap[type] ?? 0) + 1;
      }
      
      // 연동 유형별 분류
      final connectionTypeMap = <String, int>{};
      for (final item in data) {
        final type = item.connectionType.isNotEmpty ? item.connectionType : '미지정';
        connectionTypeMap[type] = (connectionTypeMap[type] ?? 0) + 1;
      }
      
      // 상태별 분류
      final statusMap = <String, List<EquipmentConnectionModel>>{};
      for (final status in EquipmentConnectionModel.statusTypes) {
        statusMap[status] = [];
      }
      
      for (final item in data) {
        final status = item.status.isNotEmpty ? item.status : '대기';
        statusMap[status]?.add(item);
      }
      
      // 라인별 분류
      final lineMap = <String, int>{};
      for (final item in data) {
        final line = item.line.isNotEmpty ? item.line : '미지정';
        lineMap[line] = (lineMap[line] ?? 0) + 1;
      }
      
      setState(() {
        _connectionData.clear();
        _connectionData.addAll(data);
        _workTypeData.clear();
        _workTypeData.addAll(workTypeMap);
        _connectionTypeData.clear();
        _connectionTypeData.addAll(connectionTypeMap);
        _statusData.clear();
        _statusData.addAll(statusMap);
        _lineData.clear();
        _lineData.addAll(lineMap);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('대시보드 데이터 로드 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 작업 유형별 차트
  Widget _buildWorkTypeChart() {
    if (_workTypeData.isEmpty) {
      return const Center(child: Text('데이터가 없습니다'));
    }
    
    // 색상 목록
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    // 데이터 정렬
    final sortedData = _workTypeData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // 차트 데이터 생성
    final pieData = <PieChartSectionData>[];
    
    for (var i = 0; i < sortedData.length; i++) {
      final item = sortedData[i];
      final color = colors[i % colors.length];
      
      pieData.add(PieChartSectionData(
        value: item.value.toDouble(),
        title: '${item.key}\n${item.value}',
        color: color,
        radius: 100,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ));
    }
    
    // 범례 생성
    final legendItems = <Widget>[];
    
    for (var i = 0; i < sortedData.length; i++) {
      final item = sortedData[i];
      final color = colors[i % colors.length];
      
      legendItems.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${item.key}: ${item.value}개',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ));
    }
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '작업 유형별 연동 현황',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: PieChart(
                      PieChartData(
                        sections: pieData,
                        centerSpaceRadius: 0,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendItems,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 연동 유형별 차트
  Widget _buildConnectionTypeChart() {
    if (_connectionTypeData.isEmpty) {
      return const Center(child: Text('데이터가 없습니다'));
    }
    
    // 색상 목록
    final colors = [
      Colors.teal,
      Colors.amber,
      Colors.purple,
      Colors.blue,
      Colors.red,
      Colors.green,
    ];
    
    // 데이터 정렬
    final sortedData = _connectionTypeData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // 차트 데이터 생성
    final barData = <BarChartGroupData>[];
    final legendItems = <Widget>[];
    
    for (var i = 0; i < sortedData.length; i++) {
      final item = sortedData[i];
      final color = colors[i % colors.length];
      
      barData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: item.value.toDouble(),
            color: color,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ));
      
      legendItems.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${item.key}: ${item.value}개',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ));
    }
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '연동 유형별 현황',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.center,
                        barGroups: barData,
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          drawVerticalLine: false,
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value >= 0 && value < sortedData.length) {
                                  final name = sortedData[value.toInt()].key;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      name.length > 8 ? '${name.substring(0, 8)}...' : name,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendItems,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 상태별 현황
  Widget _buildStatusWidget() {
    // 색상 매핑
    final colorMap = {
      '대기': Colors.grey,
      '진행중': Colors.blue,
      '완료': Colors.green,
      '중단': Colors.red,
    };
    
    // 카운트 계산
    final counts = <String, int>{};
    for (final entry in _statusData.entries) {
      counts[entry.key] = entry.value.length;
    }
    
    // 카드 생성
    final cards = <Widget>[];
    
    _statusData.forEach((key, items) {
      cards.add(
        Expanded(
          child: Card(
            elevation: 2,
            color: colorMap[key]?.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    key,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorMap[key],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${items.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorMap[key],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
    
    // 최근 항목 테이블 데이터 준비
    final recentItems = [
      ..._statusData['진행중'] ?? [],
    ];
    
    recentItems.sort((a, b) {
      if (a.startDate == null && b.startDate == null) return 0;
      if (a.startDate == null) return 1;
      if (b.startDate == null) return -1;
      return b.startDate!.compareTo(a.startDate!);
    });
    
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '설비 연동 상태 현황',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth > 700
                  ? Row(children: cards)
                  : Column(
                      children: _statusData.entries.map((entry) {
                        final key = entry.key;
                        final items = entry.value;
                        return Card(
                          elevation: 2,
                          color: colorMap[key]?.withOpacity(0.1),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    key,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorMap[key],
                                    ),
                                  ),
                                ),
                                Text(
                                  '${items.length}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: colorMap[key],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
              }
            ),
            const SizedBox(height: 24),
            Text(
              '진행중인 연동 작업 (최근 순)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            recentItems.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('진행중인 연동 작업이 없습니다'),
                    ),
                  )
                : Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('라인')),
                          DataColumn(label: Text('설비')),
                          DataColumn(label: Text('작업유형')),
                          DataColumn(label: Text('연동유형')),
                          DataColumn(label: Text('시작일')),
                          DataColumn(label: Text('상태')),
                        ],
                        rows: recentItems.take(10).map((item) {
                          return DataRow(
                            cells: [
                              DataCell(Text(item.line)),
                              DataCell(Text(item.equipment)),
                              DataCell(Text(item.workType)),
                              DataCell(Text(item.connectionType)),
                              DataCell(Text(item.startDate != null
                                  ? dateFormat.format(item.startDate!)
                                  : '-')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '진행중',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '설비 연동관리 대시보드',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '총 ${_connectionData.length}개의 설비 연동 데이터',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return constraints.maxWidth > 1000 
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildWorkTypeChart()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildConnectionTypeChart()),
                            ],
                          )
                        : Column(
                            children: [
                              _buildWorkTypeChart(),
                              const SizedBox(height: 16),
                              _buildConnectionTypeChart(),
                            ],
                          );
                    }
                  ),
                  const SizedBox(height: 24),
                  _buildStatusWidget(),
                ],
              ),
            ),
    );
  }
} 