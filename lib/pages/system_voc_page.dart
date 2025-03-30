import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:intl/intl.dart';
import '../models/voc_model.dart';
import '../services/api_service.dart';
import 'dashboard_page.dart';
import 'dart:async';

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
    'MES 아산', 'MES 비나', 'QMS 아산', 'QMS 비나', 
    '그룹웨어', '하드웨어', '소프트웨어', '통신', '기타'
  ];
  
  // 요청 분류 리스트
  final List<String> _requestTypes = ['단순문의', '전산오류', '시스템개발', '업무협의', '기타'];
  
  // 상태 리스트
  final List<String> _statusList = ['접수', '진행중', '완료', '보류'];
  
  // VOC 데이터
  List<VocModel> _vocData = [];
  
  // 로딩 상태
  bool _isLoading = true;
  
  // 삭제 버튼에 사용할 상태 변수 추가
  bool _hasSelectedItems = false;
  
  // PlutoGrid 상태 관리자
  PlutoGridStateManager? _stateManager;
  
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
        if (_stateManager != null) {
          _stateManager!.removeAllRows();
          _stateManager!.appendRows(_getPlutoRows());
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
  void onLoaded(PlutoGridOnLoadedEvent event) {
    _stateManager = event.stateManager;
    
    // 선택 모드를 none으로 설정 (행 선택 시 파란색 선택 표시 제거)
    _stateManager!.setSelectingMode(PlutoGridSelectingMode.none);
    
    // 이전에 선택된 행이 있으면 체크 표시
    for (final row in _stateManager!.rows) {
      final vocCode = row.cells['code']?.value as String? ?? '';
      
      // 저장 상태 확인
      final vocIdx = _vocData.indexWhere((voc) => voc.code == vocCode);
      if (vocIdx != -1) {
        final voc = _vocData[vocIdx];
        
        // 배경색 적용 - PlutoRow에서 직접 지원하지 않으므로 제거
        // 대신 PlutoGrid의 색상 스타일링 사용
      }
      
      if (_selectedCodes.contains(vocCode)) {
        row.cells['selected']?.value = true;
      }
    }
    
    // 선택 상태 업데이트
    _updateSelectedState();
  }
  
  // 선택 상태 업데이트
  void _updateSelectedState() {
    if (_stateManager == null) return;
    
    _selectedCodes = [];
    
    // 체크된 모든 행의 코드 수집
    for (final row in _stateManager!.rows) {
      final isSelected = row.cells['selected']?.value == true;
      final vocCode = row.cells['code']?.value as String? ?? '';
      
      if (isSelected && vocCode.isNotEmpty) {
        _selectedCodes.add(vocCode);
      }
    }
    
    setState(() {
      _hasSelectedItems = _selectedCodes.isNotEmpty;
    });
  }
  
  // 셀 변경 이벤트 핸들러
  void onCellChanged(PlutoGridOnChangedEvent event) {
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
  
  // VOC 데이터를 PlutoRow로 변환
  List<PlutoRow> _getPlutoRows() {
    final paginatedData = _paginatedData();
    
    return List.generate(paginatedData.length, (index) {
      final voc = paginatedData[index];
      
      // 행의 색상을 결정하는 변수 (저장되지 않은 데이터는 배경색 변경)
      final backgroundColor = !voc.isSaved 
          ? Colors.blue.shade50  // 새로 추가된 행 (저장되지 않음)
          : voc.isModified 
              ? Colors.amber.shade50  // 수정된 행
              : Colors.white;     // 저장된 행
      
      return PlutoRow(
        cells: {
          'selected': PlutoCell(value: _selectedCodes.contains(voc.code)),
          'no': PlutoCell(value: voc.no), // 실제 VOC 번호 표시
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
        // 배경색은 직접 지정하지 않고, 나중에 CSS로 처리
      );
    });
  }
  
  // VOC 시스템용 PlutoGrid 컬럼 정의
  List<PlutoColumn> _createColumns() {
    return [
      // 체크박스 컬럼 추가 - select 타입 대신 text 타입 사용
      PlutoColumn(
        title: '',
        field: 'selected',
        type: PlutoColumnType.text(), // select가 아닌 text 타입 사용
        width: 50,
        enableSorting: false,
        enableColumnDrag: false,
        enableContextMenu: false,
        enableDropToResize: false,
        enableEditingMode: false, // 편집 모드 비활성화
        textAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          // 체크 상태 확인 - 값이 true인 경우에만 체크됨
          final isChecked = rendererContext.cell.value == true;
          
          // 체크박스만 표시하고 텍스트는 표시하지 않음
          return StatefulBuilder(
            builder: (context, setBuilderState) {
              return Center(
                child: Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    // 1. 즉시 UI 갱신을 위해 StatefulBuilder 상태 업데이트
                    setBuilderState(() {
                      // 체크박스 상태를 즉시 변경
                    });
                    
                    // 2. PlutoGrid 셀 값 직접 변경
                    rendererContext.cell.value = value;
                    
                    // 3. 그리드 UI에 알림
                    rendererContext.stateManager.notifyListeners();
                    
                    // 4. VOC 코드 가져오기
                    final row = rendererContext.row;
                    final vocCode = row.cells['code']?.value as String? ?? '';
                    
                    // 5. 글로벌 상태 업데이트
                    if (mounted) {
                      setState(() {
                        if (value == true && vocCode.isNotEmpty) {
                          // 체크박스가 선택되면 목록에 추가
                          if (!_selectedCodes.contains(vocCode)) {
                            _selectedCodes.add(vocCode);
                          }
                        } else {
                          // 체크박스가 해제되면 목록에서 제거
                          _selectedCodes.remove(vocCode);
                        }
                        
                        // 행 삭제 버튼 활성화 상태 업데이트
                        _hasSelectedItems = _selectedCodes.isNotEmpty;
                      });
                    }
                  },
                  // 체크박스 스타일 커스터마이징
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }
          );
        },
      ),
      PlutoColumn(
        title: 'No',
        field: 'no',
        type: PlutoColumnType.number(),
        width: 60,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        // 셀 렌더러 추가
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
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: '등록일',
        field: 'regDate',
        type: PlutoColumnType.date(),
        width: 120,
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: '코드',
        field: 'code',
        type: PlutoColumnType.text(),
        width: 120,
        enableEditingMode: false,  // 코드는 수정 불가능
        textAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'VOC분류',
        field: 'vocCategory',
        type: PlutoColumnType.select(_vocCategories),
        width: 130,
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: '요청부서',
        field: 'requestDept',
        type: PlutoColumnType.text(),
        width: 130,
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: '요청자',
        field: 'requester',
        type: PlutoColumnType.text(),
        width: 120,
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: '시스템경로',
        field: 'systemPath',
        type: PlutoColumnType.text(),
        width: 160,
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: '요청내용',
        field: 'request',
        type: PlutoColumnType.text(),
        width: 250,
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: '요청유형',
        field: 'requestType',
        type: PlutoColumnType.select(_requestTypes),
        width: 120,
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: '실행조치',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 250,
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: '실행팀',
        field: 'actionTeam',
        type: PlutoColumnType.text(),
        width: 120,
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: '실행자',
        field: 'actionPerson',
        type: PlutoColumnType.text(),
        width: 120,
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: '상태',
        field: 'status',
        type: PlutoColumnType.select(_statusList),
        width: 100,
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: '완료예정일',
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
      if (_stateManager != null) {
        _stateManager!.removeAllRows();
        _stateManager!.appendRows(_getPlutoRows());
      }
    }
  }
  
  // PlutoGrid 갱신 함수 개선
  void _refreshPlutoGrid() {
    if (_stateManager != null) {
      _stateManager!.removeAllRows();
      final rows = _getPlutoRows();
      _stateManager!.appendRows(rows);
      
      // 첫 번째 행 선택 (행이 있는 경우)
      if (rows.isNotEmpty) {
        _stateManager!.setCurrentCell(
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
        // 행 추가 버튼
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
        // 데이터 저장 버튼
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
        // 행 삭제 버튼
        ElevatedButton.icon(
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
      ],
    );
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
      vocCategory: _vocCategories.isNotEmpty ? _vocCategories.first : 'MES 아산',
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
    if (_stateManager == null) return;
    
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

  // 페이지 네비게이션 위젯
  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 처음으로 버튼
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 0 ? () => _changePage(0) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
          ),
          // 이전 버튼
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0 ? () => _changePage(_currentPage - 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
          ),
          // 페이지 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              '${_currentPage + 1} / $_totalPages',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // 다음 버튼
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages - 1 ? () => _changePage(_currentPage + 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
          ),
          // 마지막으로 버튼
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < _totalPages - 1 ? () => _changePage(_totalPages - 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
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
      if (_stateManager != null) {
        _stateManager!.removeAllRows();
        final newRows = _getPlutoRows();
        _stateManager!.appendRows(newRows);
        
        // 변경된 페이지의 첫 번째 행 선택 (행이 있는 경우)
        if (newRows.isNotEmpty) {
          _stateManager!.setCurrentCell(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 범례 정보
        if (_unsavedChanges)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Text('범례: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const Text('새 데이터'),
                const SizedBox(width: 12),
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const Text('수정됨'),
                const SizedBox(width: 12),
                const Text('변경사항은 데이터 저장 버튼을 눌러야 저장됩니다.', 
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red)
                ),
              ],
            ),
          ),
        
        // PlutoGrid
        Expanded(
          child: PlutoGrid(
            columns: _createColumns(),
            rows: _getPlutoRows(),
            onLoaded: onLoaded,
            onChanged: onCellChanged,
            configuration: const PlutoGridConfiguration(
              columnSize: PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.scale,
              ),
              style: PlutoGridStyleConfig(
                gridBackgroundColor: Colors.white,
                gridBorderColor: Colors.grey,
                gridBorderRadius: BorderRadius.all(Radius.circular(8)),
                rowHeight: 49,
                columnFilterHeight: 56,
                cellTextStyle: TextStyle(fontSize: 13),
                columnTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                activatedColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
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
        
        // 데이터 테이블 영역
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
        
        // 항상 페이지네이션 표시 (데이터가 있는 경우에만)
        if (_vocData.isNotEmpty) _buildPagination(),
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