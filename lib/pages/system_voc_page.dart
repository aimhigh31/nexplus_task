import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:intl/intl.dart';
import '../models/voc_model.dart';
import '../services/api_service.dart';
import 'dashboard_page.dart'; // VOC 대시보드 사용
import 'dart:async';
import 'package:excel/excel.dart' hide Border, BorderStyle;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'dart:io';
import '../widgets/data_table_widget.dart';

class SystemVocPage extends StatefulWidget {
  const SystemVocPage({super.key});

  @override
  State<SystemVocPage> createState() => _SystemVocPageState();
}

class _SystemVocPageState extends State<SystemVocPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  final List<String> _vocTabs = ['데이터 관리', '종합현황']; // 탭 이름 수정

  // 페이지네이션 변수
  int _currentPage = 0;
  final int _rowsPerPage = 11;
  int _totalPages = 0;

  // 검색 및 필터 변수
  final TextEditingController _searchController = TextEditingController();
  String? _selectedVocCategory;
  String? _selectedRequestType;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _dueDateStart;
  DateTime? _dueDateEnd;

  // VOC 분류 리스트
  final List<String> _vocCategories = [
    'MES 본사', 'QMS 본사', 'MES 베트남', 'QMS 베트남',
    '하드웨어', '소프트웨어', '그룹웨어', '통신', '기타'
  ];

  // 요청 분류 리스트
  final List<String> _requestTypes = ['단순문의', '전산오류', '시스템 개발', '업무협의', '데이터수정', '기타'];

  // 상태 리스트
  final List<String> _statusList = ['접수', '진행중', '완료', '보류'];

  // VOC 데이터
  List<VocModel> _vocData = [];

  // 로딩 상태
  bool _isLoading = true;

  // 삭제 버튼 상태
  bool _hasSelectedItems = false;

  // PlutoGrid 상태 관리자
  PlutoGridStateManager? _gridStateManager;

  // 선택된 VOC 코드 목록
  List<String> _selectedCodes = [];

  // 저장되지 않은 변경사항
  bool _unsavedChanges = false;

  // 디바운싱 타이머
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _vocTabs.length, vsync: this);

    try {
      _loadVocData();
    } catch (e) {
      debugPrint('VOC 데이터 로드 오류: $e');
      setState(() {
        _isLoading = false;
        _vocData = [];
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // VOC 데이터 로드
  Future<void> _loadVocData() async {
    setState(() { _isLoading = true; });

    try {
      final vocData = await _apiService.getVocData(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        vocCategory: _selectedVocCategory,
        requestType: _selectedRequestType,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        dueDateStart: _dueDateStart,
        dueDateEnd: _dueDateEnd,
      );

      vocData.sort((a, b) => b.no.compareTo(a.no));

      if (mounted) {
        setState(() {
          _vocData = vocData;
          _totalPages = (_vocData.length / _rowsPerPage).ceil();
          if (_totalPages == 0) {
            _currentPage = 0;
          } else if (_currentPage >= _totalPages) {
            _currentPage = _totalPages - 1;
          }
          _isLoading = false;
        });
        _refreshPlutoGrid();
      }
    } catch (e) {
      debugPrint('VOC 데이터 로드 오류: $e');
      if (mounted) {
        setState(() { 
          _isLoading = false; 
          _vocData = []; // 데이터 로드 실패 시 빈 배열 설정
          _totalPages = 0;
          _currentPage = 0;
        });
      }
    }
  }

  // 현재 페이지 데이터
  List<VocModel> _paginatedData() {
    if (_vocData.isEmpty) {
      return [];
    }
    
    // 페이지 범위 확인
    if (_currentPage < 0) {
      _currentPage = 0;
    }
    
    // 빈 데이터 처리 개선
    final totalPages = (_vocData.length / _rowsPerPage).ceil();
    if (totalPages == 0) {
      return [];
    }
    
    // 현재 페이지가 범위를 벗어난 경우 마지막 페이지로 조정
    if (_currentPage >= totalPages) {
      _currentPage = totalPages - 1;
    }
    
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage > _vocData.length)
        ? _vocData.length
        : startIndex + _rowsPerPage;
    
    // 데이터 확인 로그
    debugPrint('페이지 데이터: ${_currentPage + 1}/$totalPages, 시작:$startIndex, 끝:$endIndex, 총:${_vocData.length}개');
    
    return _vocData.sublist(startIndex, endIndex);
  }

  // 날짜 선택기
  Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
  }

  // 셀 변경 처리
  void _handleCellChanged(PlutoGridOnChangedEvent event) {
    final field = event.column.field;
    if (field == 'selected') return;

    final vocCode = event.row.cells['code']?.value as String? ?? '';
    if (vocCode.isEmpty) return;

    final vocIdx = _vocData.indexWhere((v) => v.code == vocCode);
    if (vocIdx == -1) return;

    final vocData = _vocData[vocIdx];
    VocModel updatedVoc;

    switch (field) {
      case 'regDate': updatedVoc = vocData.copyWith(regDate: event.value, isModified: true); break;
      case 'vocCategory': updatedVoc = vocData.copyWith(vocCategory: event.value, isModified: true); break;
      case 'requestDept': updatedVoc = vocData.copyWith(requestDept: event.value, isModified: true); break;
      case 'requester': updatedVoc = vocData.copyWith(requester: event.value, isModified: true); break;
      case 'systemPath': updatedVoc = vocData.copyWith(systemPath: event.value, isModified: true); break;
      case 'request': updatedVoc = vocData.copyWith(request: event.value, isModified: true); break;
      case 'requestType': updatedVoc = vocData.copyWith(requestType: event.value, isModified: true); break;
      case 'action': updatedVoc = vocData.copyWith(action: event.value, isModified: true); break;
      case 'actionTeam': updatedVoc = vocData.copyWith(actionTeam: event.value, isModified: true); break;
      case 'actionPerson': updatedVoc = vocData.copyWith(actionPerson: event.value, isModified: true); break;
      case 'status': updatedVoc = vocData.copyWith(status: event.value, isModified: true); break;
      case 'dueDate': updatedVoc = vocData.copyWith(dueDate: event.value, isModified: true); break;
      default: return;
    }

    _vocData[vocIdx] = updatedVoc;
    _unsavedChanges = true;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 10), () {
      if (mounted) setState(() {});
    });
  }

  // PlutoGrid 행 변환
  List<PlutoRow> _getPlutoRows() {
    final List<PlutoRow> rows = [];
    final pageData = _paginatedData();
    for (var index = 0; index < pageData.length; index++) {
      final data = pageData[index];
      rows.add(PlutoRow(
        cells: {
          'selected': PlutoCell(value: _selectedCodes.contains(data.code)),
          'no': PlutoCell(value: data.no),
          'regDate': PlutoCell(value: data.regDate),
          'code': PlutoCell(value: data.code ?? ''),
          'vocCategory': PlutoCell(value: data.vocCategory),
          'requestDept': PlutoCell(value: data.requestDept),
          'requester': PlutoCell(value: data.requester),
          'systemPath': PlutoCell(value: data.systemPath),
          'request': PlutoCell(value: data.request),
          'requestType': PlutoCell(value: data.requestType),
          'action': PlutoCell(value: data.action),
          'actionTeam': PlutoCell(value: data.actionTeam),
          'actionPerson': PlutoCell(value: data.actionPerson),
          'status': PlutoCell(value: data.status),
          'dueDate': PlutoCell(value: data.dueDate),
        },
      ));
    }
    return rows;
  }

  // PlutoGrid 컬럼 정의
  List<PlutoColumn> get _columns {
    return [
      PlutoColumn( title: '', field: 'selected', type: PlutoColumnType.text(), width: 40, enableEditingMode: false, textAlign: PlutoColumnTextAlign.center, renderer: (ctx) => _buildCheckboxRenderer(ctx)),
      PlutoColumn( title: 'No', field: 'no', type: PlutoColumnType.number(), width: 60, enableEditingMode: false, readOnly: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.center ),
      PlutoColumn( title: '등록일', field: 'regDate', type: PlutoColumnType.date(), width: 100, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.center ),
      PlutoColumn( title: 'VOC코드', field: 'code', type: PlutoColumnType.text(), width: 110, enableEditingMode: false, readOnly: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.center ),
      PlutoColumn( title: 'VOC분류', field: 'vocCategory', type: PlutoColumnType.select(_vocCategories), width: 100, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.center ),
      PlutoColumn( title: '요청부서', field: 'requestDept', type: PlutoColumnType.text(), width: 100, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.center ),
      PlutoColumn( title: '요청자', field: 'requester', type: PlutoColumnType.text(), width: 80, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.center ),
      PlutoColumn( title: '시스템경로', field: 'systemPath', type: PlutoColumnType.text(), width: 150, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.left ),
      PlutoColumn( title: '요청내용', field: 'request', type: PlutoColumnType.text(), width: 200, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.left ),
      PlutoColumn( title: '요청유형', field: 'requestType', type: PlutoColumnType.select(_requestTypes), width: 80, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.center ),
      PlutoColumn( title: '조치내용', field: 'action', type: PlutoColumnType.text(), width: 200, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.left ),
      PlutoColumn( title: '담당팀', field: 'actionTeam', type: PlutoColumnType.text(), width: 100, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.center ),
      PlutoColumn( title: '담당자', field: 'actionPerson', type: PlutoColumnType.text(), width: 80, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.center ),
      PlutoColumn( title: '상태', field: 'status', type: PlutoColumnType.select(_statusList), width: 80, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.center ),
      PlutoColumn( title: '완료일정', field: 'dueDate', type: PlutoColumnType.date(), width: 100, enableEditingMode: true, titleTextAlign: PlutoColumnTextAlign.center, textAlign: PlutoColumnTextAlign.center ),
    ];
  }

  // 체크박스 렌더러
  Widget _buildCheckboxRenderer(PlutoColumnRendererContext context) {
    return Center(
      child: Checkbox(
        value: context.cell.value as bool? ?? false,
        onChanged: (bool? value) {
          final rowIdx = context.rowIdx;
          if (rowIdx < 0 || rowIdx >= _paginatedData().length) return;
          
          final data = _paginatedData()[rowIdx];
          _toggleRowSelection(rowIdx);
          
          // PlutoGrid 셀 값도 변경
          if (_gridStateManager != null) {
            _gridStateManager!.changeCellValue(
              context.cell, 
              value,
              force: true
            );
          }
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // 빈 행 추가
  void _addEmptyRow() {
    int newNo = _vocData.isEmpty ? 1 : _vocData.map((v) => v.no).fold(0, (max, current) => current > max ? current : max) + 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final newCode = VocModel.generateVocCode(today, newNo); // VocModel 사용

    final newVoc = VocModel(
      no: newNo,
      regDate: today,
      code: newCode,
      vocCategory: _vocCategories.first,
      requestDept: '', requester: '', systemPath: '', request: '', requestType: _requestTypes.first,
      action: '', actionTeam: '', actionPerson: '', status: _statusList.first, dueDate: today.add(const Duration(days: 7)),
      isSaved: false,
      isModified: true,
    );

    setState(() {
      _vocData.insert(0, newVoc); // 새 VOC를 목록 맨 앞에 추가
      _currentPage = 0; // 첫 페이지로 이동
      _totalPages = (_vocData.length / _rowsPerPage).ceil(); // totalPages 다시 계산
      _unsavedChanges = true;
    });

    // 그리드 갱신
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPlutoGrid();
    });
  }

  // 모든 변경사항 저장
  Future<void> _saveAllData() async {
    final unsavedItems = _vocData.where((v) => !v.isSaved || v.isModified).toList();
    if (unsavedItems.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    int successCount = 0;
    int failCount = 0;

    // 실제 API 저장 호출
    for (final item in unsavedItems) {
      try {
        VocModel? result;
        if (item.isSaved) {
          // 기존 데이터 업데이트
          result = await _apiService.updateVoc(item);
        } else {
          // 새 데이터 추가
          result = await _apiService.addVoc(item);
        }

        if (result != null) {
          successCount++;
          // 저장된 데이터로 업데이트
          final index = _vocData.indexWhere((v) => v.no == item.no);
          if (index != -1) {
            _vocData[index] = result.copyWith(isSaved: true, isModified: false);
          }
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
        debugPrint('VOC 데이터 저장 중 오류: $e');
      }
    }

    // UI 업데이트
    if (mounted) {
      setState(() {
        _isLoading = false;
        _unsavedChanges = false;
        _totalPages = (_vocData.length / _rowsPerPage).ceil(); // totalPages 다시 계산
        if (_currentPage >= _totalPages && _totalPages > 0) {
          _currentPage = _totalPages - 1; // 페이지 범위 조정
        }
      });
      
      _refreshPlutoGrid();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 완료 (성공: $successCount, 실패: $failCount)')),
      );
    }
  }

  // 선택된 행 삭제
  void _deleteSelectedRows() {
    if (_selectedCodes.isEmpty) return;
    final codesToDelete = List<String>.from(_selectedCodes);

    showDialog<bool>(
      context: context, builder: (context) => AlertDialog(
        title: const Text('행 삭제'), content: Text('선택한 ${codesToDelete.length}개 행을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('삭제')),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true) return;
      setState(() { _isLoading = true; });
      _deleteCodesSequentially(codesToDelete);
    });
  }

  Future<void> _deleteCodesSequentially(List<String> codes) async {
    int successCount = 0;
    int failCount = 0;

    // 실제 API 호출
    for (final code in codes) {
      try {
        bool success = await _apiService.deleteVocByCode(code);
        if (success) {
          successCount++;
          _vocData.removeWhere((d) => d.code == code);
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
        debugPrint('VOC 삭제 중 오류: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _selectedCodes.clear();
        _hasSelectedItems = false;
        _totalPages = (_vocData.length / _rowsPerPage).ceil();
        if (_totalPages == 0) _currentPage = 0;
        else if (_currentPage >= _totalPages) _currentPage = _totalPages - 1;
      });
      _refreshPlutoGrid();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('선택한 ${codes.length}개 항목 삭제 완료 (성공: $successCount, 실패: $failCount)')),
      );
    }
  }

  // 엑셀 내보내기 (VOC 기준)
  Future<void> _exportToExcel() async { /* ... VOC 필드 기준으로 구현 ... */ }
  // 엑셀 가져오기 (VOC 기준)
  Future<void> _importFromExcel() async { /* ... VOC 필드 기준으로 구현 ... */ }
  // 관리자 암호 확인
  Future<void> _showAdminPasswordDialog() async { /* ... 기존 로직 유지 ... */ }

  // 페이지 변경
  void _changePage(int page) {
    if (page < 0 || page >= _totalPages) return;
    setState(() {
      _currentPage = page;
    });
    _refreshPlutoGrid();
  }

  // 그리드 갱신
  void _refreshPlutoGrid() {
    if (_gridStateManager != null) {
      try {
        _gridStateManager!.removeAllRows();
        final rows = _getPlutoRows();
        _gridStateManager!.appendRows(rows);
        
        if (rows.isNotEmpty) {
          _gridStateManager!.setCurrentCell(rows.first.cells.values.first, 0);
        }
        
        _updateSelectedState();
        
        // 디버깅 정보
        debugPrint('플루토 그리드 갱신 완료: ${rows.length}개 행, 페이지 ${_currentPage + 1}/${_totalPages > 0 ? _totalPages : 1}');
      } catch (e) {
        debugPrint('플루토 그리드 갱신 오류: $e');
      }
    }
  }

  // 선택 토글
  void _toggleRowSelection(int rowIdx) {
    if (rowIdx < 0 || rowIdx >= _paginatedData().length) return;
    final code = _paginatedData()[rowIdx].code;
    if (code == null || code.isEmpty) return;

    setState(() {
        if (_selectedCodes.contains(code)) {
            _selectedCodes.remove(code);
        } else {
            _selectedCodes.add(code);
        }
        _hasSelectedItems = _selectedCodes.isNotEmpty;
    });
    _refreshPlutoGrid();
  }

  // 선택 상태 업데이트
  void _updateSelectedState() {
    setState(() { _hasSelectedItems = _selectedCodes.isNotEmpty; });
  }

  // 데이터가 없을 때 표시할 위젯
  Widget _buildEmptyDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addEmptyRow,
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

  // 필터 디자인을 솔루션 개발 데이터관리와 동일하게 구현
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // 솔루션분류 필터
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'VOC분류',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: _selectedVocCategory,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ..._vocCategories.map((category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedVocCategory = value;
                  _currentPage = 0;
                });
                _loadVocData();
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // 요청유형 필터
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '요청유형',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: _selectedRequestType,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ..._requestTypes.map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRequestType = value;
                  _currentPage = 0;
                });
                _loadVocData();
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // 상태 필터
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '상태',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: _selectedStatus,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ..._statusList.map((status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                  _currentPage = 0;
                });
                _loadVocData();
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // 통합검색
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '통합검색',
                hintText: '검색어 입력',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: (value) {
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                  setState(() { _currentPage = 0; });
                  _loadVocData();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // 타이틀과 실행 버튼
  Widget _buildTitleAndActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 타이틀 및 데이터 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '시스템 VOC',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '전체 ${_vocData.length}개 항목, ${_currentPage + 1}/${_totalPages} 페이지',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          // 실행 버튼들
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addEmptyRow,
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text('행 추가', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  disabledForegroundColor: Colors.black
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _saveAllData,
                icon: Icon(Icons.save, color: _unsavedChanges ? Colors.yellow : Colors.white),
                label: Text(
                  '데이터 저장${_unsavedChanges ? ' *' : ''}',
                  style: TextStyle(
                    fontWeight: _unsavedChanges ? FontWeight.bold : FontWeight.normal,
                    color: Colors.white
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _unsavedChanges ? Colors.blue.shade700 : null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _hasSelectedItems ? _deleteSelectedRows : null,
                icon: const Icon(Icons.delete_outline),
                label: Text('행 삭제${_hasSelectedItems ? ' (${_selectedCodes.length})' : ''}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.red.withOpacity(0.3),
                  disabledForegroundColor: Colors.black
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.file_download, color: Colors.white),
                label: const Text('엑셀 다운로드', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _importFromExcel,
                icon: const Icon(Icons.file_upload, color: Colors.white),
                label: const Text('엑셀 업로드', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 범례 (한 줄에 표시)
  Widget _buildLegend() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('범례:', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4)
                )
              ),
              const SizedBox(width: 4),
              const Text('신규')
            ]
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(4)
                )
              ),
              const SizedBox(width: 4),
              const Text('수정')
            ]
          ),
          if (_unsavedChanges)
            const Text(
              '* 저장되지 않은 변경사항',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            ),
        ],
      ),
    );
  }

  // 페이지 네비게이션
  Widget _buildPageNavigator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 0 ? () => _changePage(0) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30)
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0 ? () => _changePage(_currentPage - 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30)
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${_currentPage + 1} / $_totalPages',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
            )
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages - 1 ? () => _changePage(_currentPage + 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30)
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < _totalPages - 1 ? () => _changePage(_totalPages - 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30)
          ),
        ],
      ),
    );
  }

  // 데이터 탭 UI 빌드 (컴포넌트 사용)
  Widget _buildDataTab() {
    return Column(
      children: [
        // 1. 필터 (맨 위에 배치)
        _buildFilterBar(),
        
        // 2. 타이틀과 실행 버튼 (한 줄에 표시)
        _buildTitleAndActions(),
        
        // 3. 범례 (데이터 테이블 바로 위에 배치)
        if (_vocData.isNotEmpty) _buildLegend(),
        
        // 4. 데이터 테이블 (Expanded로 남은 공간 채움)
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _vocData.isEmpty
              ? _buildEmptyDataView()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: PlutoGrid(
                    columns: _columns,
                    rows: _getPlutoRows(),
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      _gridStateManager = event.stateManager;
                      _gridStateManager!.setShowColumnFilter(false);
                    },
                    onChanged: _handleCellChanged,
                    configuration: PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(
                        cellTextStyle: const TextStyle(fontSize: 12),
                        columnTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        rowColor: Colors.white,
                        oddRowColor: Colors.grey.shade50,
                        activatedColor: Colors.blue.shade100,
                        gridBorderColor: Colors.grey.shade300,
                        borderColor: Colors.grey.shade300,
                        inactivatedBorderColor: Colors.grey.shade300
                      ),
                    ),
                  ),
                ),
        ),
        
        // 5. 페이지 네비게이션 (맨 아래에 배치)
        if (_vocData.isNotEmpty) _buildPageNavigator(),
      ],
    );
  }

  // 페이지 전체 빌드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VOC 관리'),
        titleSpacing: 16.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _vocTabs.map((tabName) => Tab(text: tabName)).toList(), // 탭 이름
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
        children: [
          // 데이터 관리 탭
          _buildDataTab(),
          // 종합 현황 탭 (VOC 대시보드 연결)
          DashboardPage(vocData: _vocData),
        ],
      ),
    );
  }
}

