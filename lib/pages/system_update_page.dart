import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pluto_grid_plus/pluto_grid_plus.dart' hide Border, BorderStyle, TextStyle, Color;
import 'package:intl/intl.dart';
import '../models/system_update_model.dart'; // 시스템 업데이트 모델 사용
import '../services/api_service.dart';
import 'update_dashboard_page.dart'; // 종합현황 페이지 import
import 'dart:async';
import 'package:excel/excel.dart' hide Border, BorderStyle, TextStyle, Color;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'dart:io';
import '../widgets/attachment_popup.dart'; // 첨부파일 팝업 위젯 추가
import '../models/attachment_model.dart'; // 첨부파일 모델 추가

class SystemUpdatePage extends StatefulWidget {
  const SystemUpdatePage({super.key});

  @override
  State<SystemUpdatePage> createState() => _SystemUpdatePageState();
}

class _SystemUpdatePageState extends State<SystemUpdatePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  List<String> get _updateTabs => ['데이터관리', '대시보드'];
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  final List<SystemUpdateModel> _selectedItems = [];
  final Set<String?> _selectedUpdateCodes = {}; // 선택된 코드 목록
  String? _selectedStatus;
  PlutoGridStateManager? _gridStateManager;

  // 페이지네이션
  int _currentPage = 0;
  final int _rowsPerPage = 11;
  int _totalPages = 0;

  // 검색 및 필터
  final TextEditingController _searchController = TextEditingController();
  final List<String> _targetSystems = ['MES', 'QMS', 'PLM', 'SPC', 'MMS', 'KPI', '그룹웨어', '백업솔루션', '기타'];
  final List<String> _updateTypes = ['기능개선', '버그수정', '보안패치', 'UI변경', '데이터보정', '기타'];
  final List<String> _updateStatusList = ['계획', '진행중', '테스트', '완료', '보류'];
  String? _selectedTargetSystem;
  String? _selectedUpdateType;

  // 데이터
  List<SystemUpdateModel> _updateData = [];

  // 첨부파일 개수 데이터 맵 (업데이트ID -> 첨부파일 개수)
  Map<String, int> _attachmentCounts = {};

  // 상태
  bool _hasSelectedItems = false;
  Timer? _debounceTimer;
  final FocusNode _gridFocusNode = FocusNode();
  final ScrollController _gridScrollController = ScrollController();
  bool _isDataInitialized = false;

  // 개발사 리스트 추가
  final List<String> _developerList = ['건솔루션', '디비벨리', '하람정보', '코비젼'];

  bool _filterByAttachment = false; // 첨부파일 필터링 상태 변수 추가
  String _currentSortColumn = 'regDate'; // 현재 정렬 컬럼
  bool _isAscending = false; // 정렬 방향 (false: 내림차순, true: 오름차순)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _updateTabs.length, vsync: this);
    _initializeData();
    
    // 5분마다 자동 저장 타이머 설정
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _autoSave();
      } else {
        timer.cancel(); // 위젯이 해제되면 타이머 취소
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    _gridFocusNode.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    
    try {
      final List<SystemUpdateModel> loadedData = await _apiService.getSystemUpdates();

      if (mounted) {
        setState(() {
          _updateData = loadedData;
          _totalPages = (_updateData.length / _rowsPerPage).ceil();
          _currentPage = 0;
        });
        
        // 첨부파일 개수 로드 - await 추가하여 비동기 작업 완료 기다림
        await _loadAttachmentCounts();
      }
    } catch (e) {
      debugPrint('데이터 초기화 중 오류: $e');
      
      if (mounted) {
        setState(() {
          _updateData = []; // 빈 배열로 설정
          _totalPages = 0;
          _currentPage = 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 첨부파일 개수 로드 함수
  Future<void> _loadAttachmentCounts() async {
    try {
      debugPrint('첨부파일 개수 로드 시작...');
      final Map<String, int> counts = {};
      
      // 현재 페이지에 표시된 항목만 첨부파일 개수 로드
      for (final item in _paginatedData()) {
        if (item.id == null) {
          debugPrint('ID가 없는 항목 건너뜀 (저장되지 않은 항목): ${item.updateCode}');
          counts[item.no.toString()] = 0; // 저장되지 않은 항목은 ID 대신 no를 키로 사용
          continue;
        }
        
        try {
          // 임시 ID 또는 로컬 ID 확인
          final tempId = 'temp_${item.no}_${item.updateCode}';
          
          // 첨부파일 목록 요청
          debugPrint('항목의 첨부파일 개수 확인: ${item.id}, ${item.updateCode}');
          final attachments = await _apiService.getAttachments(
            entityId: item.id!,
            entityType: 'system_update',
          );
          
          // 임시 ID로 첨부파일 추가 확인
          final tempAttachments = await _apiService.getAttachments(
            entityId: tempId,
            entityType: 'system_update',
          );
          
          // 실제 항목과 임시 항목의 첨부파일 합계
          int totalCount = attachments.length + tempAttachments.length;
          counts[item.id!] = totalCount;
          debugPrint('첨부파일 개수: $totalCount (서버: ${attachments.length}, 임시: ${tempAttachments.length}), 항목: ${item.updateCode}');
        } catch (itemError) {
          debugPrint('항목 첨부파일 개수 로드 중 오류: ${item.updateCode}, $itemError');
          // 오류가 발생한 경우 기존 카운트 유지 (없으면 0으로 설정)
          if (!counts.containsKey(item.id!)) {
            counts[item.id!] = 0;
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _attachmentCounts = counts;
          debugPrint('첨부파일 개수 업데이트 완료: ${counts.length}개 항목');
        });
        
        // 그리드 새로고침
        _refreshPlutoGrid();
      }
    } catch (e) {
      debugPrint('첨부파일 개수 로드 중 오류: $e');
      // 오류 발생 시에도 그리드 새로고침
      _refreshPlutoGrid();
    }
  }

  // 첨부파일 팝업 표시 함수
  void _showAttachmentPopup(BuildContext context, SystemUpdateModel update) async {
    final String entityId;
    bool isUnsaved = update.id == null;
    SystemUpdateModel currentUpdate = update;

    if (isUnsaved) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars(); // 기존 스낵바 제거
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('항목을 먼저 저장합니다...'), duration: Duration(seconds: 2)),
        );
      }
      setState(() => _isLoading = true);

      final savedItem = await _saveSpecificRow(currentUpdate);

      if (mounted) {
        setState(() => _isLoading = false);
      }

      if (savedItem != null && savedItem.id != null) {
        entityId = savedItem.id!;
        currentUpdate = savedItem;
        isUnsaved = false;
        debugPrint('항목 저장 성공, 첨부파일 팝업 열기: ID ${entityId}');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars(); // 기존 스낵바 제거
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('항목 저장 실패. 첨부파일을 추가할 수 없습니다.'), backgroundColor: Colors.red),
          );
        }
        return;
      }
    } else {
      entityId = update.id!;
    }
    
    if (mounted) {
      debugPrint('첨부파일 팝업 열기: 항목 ID ${entityId}, 코드 ${currentUpdate.updateCode}');
      showDialog(
        context: context,
        builder: (context) => AttachmentPopup(
          entityId: entityId,
          entityType: 'system_update',
          entityName: '솔루션 개발 [${currentUpdate.updateCode}]',
        ),
      ).then((_) async {
        debugPrint('첨부파일 팝업 닫힘, 첨부파일 개수 다시 로드');
        // 첨부파일 개수 즉시 로드하고 UI 갱신
        await _loadAttachmentCounts();
        _refreshPlutoGrid();
      });
    }
  }

  // 샘플 데이터 생성 함수 추가
  List<SystemUpdateModel> _getSampleUpdateData() {
    return List.generate(25, (index) {
      final now = DateTime.now();
      final regDate = now.subtract(Duration(days: index * 3));
      final status = _updateStatusList[index % _updateStatusList.length];
      return SystemUpdateModel(
        no: 25 - index,
        regDate: regDate,
        updateCode: _generateUpdateCode(regDate, 25 - index),
        targetSystem: _targetSystems[index % _targetSystems.length],
        developer: _developerList[index % _developerList.length],
        description: '시스템 기능 개선 및 버그 수정 #${25 - index}. 사용성 향상을 위한 UI 변경 포함.',
        updateType: _updateTypes[index % _updateTypes.length],
        assignee: '담당자${(index % 5) + 1}',
        status: status,
        completionDate: status == '완료' ? regDate.add(Duration(days: (index % 7) + 1)) : null,
        remarks: (index % 4 == 0) ? '긴급 패치 필요' : '',
        isSaved: true,
        isModified: false,
      );
    });
  }

  // 업데이트 코드 생성 함수
  String _generateUpdateCode(DateTime date, int no) {
    final yearMonth = '${date.year.toString().substring(2)}${date.month.toString().padLeft(2, '0')}';
    final seq = no.toString().padLeft(3, '0');
    return 'UPD$yearMonth$seq';
  }

  // 필터링 및 정렬 로직 적용된 데이터 반환
  List<SystemUpdateModel> _getFilteredAndSortedData() {
    List<SystemUpdateModel> filteredData = _updateData;

    // 1. 검색어 필터링
    final searchTerm = _searchController.text.toLowerCase();
    if (searchTerm.isNotEmpty) {
      filteredData = filteredData.where((item) {
        return (item.updateCode?.toLowerCase().contains(searchTerm) ?? false) ||
               (item.targetSystem.toLowerCase().contains(searchTerm)) ||
               (item.developer?.toLowerCase().contains(searchTerm) ?? false) ||
               (item.description.toLowerCase().contains(searchTerm)) ||
               (item.updateType.toLowerCase().contains(searchTerm)) ||
               (item.assignee.toLowerCase().contains(searchTerm)) ||
               (item.status.toLowerCase().contains(searchTerm)) ||
               (item.remarks?.toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    }

    // 2. 드롭다운 필터링
    if (_selectedTargetSystem != null) {
      filteredData = filteredData.where((item) => item.targetSystem == _selectedTargetSystem).toList();
    }
    if (_selectedUpdateType != null) {
      filteredData = filteredData.where((item) => item.updateType == _selectedUpdateType).toList();
    }
    if (_selectedStatus != null) {
      filteredData = filteredData.where((item) => item.status == _selectedStatus).toList();
    }

    // 3. 첨부파일 유무 필터링 (새로 추가)
    if (_filterByAttachment) {
      filteredData = filteredData.where((item) {
        final attachmentCount = item.id != null ? _attachmentCounts[item.id] ?? 0 : 0;
        return attachmentCount > 0;
      }).toList();
    }

    // 4. 정렬 (PlutoGrid 내부 정렬 대신 직접 구현)
    filteredData.sort((a, b) {
      int compare = 0;
      switch (_currentSortColumn) {
        case 'no':
          compare = a.no.compareTo(b.no);
          break;
        case 'regDate':
          compare = a.regDate.compareTo(b.regDate);
          break;
        case 'updateCode':
          compare = (a.updateCode ?? '').compareTo(b.updateCode ?? '');
          break;
        case 'targetSystem':
          compare = a.targetSystem.compareTo(b.targetSystem);
          break;
        case 'developer':
          compare = (a.developer ?? '').compareTo(b.developer ?? '');
          break;
        case 'description':
          compare = a.description.compareTo(b.description);
          break;
        case 'updateType':
          compare = a.updateType.compareTo(b.updateType);
          break;
        case 'assignee':
          compare = a.assignee.compareTo(b.assignee);
          break;
        case 'status':
          compare = a.status.compareTo(b.status);
          break;
        case 'completionDate':
          // Handle nulls for date comparison
          DateTime dateA = a.completionDate ?? DateTime(1900);
          DateTime dateB = b.completionDate ?? DateTime(1900);
          compare = dateA.compareTo(dateB);
          break;
        case 'attachments': // 첨부파일 개수로 정렬
          int countA = a.id != null ? _attachmentCounts[a.id] ?? 0 : 0;
          int countB = b.id != null ? _attachmentCounts[b.id] ?? 0 : 0;
          compare = countA.compareTo(countB);
          break;
        case 'remarks':
          compare = (a.remarks ?? '').compareTo(b.remarks ?? '');
          break;
        default:
          compare = a.regDate.compareTo(b.regDate); // Default sort by regDate
      }
      return _isAscending ? compare : -compare;
    });

    return filteredData;
  }

  // 페이지네이션 데이터 계산 (필터링/정렬된 데이터 사용)
  List<SystemUpdateModel> _paginatedData() {
    final data = _getFilteredAndSortedData(); // 수정된 데이터 소스 사용
    if (data.isEmpty) return [];

    // 페이지네이션 재계산
    _totalPages = (data.length / _rowsPerPage).ceil();
    // 현재 페이지가 총 페이지 수를 넘지 않도록 조정
    if (_currentPage >= _totalPages && _totalPages > 0) {
       // Use WidgetsBinding to schedule state update after build
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) { // Check if the widget is still mounted
           setState(() {
             _currentPage = _totalPages - 1;
           });
           _refreshPlutoGrid(); // Refresh grid after page adjustment
         }
       });
    } else if (_currentPage < 0) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) {
           setState(() {
             _currentPage = 0;
           });
           _refreshPlutoGrid();
         }
       });
    }

    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage > data.length)
        ? data.length
        : startIndex + _rowsPerPage;

    if (startIndex >= data.length && data.isNotEmpty) {
       // This case should ideally be handled by the adjustment above
       // If it still happens, return the last page
       int lastPage = _totalPages > 0 ? _totalPages - 1 : 0;
       int lastPageStart = lastPage * _rowsPerPage;
       return data.sublist(lastPageStart, data.length);
    }
    if (startIndex < 0) return data.sublist(0, endIndex); // Should not happen

    return data.sublist(startIndex, endIndex);
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate) async {
    return await showDatePicker(
      context: context, initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020), lastDate: DateTime(2030),
    );
  }

  bool _onCellChanged(PlutoGridOnChangedEvent event) {
    final field = event.column.field;
    final rowIdx = event.rowIdx;
    
    try {
      // rowIdx가 유효한지 확인
      if (rowIdx < 0 || rowIdx >= _paginatedData().length) {
        debugPrint('행 인덱스 범위 오류: $rowIdx (범위: 0-${_paginatedData().length-1})');
        return false;
      }
      
      final SystemUpdateModel oldData = _paginatedData()[rowIdx];
      SystemUpdateModel newData = oldData;
      
      // event.value가 null인 경우 처리
      final value = event.value;

    switch (field) {
        case 'regDate':
          if (value is DateTime) {
            newData = oldData.copyWith(regDate: value, isModified: true);
          }
          break;
        case 'targetSystem':
          final strValue = value?.toString() ?? '';
          newData = oldData.copyWith(targetSystem: strValue, isModified: true);
          break;
        case 'developer':
          final strValue = value?.toString() ?? '';
          newData = oldData.copyWith(developer: strValue, isModified: true);
          break;
        case 'description':
          final strValue = value?.toString() ?? '';
          newData = oldData.copyWith(description: strValue, isModified: true);
          break;
        case 'updateType':
          final strValue = value?.toString() ?? '';
          newData = oldData.copyWith(updateType: strValue, isModified: true);
          break;
        case 'assignee':
          final strValue = value?.toString() ?? '';
          newData = oldData.copyWith(assignee: strValue, isModified: true);
          break;
        case 'status':
          final strValue = value?.toString() ?? '';
          newData = oldData.copyWith(status: strValue, isModified: true);
          break;
        case 'completionDate':
          if (value is DateTime) {
            newData = oldData.copyWith(completionDate: value, isModified: true);
          } else if (value == null) {
            newData = oldData.copyWith(clearCompletionDate: true, isModified: true);
          }
          break;
        case 'remarks':
          final strValue = value?.toString() ?? '';
          newData = oldData.copyWith(remarks: strValue, isModified: true);
          break;
      }
      
      // 원본 데이터 배열에서 아이템 업데이트
      final updateIdx = _updateData.indexWhere((item) => item.no == oldData.no);
      if (updateIdx != -1) {
        setState(() {
          _updateData[updateIdx] = newData;
          _hasUnsavedChanges = true;
        });
        
        // 딜레이 후 자동 저장 실행
        if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
        _debounceTimer = Timer(const Duration(seconds: 3), () {
          if (mounted && _hasUnsavedChanges) {
            debugPrint('자동 저장 실행 (셀 변경 후)');
            _autoSave();
          }
        });
        
        return true;
      } else {
        debugPrint('데이터 업데이트 실패: 항목 #${oldData.no}을 찾을 수 없음');
        return false;
      }
    } catch (e) {
      debugPrint('셀 변경 이벤트 처리 중 오류: $e');
      return false;
    }
  }
  
  // 자동 저장 기능
  void _autoSave() {
    if (_hasUnsavedChanges) {
      debugPrint('자동 저장 시작...');
      _saveAllData();
    } else {
      debugPrint('자동 저장 필요 없음: 변경사항 없음');
    }
  }

  List<PlutoRow> _getPlutoRows() {
    final List<PlutoRow> rows = [];
    final pageData = _paginatedData();
    
    try {
      for (var index = 0; index < pageData.length; index++) {
        final data = pageData[index];
        
        // 첨부파일 개수 가져오기
        final attachmentCount = data.id != null ? _attachmentCounts[data.id] ?? 0 : 0;
        final attachmentText = attachmentCount > 0 ? '첨부($attachmentCount)' : '첨부';
        
        // 행 생성
        final PlutoRow row = PlutoRow(
          cells: {
            'selected': PlutoCell(value: _selectedUpdateCodes.contains(data.updateCode)),
            'no': PlutoCell(value: data.no.toString()),
            'regDate': PlutoCell(value: data.regDate),
            'updateCode': PlutoCell(value: data.updateCode ?? ''),
            'targetSystem': PlutoCell(value: data.targetSystem),
            'developer': PlutoCell(value: data.developer ?? _developerList.first),
            'description': PlutoCell(value: data.description),
            'updateType': PlutoCell(value: data.updateType),
            'assignee': PlutoCell(value: data.assignee),
            'status': PlutoCell(value: data.status),
            'completionDate': PlutoCell(value: data.completionDate),
            'attachments': PlutoCell(value: attachmentText),
            'remarks': PlutoCell(value: data.remarks),
          },
        );
        
        rows.add(row);
      }
      return rows;
    } catch (e) {
      debugPrint('PlutoRow 생성 중 오류: $e');
      return [];
    }
  }

  List<PlutoColumn> _getGridColumns() {
    return [
      PlutoColumn(
        title: '번호',
        field: 'no',
        type: PlutoColumnType.number(),
        width: 70,
        minWidth: 60,
        readOnly: true, // 항목 번호는 수정 불가
        textAlign: PlutoColumnTextAlign.right,
        enableColumnDrag: false,
        sort: PlutoColumnSort.ascending,
      ),
      PlutoColumn( title: '', field: 'selected', type: PlutoColumnType.text(), width: 40, enableEditingMode: false, textAlign: PlutoColumnTextAlign.center, renderer: (ctx) => _buildCheckboxRenderer(ctx)),
      PlutoColumn( title: '코드', field: 'updateCode', type: PlutoColumnType.text(), width: 150, minWidth: 120, readOnly: true, // 코드는 자동 생성되므로 수정 불가
        enableColumnDrag: false,
        sort: PlutoColumnSort.ascending,
      ),
      PlutoColumn( title: '솔루션분류', field: 'targetSystem', type: PlutoColumnType.select(_targetSystems), width: 100, enableEditingMode: true, sort: PlutoColumnSort.ascending ),
      PlutoColumn( title: '개발사', field: 'developer', type: PlutoColumnType.select(_developerList), width: 100, enableEditingMode: true, sort: PlutoColumnSort.ascending ),
      PlutoColumn( title: '세부내용', field: 'description', type: PlutoColumnType.text(), width: 300, enableEditingMode: true, sort: PlutoColumnSort.ascending ),
      PlutoColumn( title: '업데이트유형', field: 'updateType', type: PlutoColumnType.select(_updateTypes), width: 110, enableEditingMode: true, sort: PlutoColumnSort.ascending ),
      PlutoColumn( title: '담당자', field: 'assignee', type: PlutoColumnType.text(), width: 80, enableEditingMode: true, sort: PlutoColumnSort.ascending ),
      PlutoColumn( title: '상태', field: 'status', type: PlutoColumnType.select(_updateStatusList), width: 80, enableEditingMode: true, sort: PlutoColumnSort.ascending ),
      PlutoColumn( title: '완료일정', field: 'completionDate', type: PlutoColumnType.date(), width: 120, enableEditingMode: true, sort: PlutoColumnSort.ascending ),
      PlutoColumn(
        title: '첨부파일',
        field: 'attachments',
        type: PlutoColumnType.text(),
        width: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        sort: PlutoColumnSort.none,
        // titleRenderer -> titleSpan 으로 변경
        titleSpan: _buildAttachmentHeaderSpan(), // Use titleSpan for custom header
        renderer: (ctx) => _buildAttachmentRenderer(ctx),
      ),
      PlutoColumn( title: '비고', field: 'remarks', type: PlutoColumnType.text(), width: 150, enableEditingMode: true, sort: PlutoColumnSort.none ), // Disable internal sort
    ];
  }

  // 첨부파일 컬럼 헤더 Span 생성 함수 (BuildContext 제거)
  InlineSpan _buildAttachmentHeaderSpan() {
    // Access theme data indirectly if needed, or use fixed styles
    final headerColor = _filterByAttachment ? Colors.blue.shade700 : Colors.black87;

    return WidgetSpan(
       alignment: PlaceholderAlignment.middle,
       child: InkWell(
         onTap: () {
           setState(() {
             _filterByAttachment = !_filterByAttachment; // 필터 상태 토글
             _currentPage = 0; // 필터 변경 시 첫 페이지로
           });
           _refreshPlutoGrid(); // 필터 적용된 그리드 새로고침
         },
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 4.0), // Adjust padding
           child: Text(
             '첨부파일',
             style: TextStyle(
               fontWeight: FontWeight.w500, // Standard header weight
               fontSize: 13, // Match other headers
               color: headerColor,
             ),
           ),
         ),
       ),
     );
  }

  Widget _buildCheckboxRenderer(PlutoColumnRendererContext context) {
    return Center(
      child: Checkbox(
        value: context.cell.value as bool? ?? false,
        onChanged: (bool? value) {
          final rowIdx = context.rowIdx;
          if (rowIdx < 0 || rowIdx >= _paginatedData().length) return;
          
          final data = _paginatedData()[rowIdx];
          _handleRowCheckChanged(data.updateCode, rowIdx, value ?? false);
          
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
  
  // 첨부파일 셀 렌더러
  Widget _buildAttachmentRenderer(PlutoColumnRendererContext context) {
    final cellValue = context.cell.value as String? ?? '첨부';
    final rowIdx = context.rowIdx;
    
    // 셀 값에서 첨부파일 개수 추출
    int attachmentCount = 0;
    if (cellValue.startsWith('첨부(') && cellValue.endsWith(')')) {
      final countStr = cellValue.substring(3, cellValue.length - 1);
      attachmentCount = int.tryParse(countStr) ?? 0;
    }
    
    final hasAttachments = attachmentCount > 0;
    
    // 색상 및 스타일 설정
    final textColor = hasAttachments ? Colors.blue.shade700 : Colors.grey.shade700;
    final fontWeight = hasAttachments ? FontWeight.w500 : FontWeight.normal;
    
    return InkWell(
      onTap: () {
        if (rowIdx < 0 || rowIdx >= _paginatedData().length) return;
        
        final update = _paginatedData()[rowIdx];
        _showAttachmentPopup(context.stateManager.gridFocusNode.context!, update);
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_file,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                hasAttachments ? '첨부($attachmentCount)' : '첨부', // 개수 표시
                style: TextStyle(
                  color: textColor,
                  fontWeight: fontWeight,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRowCheckChanged(String? code, int no, bool? checked) {
    if (code == null) return;
    setState(() {
      if (checked == true) {
        _selectedUpdateCodes.add(code);
        
        // 선택된 항목 추가
        final selectedItem = _updateData.firstWhere((item) => item.updateCode == code);
        if (!_selectedItems.contains(selectedItem)) {
          _selectedItems.add(selectedItem);
        }
      } else {
        _selectedUpdateCodes.remove(code);
        
        // 선택된 항목 제거
        _selectedItems.removeWhere((item) => item.updateCode == code);
      }
      
      _hasSelectedItems = _selectedUpdateCodes.isNotEmpty;
    });
  }

  // 행 추가 기능
  void _addEmptyRow() {
    setState(() {
      // 새로운 항목 번호 계산
      final int newNo = _updateData.isEmpty 
        ? 1 
        : (_updateData.map((item) => item.no).reduce((a, b) => a > b ? a : b) + 1);
      
      // 새로운 업데이트 코드 생성
      final now = DateTime.now();
      final String newCode = _generateUpdateCode(now, newNo);

      // 새 업데이트 항목 생성
      final newUpdate = SystemUpdateModel(
        no: newNo,
        regDate: now,
        updateCode: newCode,
        targetSystem: _targetSystems.first,
        developer: _developerList.first,
        description: '',
        updateType: _updateTypes.first,
        assignee: '',
        status: _updateStatusList.first,
        completionDate: null,
        remarks: '',
        isSaved: false,
        isModified: false,
      );
      
      // 새 항목을 목록 맨 앞에 추가
      _updateData.insert(0, newUpdate);
      _hasUnsavedChanges = true;
      
      // 페이지 계산 및 처음 페이지로 설정
      _currentPage = 0;
      _totalPages = (_updateData.length / _rowsPerPage).ceil();
    });
    
    // 그리드 새로고침
    _refreshPlutoGrid();
    
    // 즉시 저장 실행 (서버에 바로 저장)
    _saveNewRow();
  }
  
  // 새로 추가된 행만 서버에 저장
  Future<void> _saveNewRow() async {
    if (_updateData.isEmpty) return;
    
    // 가장 최근에 추가된 미저장 행을 찾음
    final dataToSave = _updateData.firstWhere(
      (item) => !item.isSaved, 
      orElse: () => SystemUpdateModel(
        no: 0, regDate: DateTime.now(), targetSystem: '', 
        developer: _developerList.first, description: '', updateType: '', 
        assignee: '', status: '', remarks: '')
    );
    
    if (dataToSave.no == 0) return; // 유효한 미저장 행이 없는 경우
    
    setState(() => _isLoading = true);
    
    try {
      debugPrint('새 행 저장 시도: ${dataToSave.updateCode}');
      final result = await _apiService.addSystemUpdate(dataToSave);
      
      if (result != null) {
        final index = _updateData.indexWhere((item) => item.no == dataToSave.no);
        if (index != -1) {
          setState(() {
            _updateData[index] = SystemUpdateModel(
              id: result.id,
              no: result.no,
              regDate: result.regDate,
              updateCode: result.updateCode,
              targetSystem: result.targetSystem,
              developer: result.developer,
              description: result.description,
              updateType: result.updateType,
              assignee: result.assignee,
              status: result.status,
              completionDate: result.completionDate,
              remarks: result.remarks,
              isSaved: true,
              isModified: false,
            );
          });
          
          debugPrint('새 행 저장 성공: ${result.updateCode}');
          
          // 로딩 중 표시 짧게 유지 (사용자 경험 향상)
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() => _isLoading = false);
              // 첨부파일 카운트 로드
              _loadAttachmentCounts();
            }
          });
        }
      } else {
        debugPrint('새 행 저장 실패');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('새 행 저장 중 오류: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAllData() async {
    final List<SystemUpdateModel> dataToSave = _updateData
        .where((item) => !item.isSaved || item.isModified)
        .toList();
    
    if (dataToSave.isEmpty) {
      debugPrint('저장할 데이터가 없음');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // 총 저장할 데이터 항목 수 표시
      debugPrint('총 저장할 데이터: ${dataToSave.length}개');
      
      // 각 데이터 항목을 저장
      for (SystemUpdateModel update in dataToSave) {
        try {
          SystemUpdateModel? result;
          
          if (update.isSaved) {
            // 기존 데이터 업데이트
            debugPrint('데이터 업데이트 시도: ${update.updateCode}');
            result = await _apiService.updateSystemUpdate(update);
          } else {
            // 새로운 데이터 추가
            debugPrint('새 데이터 추가 시도: ${update.updateCode}');
            result = await _apiService.addSystemUpdate(update);
          }
          
        if (result != null) {
            final index = _updateData.indexWhere((item) => item.no == update.no);
            if (index != -1) {
              // SystemUpdateModel? -> SystemUpdateModel 변환
              final SystemUpdateModel nonNullResult = SystemUpdateModel(
                id: result.id,
                no: result.no,
                regDate: result.regDate,
                updateCode: result.updateCode,
                targetSystem: result.targetSystem,
                developer: result.developer,
                description: result.description,
                updateType: result.updateType,
                assignee: result.assignee,
                status: result.status,
                completionDate: result.completionDate,
                remarks: result.remarks,
                isSaved: true,
                isModified: false,
              );
              
              setState(() {
                _updateData[index] = nonNullResult;
              });
              
              debugPrint('데이터 저장 성공: ${result.updateCode}');
            }
          }
        } catch (itemError) {
          debugPrint('개별 데이터 저장 중 오류: $itemError');
          // 개별 항목 저장 실패 시에도 계속 진행
          continue;
        }
      }
      
      // 그리드 새로고침
      if (_gridStateManager != null) {
        _gridStateManager!.rows.clear();
        _gridStateManager!.rows.addAll(_getPlutoRows());
        _gridStateManager!.notifyListeners();
      }
      
      // 변경 사항 저장됨 표시
      setState(() {
        _hasUnsavedChanges = false;
      });
      
      // 데이터 다시 로드하여 동기화 상태 확인
      await _reloadData();
      
    } catch (e) {
      debugPrint('데이터 저장 중 오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // 데이터 다시 로드 함수
  Future<void> _reloadData() async {
    try {
      debugPrint('데이터 다시 로드 시도...');
      
      // 로딩 상태 설정
      setState(() => _isLoading = true);
      
      // 저장된 필터 값 및 검색어 유지
      final List<SystemUpdateModel> reloadedData = await _apiService.getSystemUpdates(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        targetSystem: _selectedTargetSystem,
        updateType: _selectedUpdateType,
        status: _selectedStatus
      );
      
      if (reloadedData.isNotEmpty) {
        debugPrint('데이터 다시 로드 성공: ${reloadedData.length}개');
        
        // 현재 선택된 항목들의 코드를 임시 저장
        final selectedCodes = Set<String?>.from(_selectedUpdateCodes);
        
        setState(() {
          _updateData = reloadedData;
          _hasUnsavedChanges = false;
          _totalPages = (_updateData.length / _rowsPerPage).ceil();
          
          // 페이지가 범위를 벗어나면 마지막 페이지로 설정
          if (_currentPage >= _totalPages && _totalPages > 0) {
            _currentPage = _totalPages - 1;
          } else if (_totalPages == 0) {
            _currentPage = 0;
          }
          
          // 선택된 항목 복원
          _selectedUpdateCodes.clear();
          _selectedItems.clear();
          
          for (final code in selectedCodes) {
            if (code != null) {
              final item = _updateData.firstWhere(
                (item) => item.updateCode == code,
                orElse: () => SystemUpdateModel(
                  no: 0, 
                  regDate: DateTime.now(), 
                  targetSystem: '', 
                  developer: _developerList.first,
                  description: '',
                  updateType: '', 
                  assignee: '', 
                  status: '',
                  remarks: ''
                ),
              );
              
              if (item.no != 0) { // 유효한 항목인 경우
                _selectedUpdateCodes.add(code);
                _selectedItems.add(item);
              }
            }
          }
          
          _hasSelectedItems = _selectedUpdateCodes.isNotEmpty;
        });
        
        // 첨부파일 개수 로드
        await _loadAttachmentCounts();
        
        // 그리드 새로고침
        _refreshPlutoGrid();
      } else {
        debugPrint('데이터 다시 로드 실패: 데이터가 없음');
      }
    } catch (e) {
      debugPrint('데이터 다시 로드 중 오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _refreshPlutoGrid() {
    if (_gridStateManager != null) {
      _gridStateManager!.rows.clear();
      _gridStateManager!.rows.addAll(_getPlutoRows());
      _gridStateManager!.notifyListeners();
    }
  }

  Future<void> _deleteSelectedRows() async {
    if (_selectedUpdateCodes.isEmpty) return;
    
    // 확인 다이얼로그 표시
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 삭제 확인'),
        content: Text('선택한 ${_selectedUpdateCodes.length}개 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (result != true) return;
    
    // 실제 삭제 함수 호출
    await _deleteSelectedData();
  }
  
  Future<void> _deleteSelectedData() async {
    setState(() { _isLoading = true; });
    
    try {
      final codesToDelete = List<String>.from(_selectedUpdateCodes.where((code) => code != null).cast<String>());
      
      // 총 삭제할 항목 수 표시
      debugPrint('총 삭제할 데이터: ${codesToDelete.length}개');
      
      // 각 데이터 항목을 삭제
      for (final code in codesToDelete) {
        try {
          debugPrint('데이터 삭제 시도: $code');
        final success = await _apiService.deleteSystemUpdateByCode(code);
          
        if (success) {
            debugPrint('데이터 삭제 성공: $code');
            // 성공 시 로컬 데이터에서도 삭제
          _updateData.removeWhere((d) => d.updateCode == code);
        } else {
            debugPrint('데이터 삭제 실패: $code');
          }
        } catch (itemError) {
          debugPrint('개별 데이터 삭제 중 오류: $itemError');
          // 개별 항목 삭제 실패 시에도 계속 진행
          continue;
        }
      }
      
      setState(() {
        _selectedUpdateCodes.clear(); 
        _selectedItems.clear();
        _hasSelectedItems = false;
        _totalPages = (_updateData.length / _rowsPerPage).ceil();
        
        // 페이지 번호 조정
        if (_totalPages == 0) {
          _currentPage = 0;
        } else if (_currentPage >= _totalPages) {
          _currentPage = _totalPages - 1;
        }
      });
      
      // 그리드 새로고침
      _refreshPlutoGrid();
      
      // 데이터 다시 로드하여 동기화 상태 확인
      await _reloadData();
      
    } catch (e) {
      debugPrint('선택된 데이터 삭제 중 오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 엑셀 내보내기
  Future<void> _exportToExcel() async {
    if (_updateData.isEmpty) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 엑셀 생성
      final excel = Excel.createExcel();
      final sheet = excel['솔루션 개발'];

      // 헤더 설정
      final headers = [
        'No', '등록일', '코드', '솔루션분류', '개발사', '세부내용',
        '업데이트유형', '담당자', '상태', '완료일정', '첨부파일 수', '비고'
      ];

      // 헤더 스타일 생성
      final headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );

      // 헤더 추가
      for (var i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = headers[i]
          ..cellStyle = headerStyle;
      }

      // 날짜 포맷 정의
      final dateFormat = DateFormat('yyyy-MM-dd');

      // 데이터 추가
      for (var i = 0; i < _updateData.length; i++) {
        final item = _updateData[i];
        final rowIndex = i + 1;
        
        // 첨부파일 개수 가져오기
        final attachmentCount = item.id != null ? _attachmentCounts[item.id] ?? 0 : 0;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = item.no.toString();
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = dateFormat.format(item.regDate);
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = item.updateCode ?? '';
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = item.targetSystem;
          
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = item.developer;
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = item.description;
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = item.updateType;
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = item.assignee;
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
          .value = item.status;
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
          .value = item.completionDate != null 
              ? dateFormat.format(item.completionDate!) 
                : '';
                
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
          .value = attachmentCount.toString();
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex))
          .value = item.remarks;
      }

      // 열 너비 자동 조정
      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15.0);
      }
      sheet.setColumnWidth(5, 40.0); // 세부내용 열은 더 넓게

      // 엑셀 파일 생성
      final excelBytes = excel.encode();
      if (excelBytes != null) {
        // 파일 저장
        final dateTimeStr = DateTime.now().toString().split('.').first.replaceAll(RegExp(r'[^\d]'), '');
        final fileName = '솔루션개발_${dateTimeStr}';
        
        if (kIsWeb) {
        await FileSaver.instance.saveFile(
            name: fileName,
            bytes: Uint8List.fromList(excelBytes),
          ext: 'xlsx',
            mimeType: MimeType.microsoftExcel,
          );
        } else {
          final result = await FilePicker.platform.getDirectoryPath();
          if (result != null) {
            final filePath = '$result/$fileName.xlsx';
            final file = File(filePath);
            await file.writeAsBytes(excelBytes);
          }
        }
      }

      setState(() { _isLoading = false; });
    } catch (e) {
      debugPrint('엑셀 내보내기 오류: $e');
      setState(() { _isLoading = false; });
    }
  }

  // 엑셀 가져오기
  void _importFromExcel() {
    _showAdminPasswordDialog();
  }

  // 엑셀 가져오기 전 비밀번호 확인
  Future<bool> _showAdminPasswordDialog() async {
    final passwordController = TextEditingController();
    final validPassword = '1234'; // 실제로는 더 안전한 방식으로 관리해야 함
    
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('관리자 확인'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('데이터 가져오기를 위해 관리자 비밀번호를 입력하세요.'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '비밀번호',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                final isValid = passwordController.text == validPassword;
                Navigator.pop(context, isValid);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  void _changePage(int page) {
    if (page < 0 || page >= _totalPages) return;
    setState(() { _currentPage = page; });
    _refreshPlutoGrid();
    
    // 페이지 변경 시 첨부파일 개수 다시 로드
    _loadAttachmentCounts();
  }

  void _updateSelectedState() { 
    setState(() { 
      _hasSelectedItems = _selectedUpdateCodes.isNotEmpty; 
    }); 
  }

  // 검색 및 필터 적용 시 데이터 로드 함수
  Future<void> _loadFilteredData() async {
    setState(() => _isLoading = true);
    
    try {
      final List<SystemUpdateModel> loadedData = await _apiService.getSystemUpdates(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        targetSystem: _selectedTargetSystem,
        updateType: _selectedUpdateType,
        status: _selectedStatus,
      );
      
      if (loadedData.isNotEmpty) {
        setState(() {
          _updateData = loadedData;
          _totalPages = (_updateData.length / _rowsPerPage).ceil();
          if (_currentPage >= _totalPages) _currentPage = _totalPages > 0 ? _totalPages - 1 : 0;
        });
      } else if (_isDataInitialized) {
        // 실제 API에서 데이터를 이전에 불러왔었고, 필터링 결과가 없는 경우
        setState(() {
          _updateData = [];
          _totalPages = 0;
          _currentPage = 0;
        });
      }
      
      // 첨부파일 개수 로드
      await _loadAttachmentCounts();
      
      // 그리드 새로고침
      _refreshPlutoGrid();
      
    } catch (e) {
      debugPrint('필터링 데이터 로드 중 오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 특정 행 저장 함수 추가
  Future<SystemUpdateModel?> _saveSpecificRow(SystemUpdateModel update) async {
    if (update.isSaved && update.id != null) {
      // 이미 저장된 항목이면 그대로 반환
      return update;
    }
    
    try {
      debugPrint('특정 행 저장 시도 (${update.updateCode})');
      final result = await _apiService.addSystemUpdate(update);
      
      if (result != null) {
        // 저장 성공시 원본 데이터 배열 업데이트
        final index = _updateData.indexWhere((item) => item.no == update.no);
        if (index != -1 && mounted) {
          setState(() {
            _updateData[index] = result.copyWith(isSaved: true, isModified: false);
          });
          
          // 결과 반환
          return result;
        } else {
          return result; // 인덱스 찾지 못하면 그냥 결과 반환
        }
      } else {
        debugPrint('특정 행 저장 실패: API에서 null 반환');
        return null;
      }
    } catch (e) {
      debugPrint('특정 행 저장 중 오류: $e');
      return null;
    }
  }

  // 페이지 전체 빌드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('솔루션 개발'),
        titleSpacing: 16.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _updateTabs.map((tabName) => Tab(text: tabName)).toList(),
          indicatorSize: TabBarIndicatorSize.label, labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 13), padding: const EdgeInsets.only(left: 16.0),
          isScrollable: true, tabAlignment: TabAlignment.start, indicatorColor: Theme.of(context).primaryColor,
          dividerColor: Colors.transparent,
        ),
        elevation: 1,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _buildPageContent(),
    );
  }
  
  Widget _buildPageContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        Column(children: [
          // 1. 필터 (맨 위에 배치)
          _buildFilterBar(),
          
          // 2. 타이틀과 실행 버튼 (한 줄에 표시)
          _buildTitleAndActions(),
          
          // 3. 범례 (데이터 테이블 바로 위에 배치)
          if (_updateData.isNotEmpty) _buildLegend(),
          
          // 4. 데이터 테이블 (Expanded로 남은 공간 채움)
          Expanded(
            child: _updateData.isEmpty
              ? _buildEmptyDataView()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: _buildDataTable(),
                ),
          ),
          
          // 5. 페이지 네비게이션 (맨 아래에 배치)
          if (_updateData.isNotEmpty) _buildPageNavigator(),
        ]),
        UpdateDashboardPage(updateData: _updateData), // 업데이트 대시보드 연결
      ],
    );
  }

  // 필터 위젯
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
                labelText: '솔루션분류',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: _selectedTargetSystem,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ..._targetSystems.map((system) => DropdownMenuItem<String>(
                  value: system,
                  child: Text(system),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTargetSystem = value;
          _currentPage = 0;
                });
                _loadFilteredData();
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // 업데이트유형 필터
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '업데이트유형',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: _selectedUpdateType,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ..._updateTypes.map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUpdateType = value;
                  _currentPage = 0;
                });
                _loadFilteredData();
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
                ..._updateStatusList.map((status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                  _currentPage = 0;
                });
                _loadFilteredData();
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
                  _loadFilteredData();
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
                '솔루션 개발 목록',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '전체 ${_updateData.length}개 항목, ${_currentPage + 1}/${_totalPages} 페이지',
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
                icon: Icon(Icons.save, color: _hasUnsavedChanges ? Colors.yellow : Colors.white),
                label: Text(
                  '데이터 저장${_hasUnsavedChanges ? ' *' : ''}',
                  style: TextStyle(
                    fontWeight: _hasUnsavedChanges ? FontWeight.bold : FontWeight.normal,
                    color: Colors.white
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasUnsavedChanges ? Colors.blue.shade700 : null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _hasSelectedItems ? _deleteSelectedRows : null,
                icon: const Icon(Icons.delete_outline),
                label: Text('행 삭제${_hasSelectedItems ? ' (${_selectedUpdateCodes.length})' : ''}'),
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

  // 범례 (한 줄)
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
          if (_hasUnsavedChanges)
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
  
  // 데이터 테이블 위젯
  Widget _buildDataTable() {
    return DataTableWidget(
      columns: _getGridColumns(),
      rows: _getPlutoRows(),
      gridStateManager: _gridStateManager,
      onLoaded: (event) { _gridStateManager = event.stateManager; _gridStateManager!.setShowColumnFilter(false); },
      onChanged: _onCellChanged,
      currentPage: _currentPage,
      totalPages: _totalPages,
      onPageChanged: _changePage,
      unsavedChanges: _hasUnsavedChanges,
      paginatedDataLength: _paginatedData().length,
    );
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

  // 컬럼 정렬 이벤트 처리 (Ensure this method is defined within the State class)
  void _handleColumnSort(PlutoGridOnSortedEvent event) {
    setState(() {
      _currentSortColumn = event.column.field;
      // PlutoColumnSort enum 대신 직접 boolean 사용
      _isAscending = event.column.sort == PlutoColumnSort.ascending;
      _currentPage = 0; // 정렬 변경 시 첫 페이지로
    });
    _refreshPlutoGrid(); // 정렬 적용된 그리드 새로고침
  }
}

// --- 컴포넌트 위젯 정의 (수정 필요) --- 

// FilterWidget (SystemUpdate 기준 수정)
class FilterWidget extends StatefulWidget {
  final TextEditingController searchController;
  final String? selectedTargetSystem;
  final String? selectedUpdateType;
  final String? selectedStatus;
  final List<String> targetSystems;
  final List<String> updateTypes;
  final List<String> statusList;
  final ValueChanged<String?> onTargetSystemChanged;
  final ValueChanged<String?> onUpdateTypeChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onSearchChanged;

  const FilterWidget({
    super.key,
    required this.searchController,
    required this.selectedTargetSystem,
    required this.selectedUpdateType,
    required this.selectedStatus,
    required this.targetSystems,
    required this.updateTypes,
    required this.statusList,
    required this.onTargetSystemChanged,
    required this.onUpdateTypeChanged,
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
    _debounceTimer = Timer(const Duration(milliseconds: 500), () { widget.onSearchChanged(); });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded( child: DropdownButton<String>( hint: const Text('전체 분류'), value: widget.selectedTargetSystem, isExpanded: true, onChanged: widget.onTargetSystemChanged, items: [null, ...widget.targetSystems].map((s) => DropdownMenuItem<String>(value: s, child: Text(s ?? '전체 분류'))).toList() ) ),
          const SizedBox(width: 12),
          Expanded( child: DropdownButton<String>( hint: const Text('전체 유형'), value: widget.selectedUpdateType, isExpanded: true, onChanged: widget.onUpdateTypeChanged, items: [null, ...widget.updateTypes].map((t) => DropdownMenuItem<String>(value: t, child: Text(t ?? '전체 유형'))).toList() ) ),
          const SizedBox(width: 12),
          Expanded( child: DropdownButton<String>( hint: const Text('전체 상태'), value: widget.selectedStatus, isExpanded: true, onChanged: widget.onStatusChanged, items: [null, ...widget.statusList].map((s) => DropdownMenuItem<String>(value: s, child: Text(s ?? '전체 상태'))).toList() ) ),
          const SizedBox(width: 12),
          Expanded( flex: 2, child: TextField( controller: widget.searchController, decoration: const InputDecoration( hintText: '통합 검색...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()), onChanged: (v) => _handleSearchChange() ) ),
        ],
      ),
    );
  }
}

// ActionButtonsWidget (기존과 동일)
class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onAddRow;
  final VoidCallback onSaveData;
  final VoidCallback onDeleteRows;
  final VoidCallback onExportExcel;
  final VoidCallback onImportExcel;
  final bool hasSelectedItems;
  final int selectedItemCount;
  final bool unsavedChanges;

  const ActionButtonsWidget({
    super.key,
    required this.onAddRow,
    required this.onSaveData,
    required this.onDeleteRows,
    required this.onExportExcel,
    required this.onImportExcel,
    required this.hasSelectedItems,
    required this.selectedItemCount,
    required this.unsavedChanges
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: onAddRow,
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text('행 추가', style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              disabledForegroundColor: Colors.black
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: onSaveData,
            icon: Icon(Icons.save, color: unsavedChanges ? Colors.yellow : Colors.white),
            label: Text(
              '데이터 저장${unsavedChanges ? ' *' : ''}',
              style: TextStyle(
                fontWeight: unsavedChanges ? FontWeight.bold : FontWeight.normal,
                color: Colors.white
              )
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: unsavedChanges ? Colors.blue.shade700 : null,
            ),
          )
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: hasSelectedItems ? onDeleteRows : null,
            icon: const Icon(Icons.delete_outline),
            label: Text('행 삭제${hasSelectedItems ? ' ($selectedItemCount)' : ''}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.red.withOpacity(0.3),
              disabledForegroundColor: Colors.black
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: onExportExcel,
            icon: const Icon(Icons.file_download, color: Colors.white),
            label: const Text('엑셀 다운로드', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white
            )
          )
        ),
        ElevatedButton.icon(
          onPressed: onImportExcel,
          icon: const Icon(Icons.file_upload, color: Colors.white),
          label: const Text('엑셀 업로드', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white
          )
        ),
      ],
    );
  }
}

// DataTableWidget (기존과 동일, SystemUpdateModel 기준)
class DataTableWidget extends StatelessWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final PlutoGridStateManager? gridStateManager;
  final Function(PlutoGridOnLoadedEvent) onLoaded;
  final Function(PlutoGridOnChangedEvent) onChanged;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final bool unsavedChanges;
  final int paginatedDataLength;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
    required this.gridStateManager,
    required this.onLoaded,
    required this.onChanged,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.unsavedChanges,
    required this.paginatedDataLength
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty && paginatedDataLength == 0) {
      return Card(
            elevation: 2,
            child: Container(
              width: double.infinity,
              height: 300,
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Text(
                  '표시할 데이터가 없습니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)
                )
              )
            )
      );
    }
    
    return PlutoGrid(
            columns: columns,
            rows: rows,
            onLoaded: onLoaded,
            onChanged: onChanged,
      mode: PlutoGridMode.normal,
            configuration: PlutoGridConfiguration(
              style: PlutoGridStyleConfig(
                cellTextStyle: const TextStyle(fontSize: 12),
                columnTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                rowColor: Colors.white,
                oddRowColor: Colors.grey.shade50,
                gridBorderColor: Colors.grey.shade300,
                gridBackgroundColor: Colors.transparent,
                borderColor: Colors.grey.shade300,
                activatedColor: Colors.blue.shade100,
                activatedBorderColor: Colors.blue.shade300,
                inactivatedBorderColor: Colors.grey.shade300
              )
            )
    );
  }
}