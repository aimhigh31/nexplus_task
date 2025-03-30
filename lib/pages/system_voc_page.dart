import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:intl/intl.dart';
import '../models/voc_model.dart';
import '../services/api_service.dart';
import 'dashboard_page.dart';
import 'dart:async';
import 'package:excel/excel.dart' hide Border, BorderStyle;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'dart:io';

class SystemVocPage extends StatefulWidget {
  const SystemVocPage({super.key});

  @override
  State<SystemVocPage> createState() => _SystemVocPageState();
}

class _SystemVocPageState extends State<SystemVocPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  // 상단 탭 변경
  final List<String> _vocTabs = ['종합현황', '데이터'];
  
  // 페이지네이션 변수
  int _currentPage = 0;
  final int _rowsPerPage = 11; // 한 페이지에 11개 행 표시
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
  
  // 삭제 버튼에 사용할 상태 변수 추가
  bool _hasSelectedItems = false;
  
  // PlutoGrid 상태 관리자
  PlutoGridStateManager? _gridStateManager;
  
  // 행 선택 모드 설정 및 체크박스 관련 함수 수정
  List<String> _selectedCodes = []; // 선택된 VOC 코드 목록 저장
  
  // 저장되지 않은 변경사항 표시
  bool _unsavedChanges = false;
  
  // 디바운싱 타이머 추가
  Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 데이터 로드 시 예외 처리 추가
    try {
      _loadVocData();
    } catch (e) {
      debugPrint('VOC 데이터 로드 오류: $e');
      // 오류 발생해도 UI는 정상 표시되도록
      setState(() {
        _isLoading = false;
        _vocData = [];  // 빈 데이터라도 설정
      });
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel(); // 디바운스 타이머 해제
    super.dispose();
  }
  
  // VOC 데이터 로드
  Future<void> _loadVocData() async {
    setState(() {
      _isLoading = true;
    });
    
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
      
      // 명시적으로 번호 역순으로 정렬 (최신 번호가 위에 오도록)
      vocData.sort((a, b) => b.no.compareTo(a.no));
      debugPrint('VOC 데이터 역순 정렬 후 첫 번째 5개 항목: ${vocData.take(5).map((voc) => voc.no).join(', ')}');
      
      if (mounted) {
        setState(() {
          _vocData = vocData;
          _totalPages = (_vocData.length / _rowsPerPage).ceil();
          
          // 현재 페이지가 유효한지 확인
          if (_totalPages == 0) {
            _currentPage = 0;
          } else if (_currentPage >= _totalPages) {
            _currentPage = _totalPages - 1;
          }
          
          _isLoading = false;
        });
        
        // PlutoGrid 갱신
        if (_gridStateManager != null) {
          _gridStateManager!.removeAllRows();
          _gridStateManager!.appendRows(_getPlutoRows());
        }
      }
    } catch (e) {
      debugPrint('VOC 데이터 로드 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 중 오류가 발생했습니다: $e')),
        );
        setState(() {
          _isLoading = false;
          // 오류가 발생해도 빈 상태로 설정하여 UI 표시
          if (_vocData.isEmpty) {
            _totalPages = 0;
            _currentPage = 0;
          }
        });
      }
    }
  }
  
  // 현재 페이지의 데이터
  List<VocModel> _paginatedData() {
    if (_vocData.isEmpty) return [];
    
    // vocData는 이미 번호 역순으로 정렬되어 있음
    // (_vocData는 역순 정렬 상태를 유지해야 함)
    
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage > _vocData.length 
        ? _vocData.length 
        : startIndex + _rowsPerPage;
    
    if (startIndex >= _vocData.length) {
      // 현재 페이지가 데이터 범위를 벗어나면 첫 페이지로 리셋
      if (_currentPage > 0) {
        _currentPage = 0;
        return _paginatedData();
      }
      return [];
    }
    
    final pageData = _vocData.sublist(startIndex, endIndex);
    debugPrint('현재 페이지($_currentPage) 데이터 번호: ${pageData.map((voc) => voc.no).join(', ')}');
    return pageData;
  }
  
  // 날짜 선택기 표시
  Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
  }
  
  // PlutoGrid 로드 시 설정
  void _handleCellChanged(PlutoGridOnChangedEvent event) {
    final field = event.column.field;
    
    // 체크박스 변경 이벤트는 이미 별도 처리
    if (field == 'selected') return;
    
    final vocCode = event.row.cells['code']?.value as String? ?? '';
    if (vocCode.isEmpty) return;
    
    // 해당 코드의 VOC 데이터 찾기
    final vocIdx = _vocData.indexWhere((v) => v.code == vocCode);
    if (vocIdx == -1) return;
    
    final vocData = _vocData[vocIdx];
    
    // 수정된 필드에 따라 VOC 데이터 업데이트
    VocModel updatedVoc;
    switch (field) {
      case 'regDate':
        updatedVoc = vocData.copyWith(regDate: event.value, isModified: true);
        break;
      case 'vocCategory':
        updatedVoc = vocData.copyWith(vocCategory: event.value, isModified: true);
        break;
      case 'requestDept':
        updatedVoc = vocData.copyWith(requestDept: event.value, isModified: true);
        break;
      case 'requester':
        updatedVoc = vocData.copyWith(requester: event.value, isModified: true);
        break;
      case 'systemPath':
        updatedVoc = vocData.copyWith(systemPath: event.value, isModified: true);
        break;
      case 'request':
        updatedVoc = vocData.copyWith(request: event.value, isModified: true);
        break;
      case 'requestType':
        updatedVoc = vocData.copyWith(requestType: event.value, isModified: true);
        break;
      case 'action':
        updatedVoc = vocData.copyWith(action: event.value, isModified: true);
        break;
      case 'actionTeam':
        updatedVoc = vocData.copyWith(actionTeam: event.value, isModified: true);
        break;
      case 'actionPerson':
        updatedVoc = vocData.copyWith(actionPerson: event.value, isModified: true);
        break;
      case 'status':
        updatedVoc = vocData.copyWith(status: event.value, isModified: true);
        break;
      case 'dueDate':
        updatedVoc = vocData.copyWith(dueDate: event.value, isModified: true);
        break;
      default:
        return;
    }
    
    // 로컬 데이터 업데이트
    _vocData[vocIdx] = updatedVoc;
    _unsavedChanges = true;
    
    // 디바운스 타이머 취소
    _debounceTimer?.cancel();
    
    // 화면 갱신 로직
    _debounceTimer = Timer(const Duration(milliseconds: 10), () {
      if (mounted) {
        // 상태 업데이트를 통해 UI 갱신 (그리드 전체 갱신)
        setState(() {}); 
      }
    });
  }
  
  // 데이터를 PlutoGrid 행으로 변환
  List<PlutoRow> _getPlutoRows() {
    final List<PlutoRow> rows = [];
    
    // 현재 페이지 데이터
    final vocData = _paginatedData();
    
    for (var index = 0; index < vocData.length; index++) {
      final voc = vocData[index];
      final rowNo = _currentPage * _rowsPerPage + index + 1;
      
      // 배경색 결정 (PlutoRow에는 직접 backgroundColor 속성이 없으므로 셀 렌더러에서 적용)
      rows.add(
        PlutoRow(
          cells: {
            'selected': PlutoCell(value: _selectedCodes.contains(voc.code)),
            'no': PlutoCell(value: voc.no),
            'regDate': PlutoCell(value: voc.regDate),
            'code': PlutoCell(value: voc.code ?? ''),
            'vocCategory': PlutoCell(value: voc.vocCategory),
            'requestDept': PlutoCell(value: voc.requestDept),
            'requester': PlutoCell(value: voc.requester),
            'systemPath': PlutoCell(value: voc.systemPath),
            'request': PlutoCell(value: voc.request),
            'requestType': PlutoCell(value: voc.requestType),
            'action': PlutoCell(value: voc.action),
            'actionTeam': PlutoCell(value: voc.actionTeam),
            'actionPerson': PlutoCell(value: voc.actionPerson),
            'status': PlutoCell(value: voc.status),
            'dueDate': PlutoCell(value: voc.dueDate),
          },
          // backgroundColor 속성 제거
        ),
      );
    }
    
    return rows;
  }
  
  // VOC 시스템용 PlutoGrid 컬럼 정의
  List<PlutoColumn> get _columns {
    return [
      // 선택 컬럼(체크박스)
      PlutoColumn(
        title: '',
        field: 'selected',
        type: PlutoColumnType.text(),
        width: 40,
        enableEditingMode: false, // 수정 불가능하게 설정
        textAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          return Center(
            child: Checkbox(
              value: rendererContext.cell.value as bool? ?? false,
              onChanged: (value) {
                _toggleRowSelection(rendererContext.rowIdx);
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        },
      ),
      // 셀 번호 컬럼
      PlutoColumn(
        title: 'No',
        field: 'no',
        type: PlutoColumnType.number(),
        width: 60,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          // 현재 행의 VOC 코드를 가져옵니다
          final row = rendererContext.row;
          final vocCode = row.cells['code']?.value as String? ?? '';
          
          // VOC 데이터에서 해당 코드의 객체를 찾습니다
          final vocIdx = _vocData.indexWhere((voc) => voc.code == vocCode);
          Color bgColor = Colors.transparent;
          
          // 상태에 따라 배경색 결정
          if (vocIdx != -1) {
            final voc = _vocData[vocIdx];
            if (!voc.isSaved) {
              bgColor = Colors.blue.shade50;
            } else if (voc.isModified) {
              bgColor = Colors.amber.shade50;
            }
          }
          
          return Container(
            color: bgColor,
            alignment: Alignment.center,
            child: Text(
              '${rendererContext.cell.value}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12, // 글자 크기 12픽셀로 변경
              ),
            ),
          );
        },
      ),
      // 등록일 컬럼
      PlutoColumn(
        title: '등록일',
        field: 'regDate',
        type: PlutoColumnType.date(),
        width: 120,
        enableEditingMode: true,
      ),
      // 코드 컬럼
      PlutoColumn(
        title: '코드',
        field: 'code',
        type: PlutoColumnType.text(),
        width: 120,
        enableEditingMode: false,
      ),
      // VOC 분류 컬럼
      PlutoColumn(
        title: 'VOC분류',
        field: 'vocCategory',
        type: PlutoColumnType.select(['MES 본사', 'QMS 본사', 'MES 베트남', 'QMS 베트남', '하드웨어', '소프트웨어', '그룹웨어', '통신', '기타']),
        width: 100,
        enableEditingMode: true,
      ),
      // 요청부서 컬럼
      PlutoColumn(
        title: '요청부서',
        field: 'requestDept',
        type: PlutoColumnType.text(),
        width: 100,
        enableEditingMode: true,
      ),
      // 요청자 컬럼
      PlutoColumn(
        title: '요청자',
        field: 'requester',
        type: PlutoColumnType.text(),
        width: 80,
        enableEditingMode: true,
      ),
      // 시스템경로 컬럼
      PlutoColumn(
        title: '시스템경로',
        field: 'systemPath',
        type: PlutoColumnType.text(),
        width: 150,
        enableEditingMode: true,
      ),
      // 요청내용 컬럼
      PlutoColumn(
        title: '요청내용',
        field: 'request',
        type: PlutoColumnType.text(),
        width: 200,
        enableEditingMode: true,
      ),
      // 요청유형 컬럼
      PlutoColumn(
        title: '요청유형',
        field: 'requestType',
        type: PlutoColumnType.select(['단순문의', '전산오류', '시스템 개발', '업무협의', '데이터수정', '기타']),
        width: 80,
        enableEditingMode: true,
      ),
      // 조치내용 컬럼
      PlutoColumn(
        title: '조치내용',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 200,
        enableEditingMode: true,
      ),
      // 담당팀 컬럼
      PlutoColumn(
        title: '담당팀',
        field: 'actionTeam',
        type: PlutoColumnType.text(),
        width: 100,
        enableEditingMode: true,
      ),
      // 담당자 컬럼
      PlutoColumn(
        title: '담당자',
        field: 'actionPerson',
        type: PlutoColumnType.text(),
        width: 80,
        enableEditingMode: true,
      ),
      // 상태 컬럼
      PlutoColumn(
        title: '상태',
        field: 'status',
        type: PlutoColumnType.select(['접수', '진행중', '보류', '완료']),
        width: 80,
        enableEditingMode: true,
      ),
      // 완료일정 컬럼
      PlutoColumn(
        title: '완료일정',
        field: 'dueDate',
        type: PlutoColumnType.date(),
        width: 120,
        enableEditingMode: true,
      ),
    ];
  }

  // VOC 추가 기능 수정
  Future<void> _addVoc(VocModel newVoc) async {
    _apiService.addVoc(newVoc).then((savedVoc) {
      if (savedVoc != null) {
        // 데이터 다시 로드
        _loadVocData();
      }
    });
  }
  
  // VOC 업데이트 기능 수정
  Future<void> _updateVoc(VocModel voc) async {
    _apiService.updateVoc(voc).then((savedVoc) {
      if (savedVoc != null) {
        setState(() {
          final index = _vocData.indexWhere((v) => v.no == voc.no);
          if (index != -1) {
            _vocData[index] = savedVoc;
          }
        });
      }
    });
  }
  
  // 선택된 행 삭제 기능 수정
  void _deleteSelectedRows() {
    if (_selectedCodes.isEmpty) {
      return;
    }
    
    // 선택된 코드 목록 복사 (비동기 작업 중에 원본 리스트가 변경될 수 있음)
    final codesToDelete = List<String>.from(_selectedCodes);
    
    // 확인 다이얼로그 표시
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('행 삭제'),
        content: Text('선택한 ${codesToDelete.length}개 행을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true) return;
      
      // 로딩 상태 표시
      setState(() {
        _isLoading = true;
      });
      
      // 선택된 행 삭제
      _deleteCodesSequentially(codesToDelete);
    });
  }
  
  // 선택된 코드를 순차적으로 삭제
  Future<void> _deleteCodesSequentially(List<String> codes) async {
    int successCount = 0;
    int failCount = 0;
    
    for (final code in codes) {
      try {
        debugPrint('삭제 시도 - VOC 코드: $code');
        final success = await _apiService.deleteVocByCode(code);
        
        if (success) {
          debugPrint('삭제 성공 - VOC 코드: $code');
          successCount++;
          
          // 성공하면 로컬 데이터에서도 삭제
          _vocData.removeWhere((voc) => voc.code == code);
        } else {
          debugPrint('삭제 실패 - VOC 코드: $code');
          failCount++;
        }
      } catch (error) {
        debugPrint('삭제 중 오류 발생: $error');
        failCount++;
      }
    }
    
    // UI 업데이트는 모든 삭제 작업 완료 후 한 번만 수행
    if (mounted) {
      setState(() {
        _isLoading = false;
        _selectedCodes.clear();
        _hasSelectedItems = false;
        
        // 페이지네이션 업데이트
        _totalPages = (_vocData.length / _rowsPerPage).ceil();
        
        // 현재 페이지가 유효한지 확인
        if (_totalPages == 0) {
          _currentPage = 0;
        } else if (_currentPage >= _totalPages) {
          _currentPage = _totalPages - 1;
        }
      });
      
      // PlutoGrid 갱신
      if (_gridStateManager != null) {
        _gridStateManager!.removeAllRows();
        _gridStateManager!.appendRows(_getPlutoRows());
      }
    }
  }
  
  // PlutoGrid 갱신 함수 개선
  void _refreshPlutoGrid() {
    if (_gridStateManager != null) {
      _gridStateManager!.removeAllRows();
      final rows = _getPlutoRows();
      _gridStateManager!.appendRows(rows);
      
      // 첫 번째 행 선택 (행이 있는 경우)
      if (rows.isNotEmpty) {
        _gridStateManager!.setCurrentCell(
          rows.first.cells.values.first,
          0,
        );
      }
      
      // 선택 상태 업데이트
      _updateSelectedState();
    }
  }
  
  // 헤더 및 버튼 영역 수정
  Widget _buildHeaderActions() {
    return Row(
      children: [
        // 1. 행 추가 버튼
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: _addEmptyRow,
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text('행 추가', style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              disabledForegroundColor: Colors.black,
            ),
          ),
        ),
        // 2. 데이터 저장 버튼
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: _saveAllData,
            icon: Icon(
              Icons.save,
              // 저장되지 않은 변경사항이 있으면 표시
              color: _unsavedChanges ? Colors.yellow : Colors.white,
            ),
            label: Text(
              '데이터 저장${_unsavedChanges ? ' *' : ''}',
              style: TextStyle(
                fontWeight: _unsavedChanges ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _unsavedChanges ? Colors.blue.shade700 : null,
              foregroundColor: Colors.white, 
              disabledForegroundColor: Colors.black, // 비활성화 시 텍스트 색상 검정색으로 변경
              disabledIconColor: Colors.black, // 비활성화 시 아이콘 색상도 검정색으로 설정
            ),
          ),
        ),
        // 3. 행 삭제 버튼
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: _hasSelectedItems ? _deleteSelectedRows : null,
            icon: const Icon(Icons.delete_outline),
            label: Text('행 삭제${_hasSelectedItems ? ' (${_selectedCodes.length})' : ''}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.red.withOpacity(0.3),
              disabledForegroundColor: Colors.black,
            ),
          ),
        ),
        // 4. 엑셀 내보내기 버튼
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: _exportToExcel,
            icon: const Icon(Icons.file_download, color: Colors.white),
            label: const Text('엑셀 다운로드', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        // 5. 엑셀 가져오기 버튼
        ElevatedButton.icon(
          onPressed: _showAdminPasswordDialog,
          icon: const Icon(Icons.file_upload, color: Colors.white),
          label: const Text('엑셀 업로드', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // 관리자 암호 확인 다이얼로그 표시
  Future<void> _showAdminPasswordDialog() async {
    final passwordController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('관리자 확인', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('주의: 데이터가 덮어쓰기 됩니다 (이전 데이터 소실 가능)'),
            const SizedBox(height: 16),
            const Text('진행하려면 관리자 암호를 입력하세요:'),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '관리자 암호 입력',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final password = passwordController.text.trim();
              Navigator.of(context).pop(password == 'RISK1234');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      // 암호가 맞으면 엑셀 가져오기 기능 실행
      _importFromExcel();
    } else if (result == false) {
      // 취소했거나 암호가 틀린 경우
      if (passwordController.text.isNotEmpty && passwordController.text != 'RISK1234') {
        // 암호가 틀린 경우에만 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('관리자 암호가 일치하지 않습니다.')),
        );
      }
    }
    
    passwordController.dispose();
  }

  // 빈 행 추가 기능 - 프론트엔드에서만 임시 처리하도록 수정
  void _addEmptyRow() {
    // 새로운 VOC 기본값 설정
    int newNo = 1;
    
    // 기존 데이터가 있으면 가장 큰 번호 + 1을 사용
    if (_vocData.isNotEmpty) {
      newNo = _vocData.map((v) => v.no).reduce((a, b) => a > b ? a : b) + 1;
    }
    
    debugPrint('새 행 추가시 부여된 번호: $newNo (${_vocData.length}개 기존 데이터 중 최대값+1)');
    
    // 현재 날짜 (시간 제외, 날짜만 사용)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // 월이 두 자리가 되도록 패딩
    final month = now.month.toString().padLeft(2, '0');
    final currentYearMonth = '${now.year.toString().substring(2)}$month';
    
    // 코드 일련번호 계산
    int sequenceNumber = 1;
    
    // 같은 년월의 기존 코드 중 가장 큰 일련번호 찾기
    if (_vocData.isNotEmpty) {
      final matching = _vocData.where((voc) => 
        voc.code != null && 
        voc.code!.startsWith('VOC$currentYearMonth')).toList();
      
      if (matching.isNotEmpty) {
        try {
          // 일련번호가 가장 큰 코드 찾기
          for (final voc in matching) {
            if (voc.code != null && voc.code!.length >= 10) {
              final codeSeq = int.tryParse(voc.code!.substring(7));
              if (codeSeq != null && codeSeq >= sequenceNumber) {
                sequenceNumber = codeSeq + 1;
              }
            }
          }
        } catch (e) {
          debugPrint('코드 일련번호 파싱 오류: $e');
        }
      }
    }
    
    // 3자리 일련번호 생성 (001, 002, ...)
    final seqString = sequenceNumber.toString().padLeft(3, '0');
    final newCode = 'VOC$currentYearMonth$seqString';
    
    debugPrint('새 행 추가 - 번호: $newNo, 코드: $newCode, 날짜: ${DateFormat('yyyy-MM-dd').format(today)}');
    
    // 새 VOC 모델 생성 - isSaved 필드를 false로 설정하여 임시 데이터임을 표시
    final newVoc = VocModel(
      no: newNo,
      regDate: today,
      code: newCode,
      vocCategory: _vocCategories.isNotEmpty ? _vocCategories.first : 'MES 본사',
      requestDept: '',
      requester: '',
      systemPath: '',
      request: '',
      requestType: '단순문의',
      action: '',
      actionTeam: '',
      actionPerson: '',
      status: '접수',
      dueDate: today.add(const Duration(days: 7)),
      isSaved: false, // 임시 데이터 표시
    );
    
    // 로컬 상태에만 추가 (백엔드 저장 없음)
    setState(() {
      _vocData.insert(0, newVoc); // 최신 데이터를 맨 위에 추가
      _currentPage = 0; // 첫 페이지로 이동
      _totalPages = (_vocData.length / _rowsPerPage).ceil(); // 페이지 수 업데이트
      _unsavedChanges = true; // 저장되지 않은 변경사항 표시
    });
    
    // PlutoGrid 갱신
    _refreshPlutoGrid();
  }
  
  // 모든 데이터 저장하기 (수정된 행과 새 행 모두 저장)
  void _saveAllData() {
    if (_gridStateManager == null) return;
    
    // 로딩 상태 표시
    setState(() {
      _isLoading = true;
    });
    
    // 저장해야 할 데이터 선별
    List<VocModel> toCreate = _vocData.where((voc) => voc.isSaved == false).toList();
    List<VocModel> toUpdate = _vocData.where((voc) => voc.isSaved == true && voc.isModified == true).toList();
    
    int totalToSave = toCreate.length + toUpdate.length;
    
    // 저장 결과 추적
    int successCount = 0;
    int failCount = 0;
    
    // 오류 디버깅을 위한 로그 추가
    debugPrint('저장할 데이터 수: $totalToSave (신규: ${toCreate.length}, 수정: ${toUpdate.length})');
    
    // 변경사항이 없는 경우
    if (totalToSave == 0) {
      setState(() {
        _isLoading = false;
        _unsavedChanges = false;
      });
      return;
    }
    
    // 저장 완료 확인 함수
    void checkCompletion() {
      if (successCount + failCount >= totalToSave) {
        // 로딩 상태 해제
        setState(() {
          _isLoading = false;
          _unsavedChanges = failCount > 0; // 실패 항목이 있으면 여전히 저장 필요
        });
        
        // 최신 데이터 로드
        _loadVocData();
      }
    }
    
    // 1. 새 VOC 데이터 생성
    for (final voc in toCreate) {
      debugPrint('새 VOC 저장 시도 - No: ${voc.no}, 코드: ${voc.code}');
      
      _apiService.addVoc(voc).then((savedVoc) {
        if (savedVoc != null) {
          successCount++;
          debugPrint('새 VOC 저장 성공 - No: ${voc.no}, 코드: ${voc.code}');
          
          // 로컬 상태 업데이트
          final idx = _vocData.indexWhere((v) => v.code == voc.code);
          if (idx != -1) {
            setState(() {
              _vocData[idx] = savedVoc.copyWith(isSaved: true, isModified: false);
            });
          }
        } else {
          failCount++;
          debugPrint('새 VOC 저장 실패 - No: ${voc.no}, 코드: ${voc.code}');
        }
        
        checkCompletion();
      }).catchError((error) {
        failCount++;
        debugPrint('새 VOC 저장 중 오류 발생 - No: ${voc.no}, 오류: $error');
        checkCompletion();
      });
    }
    
    // 2. 수정된 VOC 데이터 업데이트
    for (final voc in toUpdate) {
      debugPrint('VOC 업데이트 시도 - No: ${voc.no}, 코드: ${voc.code}');
      
      _apiService.updateVoc(voc).then((savedVoc) {
        if (savedVoc != null) {
          successCount++;
          debugPrint('VOC 업데이트 성공 - No: ${voc.no}, 코드: ${voc.code}');
          
          // 로컬 상태 업데이트
          final idx = _vocData.indexWhere((v) => v.code == voc.code);
          if (idx != -1) {
            setState(() {
              _vocData[idx] = savedVoc.copyWith(isModified: false);
            });
          }
        } else {
          failCount++;
          debugPrint('VOC 업데이트 실패 - No: ${voc.no}, 코드: ${voc.code}');
        }
        
        checkCompletion();
      }).catchError((error) {
        failCount++;
        debugPrint('VOC 업데이트 중 오류 발생 - No: ${voc.no}, 오류: $error');
        checkCompletion();
      });
    }
  }

  // Excel 내보내기 함수
  Future<void> _exportToExcel() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Excel 생성
      final excel = Excel.createExcel();
      final sheet = excel.sheets.values.first;
      
      // 헤더 행 추가
      final headers = [
        'No', '등록일', 'VOC 코드', 'VOC분류', '요청부서', '요청자', 
        '시스템경로', '요청내용', '요청유형', '조치내용', '담당팀', 
        '담당자', '상태', '완료일정'
      ];
      
      for (var i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = TextCellValue(headers[i])
          ..cellStyle = CellStyle(
            bold: true, 
            horizontalAlign: HorizontalAlign.Center,
          );
      }
      
      // 데이터 행 추가
      final dateFormat = DateFormat('yyyy-MM-dd');
      
      for (var i = 0; i < _vocData.length; i++) {
        final voc = _vocData[i];
        final row = i + 1; // 0번 행은 헤더
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(voc.no.toString());
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(dateFormat.format(voc.regDate));
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(voc.code ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(voc.vocCategory);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue(voc.requestDept);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue(voc.requester);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = TextCellValue(voc.systemPath);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value = TextCellValue(voc.request);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value = TextCellValue(voc.requestType);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row)).value = TextCellValue(voc.action);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row)).value = TextCellValue(voc.actionTeam);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row)).value = TextCellValue(voc.actionPerson);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: row)).value = TextCellValue(voc.status);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: row)).value = TextCellValue(dateFormat.format(voc.dueDate));
      }
      
      // 열 너비 조정
      sheet.setColumnWidth(0, 10); // No
      sheet.setColumnWidth(1, 15); // 등록일
      sheet.setColumnWidth(2, 18); // VOC 코드
      sheet.setColumnWidth(3, 15); // VOC 분류
      sheet.setColumnWidth(4, 15); // 요청부서
      sheet.setColumnWidth(5, 12); // 요청자
      sheet.setColumnWidth(6, 20); // 시스템경로
      sheet.setColumnWidth(7, 30); // 요청내용
      sheet.setColumnWidth(8, 15); // 요청유형
      sheet.setColumnWidth(9, 30); // 조치내용
      sheet.setColumnWidth(10, 15); // 담당팀
      sheet.setColumnWidth(11, 12); // 담당자
      sheet.setColumnWidth(12, 10); // 상태
      sheet.setColumnWidth(13, 15); // 완료일정
      
      // 엑셀 파일로 저장
      final bytes = excel.save()!;
      final currentDate = dateFormat.format(DateTime.now());
      
      // 파일 저장 대화 상자 표시
      await FileSaver.instance.saveFile(
        name: 'VOC_데이터_$currentDate', 
        bytes: Uint8List.fromList(bytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('VOC 데이터가 엑셀로 내보내기 되었습니다.')),
        );
      }
    } catch (e) {
      debugPrint('엑셀 내보내기 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('엑셀 내보내기 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Excel 가져오기 함수
  Future<void> _importFromExcel() async {
    try {
      // 파일 선택
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      
      if (result == null || result.files.single.bytes == null) {
        return; // 파일 선택 취소
      }
      
      setState(() {
        _isLoading = true;
      });
      
      // 엑셀 파일 로드
      final bytes = result.files.single.bytes!;
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.keys.first;
      
      // 데이터 읽기
      if (excel.tables[sheet] == null || excel.tables[sheet]!.rows.length <= 1) {
        throw Exception('유효한 데이터가 없습니다.');
      }
      
      final rows = excel.tables[sheet]!.rows;
      final importedData = <VocModel>[];
      final dateFormat = DateFormat('yyyy-MM-dd');
      
      // 첫 번째 행은 헤더로 처리
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        
        // 필수 필드 확인 (최소한 번호와 요청내용은 있어야 함)
        if (row.isEmpty || row.length < 4 || row[0] == null || row[7] == null) {
          continue;
        }
        
        try {
          final noStr = row[0]?.value?.toString() ?? '';
          final no = int.tryParse(noStr) ?? 0;
          
          // 번호가 0 이하인 경우 스킵
          if (no <= 0) continue;
          
          final regDateStr = row[1]?.value?.toString() ?? '';
          DateTime regDate;
          try {
            regDate = dateFormat.parse(regDateStr);
          } catch (_) {
            regDate = DateTime.now();
          }
          
          final dueDateStr = row[13]?.value?.toString() ?? '';
          DateTime dueDate;
          try {
            dueDate = dateFormat.parse(dueDateStr);
          } catch (_) {
            dueDate = DateTime.now().add(const Duration(days: 7)); // 기본값: 1주일 후
          }
          
          // VOC 모델 생성
          final voc = VocModel(
            no: no,
            regDate: regDate,
            code: row[2]?.value?.toString() ?? '',
            vocCategory: row[3]?.value?.toString() ?? '기타',
            requestDept: row[4]?.value?.toString() ?? '',
            requester: row[5]?.value?.toString() ?? '',
            systemPath: row[6]?.value?.toString() ?? '',
            request: row[7]?.value?.toString() ?? '',
            requestType: row[8]?.value?.toString() ?? '기타',
            action: row[9]?.value?.toString() ?? '',
            actionTeam: row[10]?.value?.toString() ?? '',
            actionPerson: row[11]?.value?.toString() ?? '',
            status: row[12]?.value?.toString() ?? '접수',
            dueDate: dueDate,
            isSaved: false,
            isModified: true,
          );
          
          importedData.add(voc);
        } catch (e) {
          debugPrint('행 $i 처리 중 오류: $e');
          continue;
        }
      }
      
      if (importedData.isEmpty) {
        throw Exception('가져올 수 있는 유효한 데이터가 없습니다.');
      }
      
      // 사용자 확인 다이얼로그 표시
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('엑셀 데이터 가져오기'),
          content: Text('${importedData.length}개의 항목을 가져왔습니다. 기존 데이터와 병합하시겠습니까?\n\n가져온 항목 중 같은 번호나 코드를 가진 항목은 덮어쓰기됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      
      if (confirm != true) {
        return; // 사용자가 취소함
      }
      
      // 데이터 병합 (같은 번호/코드가 있으면 덮어쓰기)
      final newData = List<VocModel>.from(_vocData);
      
      for (final importedVoc in importedData) {
        int existingIndex = -1;
        
        // 코드로 찾기 (코드가 있는 경우)
        if (importedVoc.code != null && importedVoc.code!.isNotEmpty) {
          existingIndex = newData.indexWhere(
            (voc) => voc.code == importedVoc.code
          );
        }
        
        // 번호로 찾기 (코드로 찾지 못한 경우)
        if (existingIndex == -1) {
          existingIndex = newData.indexWhere(
            (voc) => voc.no == importedVoc.no
          );
        }
        
        if (existingIndex != -1) {
          // 기존 항목 업데이트
          newData[existingIndex] = importedVoc;
        } else {
          // 새 항목 추가
          newData.add(importedVoc);
        }
      }
      
      // 데이터 업데이트 및 UI 갱신
      setState(() {
        _vocData = newData;
        _unsavedChanges = true;
        _totalPages = (_vocData.length / _rowsPerPage).ceil();
        
        // 정렬 (번호 역순)
        _vocData.sort((a, b) => b.no.compareTo(a.no));
        
        // 현재 페이지가 유효한지 확인
        if (_totalPages == 0) {
          _currentPage = 0;
        } else if (_currentPage >= _totalPages) {
          _currentPage = _totalPages - 1;
        }
      });
      
      // 테이블 갱신
      if (_gridStateManager != null) {
        _gridStateManager!.removeAllRows();
        _gridStateManager!.appendRows(_getPlutoRows());
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${importedData.length}개의 VOC 데이터를 가져왔습니다. 변경사항을 저장하려면 "데이터 저장" 버튼을 클릭하세요.'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('엑셀 가져오기 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('엑셀 가져오기 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 페이지네이션 UI 구현
  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 첫 페이지로 버튼
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 0 ? () => _changePage(0) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20, // 아이콘 크기 축소
            padding: EdgeInsets.zero, // 패딩 제거
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30), // 버튼 크기 축소
          ),
          // 이전 버튼
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0 ? () => _changePage(_currentPage - 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20, // 아이콘 크기 축소
            padding: EdgeInsets.zero, // 패딩 제거
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30), // 버튼 크기 축소
          ),
          // 페이지 정보
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${_currentPage + 1} / $_totalPages',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          // 다음 버튼
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages - 1 ? () => _changePage(_currentPage + 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20, // 아이콘 크기 축소
            padding: EdgeInsets.zero, // 패딩 제거
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30), // 버튼 크기 축소
          ),
          // 마지막으로 버튼
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < _totalPages - 1 ? () => _changePage(_totalPages - 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20, // 아이콘 크기 축소
            padding: EdgeInsets.zero, // 패딩 제거
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30), // 버튼 크기 축소
          ),
        ],
      ),
    );
  }
  
  // 페이지 변경 함수
  void _changePage(int page) {
    if (page >= 0 && page < _totalPages) {
      setState(() {
        _currentPage = page;
      });
      
      // PlutoGrid 갱신
      if (_gridStateManager != null) {
        _gridStateManager!.removeAllRows();
        final newRows = _getPlutoRows();
        _gridStateManager!.appendRows(newRows);
        
        // 변경된 페이지의 첫 번째 행 선택 (행이 있는 경우)
        if (newRows.isNotEmpty) {
          _gridStateManager!.setCurrentCell(
            newRows.first.cells.values.first, 
            0,
          );
        }
      }
      
      // 페이지 정보 로깅
      debugPrint('페이지 변경: $_currentPage / $_totalPages (${_paginatedData().length}개 표시)');
    }
  }

  // 행 추가 후 로직 개선 (코드 중복 제거)
  void _onVocAdded(VocModel savedVoc) {
    if (savedVoc != null) {
      debugPrint('VOC 추가 성공 - 번호: ${savedVoc.no}, 코드: ${savedVoc.code}');
      
      setState(() {
        // 새 VOC 데이터를 목록 맨 위에 추가
        _vocData.insert(0, savedVoc);
        _currentPage = 0; // 첫 페이지로 이동
        _totalPages = (_vocData.length / _rowsPerPage).ceil(); // 페이지 수 업데이트
      });
      
      // PlutoGrid 갱신
      _refreshPlutoGrid();
      
      // 알림 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 항목이 추가되었습니다.')),
      );
    }
  }
  
  // 데이터 테이블 영역
  Widget _buildPlutoGrid() {
    // 데이터 없는 경우 메시지 표시
    if (_vocData.isEmpty) {
      return Column(
        children: [
          // 범례는 항상 표시 (데이터 없어도 표시)
          _buildLegend(),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: Container(
              width: double.infinity,
              height: 300, // 최소 높이 설정
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Text(
                  '데이터가 없습니다.',
                  style: TextStyle(
                    fontSize: 12, // 글자 크기를 12픽셀로 변경
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 현재 페이지 데이터 준비
    final rows = _getPlutoRows();

    return Column(
      mainAxisSize: MainAxisSize.min, // overflow 방지를 위한 크기 조정
      children: [
        // 범례
        _buildLegend(),
        const SizedBox(height: 8),
        
        // 데이터 테이블 - Expanded로 감싸서 남은 공간을 채우도록 설정
        Expanded(
          child: PlutoGrid(
            columns: _columns,
            rows: rows,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              _gridStateManager = event.stateManager;
              _gridStateManager!.setShowColumnFilter(false); // 필터 비활성화
            },
            onChanged: _handleCellChanged,
            configuration: PlutoGridConfiguration(
              style: PlutoGridStyleConfig(
                cellTextStyle: const TextStyle(fontSize: 12), // 셀 텍스트 크기를 12픽셀로 변경
                columnTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // 컬럼 헤더 텍스트 크기를 12픽셀로 변경
                ),
                rowColor: Colors.white,
                oddRowColor: Colors.grey.shade50,
                gridBorderColor: Colors.grey.shade300,
                gridBackgroundColor: Colors.transparent,
                borderColor: Colors.grey.shade300,
                activatedColor: Colors.blue.shade100,
                activatedBorderColor: Colors.blue.shade300,
                inactivatedBorderColor: Colors.grey.shade300,
              ),
            ),
          ),
        ),
        
        // 페이징 UI
        _buildPagination(),
      ],
    );
  }

  // 범례 위젯
  Widget _buildLegend() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            '범례:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              const Text('신규 데이터'),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              const Text('수정된 데이터'),
            ],
          ),
          if (_unsavedChanges)
            const Text(
              '* 저장되지 않은 변경사항이 있습니다. 저장 버튼을 클릭하세요.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  // 선택 행 토글 처리
  void _toggleRowSelection(int rowIdx) {
    if (rowIdx < 0 || rowIdx >= _paginatedData().length) return;
    
    final voc = _paginatedData()[rowIdx];
    final code = voc.code;
    
    if (code == null || code.isEmpty) return;
    
    setState(() {
      if (_selectedCodes.contains(code)) {
        _selectedCodes.remove(code);
      } else {
        _selectedCodes.add(code);
      }
      
      _hasSelectedItems = _selectedCodes.isNotEmpty;
    });
    
    // 그리드 갱신
    if (_gridStateManager != null) {
      final rows = _getPlutoRows();
      _gridStateManager!.removeAllRows();
      _gridStateManager!.appendRows(rows);
    }
  }
  
  // 선택 상태 업데이트 메서드
  void _updateSelectedState() {
    setState(() {
      _hasSelectedItems = _selectedCodes.isNotEmpty;
    });
  }

  // 데이터 탭 내용 구성
  Widget _buildDataTab() {
    return Column(
      children: [
        // 필터 영역 - 필터 설정 레이블 제거
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // VOC 분류 필터
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      hint: const Text('전체 분류'),
                      value: _selectedVocCategory,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedVocCategory = value;
                          _currentPage = 0; // 필터 변경 시 첫 페이지로 이동
                          _loadVocData();
                        });
                      },
                      items: [null, ..._vocCategories].map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category ?? '전체 분류'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // 요청유형 필터
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      hint: const Text('전체 유형'),
                      value: _selectedRequestType,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedRequestType = value;
                          _currentPage = 0; // 필터 변경 시 첫 페이지로 이동
                          _loadVocData();
                        });
                      },
                      items: [null, ..._requestTypes].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type ?? '전체 유형'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // 상태 필터
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      hint: const Text('전체 상태'),
                      value: _selectedStatus,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                          _currentPage = 0; // 필터 변경 시 첫 페이지로 이동
                          _loadVocData();
                        });
                      },
                      items: [null, ..._statusList].map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status ?? '전체 상태'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 헤더 및 버튼 영역
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '시스템 VOC',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_vocData.isNotEmpty)
                    Text(
                      '전체 ${_vocData.length}개 항목, ${_currentPage + 1}/${_totalPages} 페이지',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
              _buildHeaderActions(),
            ],
          ),
        ),
        
        // 데이터 테이블 영역 - 스크롤 가능하게 변경
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _vocData.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          '데이터가 없습니다',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _addEmptyRow,
                          icon: const Icon(Icons.add),
                          label: const Text('첫 데이터 추가하기'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildPlutoGrid(),
                  ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시스템 VOC'),
        titleSpacing: 16.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.data_array),
              text: '데이터 관리',
            ),
            Tab(
              icon: Icon(Icons.dashboard),
              text: '종합현황',
            ),
          ],
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
          ),
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
          _buildDataTab(),
          // 대시보드 페이지
          const DashboardPage(),
        ],
      ),
    );
  }
} 