// --- 컴포넌트 위젯 정의 --- 

// FilterWidget (VOC 기준) - 솔루션 개발 페이지와 동일한 디자인으로 변경
class FilterWidget extends StatefulWidget {
  final TextEditingController searchController;
  final String? selectedVocCategory;
  final String? selectedRequestType;
  final String? selectedStatus;
  final List<String> vocCategories;
  final List<String> requestTypes;
  final List<String> statusList;
  final ValueChanged<String?> onVocCategoryChanged;
  final ValueChanged<String?> onRequestTypeChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onSearchChanged;

  const FilterWidget({
    super.key,
    required this.searchController,
    required this.selectedVocCategory,
    required this.selectedRequestType,
    required this.selectedStatus,
    required this.vocCategories,
    required this.requestTypes,
    required this.statusList,
    required this.onVocCategoryChanged,
    required this.onRequestTypeChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // VOC 분류 필터
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'VOC분류',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: widget.selectedVocCategory,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ...widget.vocCategories.map((category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                )),
              ],
              onChanged: widget.onVocCategoryChanged,
            ),
          ),
          const SizedBox(width: 12),
          
          // 요청유형 필터
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '요청유형',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: widget.selectedRequestType,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ...widget.requestTypes.map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                )),
              ],
              onChanged: widget.onRequestTypeChanged,
            ),
          ),
          const SizedBox(width: 12),
          
          // 상태 필터
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '상태',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: widget.selectedStatus,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ...widget.statusList.map((status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                )),
              ],
              onChanged: widget.onStatusChanged,
            ),
          ),
          const SizedBox(width: 12),
          
          // 통합검색
          Expanded(
            flex: 3,
            child: TextField(
              controller: widget.searchController,
              decoration: InputDecoration(
                labelText: '통합검색',
                hintText: '검색어 입력',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: (value) {
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                  widget.onSearchChanged();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ActionButtonsWidget (기존 코드 유지)
class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onAddRow;
  final VoidCallback onSaveData;
  final VoidCallback onDeleteRows;
  final VoidCallback onExportExcel;
  final VoidCallback onImportExcel;
  final bool hasSelectedItems;
  final int selectedItemCount;
  final bool unsavedChanges;

  const ActionButtonsWidget({ super.key, required this.onAddRow, required this.onSaveData, required this.onDeleteRows, required this.onExportExcel, required this.onImportExcel, required this.hasSelectedItems, required this.selectedItemCount, required this.unsavedChanges });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(padding: const EdgeInsets.only(right: 8.0), child: ElevatedButton.icon(onPressed: onAddRow, icon: const Icon(Icons.add, color: Colors.black), label: const Text('행 추가', style: TextStyle(color: Colors.black)), style: ElevatedButton.styleFrom(foregroundColor: Colors.black, disabledForegroundColor: Colors.black))), 
        Padding(padding: const EdgeInsets.only(right: 8.0), child: ElevatedButton.icon(onPressed: onSaveData, icon: Icon(Icons.save, color: unsavedChanges ? Colors.yellow : Colors.white), label: Text('데이터 저장${unsavedChanges ? ' *' : ''}', style: TextStyle(fontWeight: unsavedChanges ? FontWeight.bold : FontWeight.normal, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: unsavedChanges ? Colors.blue.shade700 : null, foregroundColor: Colors.white, disabledForegroundColor: Colors.black, disabledIconColor: Colors.black))), 
        Padding(padding: const EdgeInsets.only(right: 8.0), child: ElevatedButton.icon(onPressed: hasSelectedItems ? onDeleteRows : null, icon: const Icon(Icons.delete_outline), label: Text('행 삭제${hasSelectedItems ? ' ($selectedItemCount)' : ''}'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, disabledBackgroundColor: Colors.red.withOpacity(0.3), disabledForegroundColor: Colors.black))), 
        Padding(padding: const EdgeInsets.only(right: 8.0), child: ElevatedButton.icon(onPressed: onExportExcel, icon: const Icon(Icons.file_download, color: Colors.white), label: const Text('엑셀 다운로드', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))), 
        ElevatedButton.icon(onPressed: onImportExcel, icon: const Icon(Icons.file_upload, color: Colors.white), label: const Text('엑셀 업로드', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white)),
      ],
    );
  }
}

// 데이터 테이블 위젯
class DataTableWidget extends StatelessWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final bool unsavedChanges;
  final Function(PlutoGridOnChangedEvent) onCellChanged;
  final Function(PlutoGridOnLoadedEvent) onLoaded;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const DataTableWidget({
    Key? key,
    required this.columns,
    required this.rows,
    required this.unsavedChanges,
    required this.onCellChanged,
    required this.onLoaded,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonDataTableWidget(
      columns: columns,
      rows: rows,
      hasUnsavedChanges: unsavedChanges,
      onChanged: onCellChanged,
      onLoaded: onLoaded,
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      legendItems: [
        LegendItem(label: '접수', color: Colors.blue.shade100),
        LegendItem(label: '진행중', color: Colors.yellow.shade100),
        LegendItem(label: '완료', color: Colors.green.shade100),
        LegendItem(label: '보류', color: Colors.red.shade100),
      ],
    );
  }
} 