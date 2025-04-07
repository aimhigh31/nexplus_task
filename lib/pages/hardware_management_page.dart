import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:intl/intl.dart';
import '../models/hardware_model.dart';
import '../services/api_service.dart';
import 'hardware_dashboard_page.dart';
import 'dart:async';
import 'package:excel/excel.dart' hide Border, BorderStyle, TextStyle, Color;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'dart:io';

class HardwareManagementPage extends StatefulWidget {
  const HardwareManagementPage({super.key});

  @override
  State<HardwareManagementPage> createState() => _HardwareManagementPageState();
}

class _HardwareManagementPageState extends State<HardwareManagementPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  final List<String> _hardwareTabs = ['데이터 관리', '종합현황'];

  // 페이지네이션
  int _currentPage = 0;
  final int _rowsPerPage = 11;
  int _totalPages = 0;

  // 검색 및 필터
  final TextEditingController _searchController = TextEditingController();
  final List<String> _assetNames = ['서버', '데스크탑 PC', '노트북', '모니터', '네트워크 스위치', '프린터', '기타'];
  final List<String> _executionTypes = ['신규구매', '사용불출', '수리중', '홀딩', '폐기'];
  String? _selectedAssetName;
  String? _selectedExecutionType;

  // 데이터
  List<HardwareModel> _hardwareData = [];
  List<String> _selectedHardwareCodes = [];

  // 상태
  bool _isLoading = true;
  bool _hasSelectedItems = false;
  PlutoGridStateManager? _gridStateManager;
  bool _unsavedChanges = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _hardwareTabs.length, vsync: this);
    _loadHardwareData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHardwareData() async {
    setState(() { _isLoading = true; });
    try {
      // API 호출 구현
      final hardwareData = await _apiService.getHardwareData(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        assetName: _selectedAssetName,
        executionType: _selectedExecutionType,
      );

      if (mounted) {
        setState(() {
          _hardwareData = hardwareData;
          _totalPages = (_hardwareData.length / _rowsPerPage).ceil();
          if (_totalPages == 0) _currentPage = 0;
          else if (_currentPage >= _totalPages) _currentPage = _totalPages - 1;
          _isLoading = false;
        });
        _refreshPlutoGrid();
      }
    } catch (e) {
      debugPrint('하드웨어 데이터 로드 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('데이터 로드 중 오류: $e')));
        setState(() { _isLoading = false; });
      }
    }
  }

  List<HardwareModel> _paginatedData() {
    if (_hardwareData.isEmpty) return [];
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage > _hardwareData.length)
        ? _hardwareData.length
        : startIndex + _rowsPerPage;
    if (startIndex >= _hardwareData.length) {
      if (_currentPage > 0) { _currentPage = 0; return _paginatedData(); }
      return [];
    }
    return _hardwareData.sublist(startIndex, endIndex);
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate) async {
    return await showDatePicker(
      context: context, initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020), lastDate: DateTime(2030),
    );
  }

  void _handleCellChanged(PlutoGridOnChangedEvent event) {
    final field = event.column.field;
    if (field == 'selected') return;
    final code = event.row.cells['code']?.value as String? ?? '';
    if (code.isEmpty) return;
    final dataIdx = _hardwareData.indexWhere((d) => d.code == code);
    if (dataIdx == -1) return;

    final currentData = _hardwareData[dataIdx];
    HardwareModel updatedData;

    switch (field) {
      case 'regDate': updatedData = currentData.copyWith(regDate: event.value, isModified: true); break;
      case 'assetCode': updatedData = currentData.copyWith(assetCode: event.value, isModified: true); break;
      case 'assetName': updatedData = currentData.copyWith(assetName: event.value, isModified: true); break;
      case 'specification': updatedData = currentData.copyWith(specification: event.value, isModified: true); break;
      case 'executionType': updatedData = currentData.copyWith(executionType: event.value, isModified: true); break;
      case 'quantity': 
        final quantityValue = int.tryParse(event.value.toString()) ?? currentData.quantity;
        updatedData = currentData.copyWith(quantity: quantityValue, isModified: true); 
        break;
      case 'lotCode': updatedData = currentData.copyWith(lotCode: event.value, isModified: true); break;
      case 'detail': updatedData = currentData.copyWith(detail: event.value, isModified: true); break;
      case 'remarks': updatedData = currentData.copyWith(remarks: event.value, isModified: true); break;
      default: return;
    }
    _hardwareData[dataIdx] = updatedData;
    _unsavedChanges = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 10), () { if (mounted) setState(() {}); });
  }

  List<PlutoRow> _getPlutoRows() {
    final List<PlutoRow> rows = [];
    final pageData = _paginatedData();
    for (var index = 0; index < pageData.length; index++) {
      final data = pageData[index];
      rows.add(PlutoRow(
        cells: {
          'selected': PlutoCell(value: _selectedHardwareCodes.contains(data.code)),
          'regDate': PlutoCell(value: data.regDate),
          'code': PlutoCell(value: data.code ?? ''),
          'assetCode': PlutoCell(value: data.assetCode),
          'assetName': PlutoCell(value: data.assetName),
          'specification': PlutoCell(value: data.specification),
          'executionType': PlutoCell(value: data.executionType),
          'quantity': PlutoCell(value: data.quantity),
          'lotCode': PlutoCell(value: data.lotCode),
          'detail': PlutoCell(value: data.detail),
          'remarks': PlutoCell(value: data.remarks),
        },
      ));
    }
    return rows;
  }

  List<PlutoColumn> get _columns {
    return [
      PlutoColumn( title: '', field: 'selected', type: PlutoColumnType.text(), width: 40, enableEditingMode: false, textAlign: PlutoColumnTextAlign.center, renderer: (ctx) => _buildCheckboxRenderer(ctx)),
      PlutoColumn( title: '등록일', field: 'regDate', type: PlutoColumnType.date(), width: 120, enableEditingMode: true ),
      PlutoColumn( title: '코드', field: 'code', type: PlutoColumnType.text(), width: 120, enableEditingMode: false ),
      PlutoColumn( title: '자산코드', field: 'assetCode', type: PlutoColumnType.text(), width: 100, enableEditingMode: true ),
      PlutoColumn( title: '자산명', field: 'assetName', type: PlutoColumnType.select(_assetNames), width: 120, enableEditingMode: true ),
      PlutoColumn( title: '규격', field: 'specification', type: PlutoColumnType.text(), width: 160, enableEditingMode: true ),
      PlutoColumn( title: '실행유형', field: 'executionType', type: PlutoColumnType.select(_executionTypes), width: 100, enableEditingMode: true ),
      PlutoColumn( title: '수량', field: 'quantity', type: PlutoColumnType.number(), width: 80, enableEditingMode: true ),
      PlutoColumn( title: 'LOT 코드', field: 'lotCode', type: PlutoColumnType.text(), width: 100, enableEditingMode: true ),
      PlutoColumn( title: '세부내용', field: 'detail', type: PlutoColumnType.text(), width: 200, enableEditingMode: true ),
      PlutoColumn( title: '비고', field: 'remarks', type: PlutoColumnType.text(), width: 150, enableEditingMode: true ),
    ];
  }

  Widget _buildCheckboxRenderer(PlutoColumnRendererContext context) {
    return Center(
      child: Checkbox(
        value: context.cell.value as bool? ?? false,
        onChanged: (value) => _toggleRowSelection(context.rowIdx),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _addEmptyRow() {
    int newNo = _hardwareData.map((d) => d.no).fold(0, (max, c) => c > max ? c : max) + 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final newCode = HardwareModel.generateHardwareCode(today, newNo);

    final newHardware = HardwareModel(
      no: newNo,
      regDate: today,
      code: newCode,
      assetCode: '',
      assetName: _assetNames.first,
      specification: '',
      executionType: _executionTypes.first,
      quantity: 1,
      lotCode: '',
      detail: '',
      remarks: '',
      isSaved: false,
      isModified: true,
    );
    setState(() {
      _hardwareData.insert(0, newHardware);
      _currentPage = 0;
      _totalPages = (_hardwareData.length / _rowsPerPage).ceil();
      _unsavedChanges = true;
    });
    _refreshPlutoGrid();
  }

  void _saveAllData() async {
    if (_gridStateManager == null) return;
    setState(() { _isLoading = true; });

    List<HardwareModel> toCreate = _hardwareData.where((d) => !d.isSaved).toList();
    List<HardwareModel> toUpdate = _hardwareData.where((d) => d.isSaved && d.isModified).toList();
    int totalToSave = toCreate.length + toUpdate.length;
    int successCount = 0;
    int failCount = 0;

    if (totalToSave == 0) { setState(() { _isLoading = false; _unsavedChanges = false; }); return; }

    // 새로운 데이터 추가
    for (var item in toCreate) {
      try {
        final result = await _apiService.addHardware(item);
        if (result != null) {
          successCount++;
          final idx = _hardwareData.indexWhere((d) => d.code == item.code);
          if (idx != -1) {
            _hardwareData[idx] = result;
          }
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
        debugPrint('하드웨어 추가 실패: $e');
      }
    }

    // 수정된 데이터 업데이트
    for (var item in toUpdate) {
      try {
        final result = await _apiService.updateHardware(item);
        if (result != null) {
          successCount++;
          final idx = _hardwareData.indexWhere((d) => d.code == item.code);
          if (idx != -1) {
            _hardwareData[idx] = result;
          }
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
        debugPrint('하드웨어 수정 실패: $e');
      }
    }

    setState(() { _isLoading = false; _unsavedChanges = failCount > 0; });
    _loadHardwareData(); // 데이터 다시 로드
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('데이터 저장 완료 (성공: $successCount, 실패: $failCount)')));
    }
  }

  void _deleteSelectedRows() {
    if (_selectedHardwareCodes.isEmpty) return;
    final codesToDelete = List<String>.from(_selectedHardwareCodes);
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('행 삭제'),
        content: Text('선택한 ${codesToDelete.length}개 행을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소')
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제')
          )
        ]
      )
    ).then((confirmed) {
      if (confirmed != true) return;
      setState(() { _isLoading = true; });
      _deleteCodesSequentially(codesToDelete);
    });
  }

  Future<void> _deleteCodesSequentially(List<String> codes) async {
    int successCount = 0;
    int failCount = 0;
    
    for (final code in codes) {
      try {
        final success = await _apiService.deleteHardwareByCode(code);
        if (success) {
          successCount++;
          _hardwareData.removeWhere((d) => d.code == code);
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
        debugPrint('하드웨어 삭제 실패: $e');
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false; 
        _selectedHardwareCodes.clear(); 
        _hasSelectedItems = false;
        _totalPages = (_hardwareData.length / _rowsPerPage).ceil();
        if (_totalPages == 0) _currentPage = 0;
        else if (_currentPage >= _totalPages) _currentPage = _totalPages - 1;
      });
      _refreshPlutoGrid();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('선택 항목 삭제 완료 (성공: $successCount, 실패: $failCount)')));
    }
  }

  // 엑셀 내보내기
  Future<void> _exportToExcel() async {
    if (_hardwareData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내보낼 데이터가 없습니다.'))
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 엑셀 생성
      final excel = Excel.createExcel();
      final sheet = excel['하드웨어 관리'];

      // 헤더 설정
      final headers = [
        'No', '등록일', '코드', '자산코드', '자산명',
        '규격', '실행유형', '수량', 'LOT 코드', '세부내용', '비고'
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
      for (var i = 0; i < _hardwareData.length; i++) {
        final data = _hardwareData[i];
        final rowIndex = i + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(data.no.toString());
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(dateFormat.format(data.regDate));
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(data.code ?? '');
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(data.assetCode);
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = TextCellValue(data.assetName);
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(data.specification);
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = TextCellValue(data.executionType);
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = TextCellValue(data.quantity.toString());
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = TextCellValue(data.lotCode);
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = TextCellValue(data.detail);
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
            .value = TextCellValue(data.remarks);
      }

      // 열 너비 자동 조정
      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15.0);
      }
      sheet.setColumnWidth(9, 40.0); // 세부내용 열은 더 넓게

      // 엑셀 저장
      final fileBytes = excel.save(fileName: '하드웨어관리_${dateFormat.format(DateTime.now())}.xlsx');
      
      if (fileBytes != null) {
        await FileSaver.instance.saveFile(
          name: '하드웨어관리_${dateFormat.format(DateTime.now())}',
          bytes: Uint8List.fromList(fileBytes),
          ext: 'xlsx',
          mimeType: MimeType.microsoftExcel
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('엑셀 파일 저장 완료'))
          );
        }
      }
    } catch (e) {
      debugPrint('엑셀 내보내기 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('엑셀 내보내기 실패: $e'))
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // 엑셀 가져오기 전 비밀번호 확인
  Future<void> _showAdminPasswordDialog() async {
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
                if (!isValid && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('비밀번호가 올바르지 않습니다.'))
                  );
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _importFromExcel();
      }
    });
  }

  // 엑셀 가져오기
  Future<void> _importFromExcel() async {
    try {
      // 파일 선택
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.isEmpty) return;

      setState(() { _isLoading = true; });

      final file = result.files.first;
      late List<int> bytes;

      if (kIsWeb) {
        bytes = file.bytes!;
      } else {
        final path = file.path!;
        final fileBytes = File(path).readAsBytesSync();
        bytes = fileBytes;
      }

      // 엑셀 파일 파싱
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]?.rows;

      if (rows == null || rows.isEmpty || rows.length <= 1) {
        throw Exception('유효한 데이터가 없습니다.');
      }

      // 헤더 검증
      final requiredHeaders = [
        'No', '등록일', '코드', '자산코드', '자산명',
        '규격', '실행유형', '수량', 'LOT 코드', '세부내용', '비고'
      ];

      final headerRow = rows[0];
      for (var i = 0; i < requiredHeaders.length; i++) {
        if (i >= headerRow.length || 
            headerRow[i]?.value.toString().trim() != requiredHeaders[i]) {
          throw Exception('열 헤더가 예상과 다릅니다. 템플릿을 확인하세요.');
        }
      }

      // 데이터 파싱
      final newItems = <HardwareModel>[];
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
          final assetCode = row[3]?.value?.toString() ?? '';
          final assetName = row[4]?.value?.toString() ?? '';
          final specification = row[5]?.value?.toString() ?? '';
          final executionType = row[6]?.value?.toString() ?? '';
          final quantityStr = row[7]?.value?.toString() ?? '';
          final lotCode = row[8]?.value?.toString() ?? '';
          final detail = row[9]?.value?.toString() ?? '';
          final remarks = row[10]?.value?.toString() ?? '';

          // 필수 값 확인
          if (regDateStr.isEmpty || assetCode.isEmpty || assetName.isEmpty) {
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

          // 수량 파싱
          final quantity = int.tryParse(quantityStr) ?? 1;
          
          // 코드 생성 (비어있는 경우)
          final finalCode = code.isNotEmpty ? 
                         code : 
                         HardwareModel.generateHardwareCode(regDate, no);

          newItems.add(HardwareModel(
            no: no,
            regDate: regDate,
            code: finalCode,
            assetCode: assetCode,
            assetName: assetName,
            specification: specification,
            executionType: executionType,
            quantity: quantity,
            lotCode: lotCode,
            detail: detail,
            remarks: remarks,
            isSaved: false,
            isModified: true,
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
            final existingIdx = _hardwareData.indexWhere(
              (item) => item.code == newItem.code
            );
            
            if (existingIdx >= 0) {
              // 기존 항목 업데이트
              _hardwareData[existingIdx] = newItem.copyWith(
                id: _hardwareData[existingIdx].id,
                isSaved: _hardwareData[existingIdx].isSaved,
                isModified: true,
              );
            } else {
              // 새 항목 추가
              _hardwareData.add(newItem);
            }
          }
          
          _unsavedChanges = true;
          _currentPage = 0;
          _totalPages = (_hardwareData.length / _rowsPerPage).ceil();
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

  void _changePage(int page) {
    if (page < 0 || page >= _totalPages) return;
    setState(() { _currentPage = page; });
    _refreshPlutoGrid();
  }

  void _refreshPlutoGrid() {
    if (_gridStateManager != null) {
      _gridStateManager!.removeAllRows();
      final rows = _getPlutoRows();
      _gridStateManager!.appendRows(rows);
      if (rows.isNotEmpty) { _gridStateManager!.setCurrentCell(rows.first.cells.values.first, 0); }
      _updateSelectedState();
    }
  }

  void _toggleRowSelection(int rowIdx) {
    if (rowIdx < 0 || rowIdx >= _paginatedData().length) return;
    final code = _paginatedData()[rowIdx].code;
    if (code == null || code.isEmpty) return;
    setState(() {
      if (_selectedHardwareCodes.contains(code)) _selectedHardwareCodes.remove(code);
      else _selectedHardwareCodes.add(code);
      _hasSelectedItems = _selectedHardwareCodes.isNotEmpty;
    });
    _refreshPlutoGrid();
  }

  void _updateSelectedState() { 
    setState(() { _hasSelectedItems = _selectedHardwareCodes.isNotEmpty; }); 
  }

  // 데이터 탭 UI 빌드 (컴포넌트 사용)
  Widget _buildDataTab() {
    return Column(
      children: [
        // 필터 위젯
        HardwareFilterWidget(
          searchController: _searchController,
          selectedAssetName: _selectedAssetName,
          selectedExecutionType: _selectedExecutionType,
          assetNames: _assetNames,
          executionTypes: _executionTypes,
          onAssetNameChanged: (value) { setState(() { _selectedAssetName = value; _currentPage = 0; _loadHardwareData(); }); },
          onExecutionTypeChanged: (value) { setState(() { _selectedExecutionType = value; _currentPage = 0; _loadHardwareData(); }); },
          onSearchChanged: () { setState(() { _currentPage = 0; _loadHardwareData(); }); },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('하드웨어 관리', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  if (_hardwareData.isNotEmpty) Text('전체 ${_hardwareData.length}개 항목, ${_currentPage + 1}/${_totalPages} 페이지', style: TextStyle(color: Colors.grey[600])),
                ]
              ),
              ActionButtonsWidget(
                onAddRow: _addEmptyRow,
                onSaveData: _saveAllData,
                onDeleteRows: _deleteSelectedRows,
                onExportExcel: _exportToExcel,
                onImportExcel: _showAdminPasswordDialog,
                hasSelectedItems: _hasSelectedItems,
                selectedItemCount: _selectedHardwareCodes.length,
                unsavedChanges: _unsavedChanges,
              ),
            ]
          ),
        ),
        Expanded(
          child: _isLoading ? const Center(child: CircularProgressIndicator()) : _hardwareData.isEmpty
            ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('데이터가 없습니다', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addEmptyRow,
                    icon: const Icon(Icons.add),
                    label: const Text('첫 데이터 추가하기')
                  )
                ]
              ))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: DataTableWidget(
                  columns: _columns,
                  rows: _getPlutoRows(),
                  gridStateManager: _gridStateManager,
                  onLoaded: (event) { _gridStateManager = event.stateManager; _gridStateManager!.setShowColumnFilter(false); },
                  onChanged: _handleCellChanged,
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onPageChanged: _changePage,
                  unsavedChanges: _unsavedChanges,
                  paginatedDataLength: _paginatedData().length,
                ),
              ),
        ),
      ],
    );
  }

  // 페이지 전체 빌드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('하드웨어 관리'),
        titleSpacing: 16.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _hardwareTabs.map((tabName) => Tab(text: tabName)).toList(),
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
          _buildDataTab(),
          HardwareDashboardPage(hardwareData: _hardwareData),
        ],
      ),
    );
  }
}

// --- 컴포넌트 위젯 정의 --- 

// 하드웨어 필터 위젯
class HardwareFilterWidget extends StatefulWidget {
  final TextEditingController searchController;
  final String? selectedAssetName;
  final String? selectedExecutionType;
  final List<String> assetNames;
  final List<String> executionTypes;
  final ValueChanged<String?> onAssetNameChanged;
  final ValueChanged<String?> onExecutionTypeChanged;
  final VoidCallback onSearchChanged;

  const HardwareFilterWidget({
    super.key,
    required this.searchController,
    required this.selectedAssetName,
    required this.selectedExecutionType,
    required this.assetNames,
    required this.executionTypes,
    required this.onAssetNameChanged,
    required this.onExecutionTypeChanged,
    required this.onSearchChanged,
  });

  @override
  State<HardwareFilterWidget> createState() => _HardwareFilterWidgetState();
}

class _HardwareFilterWidgetState extends State<HardwareFilterWidget> {
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
          Expanded(
            child: DropdownButton<String>(
              hint: const Text('전체 자산'),
              value: widget.selectedAssetName,
              isExpanded: true,
              onChanged: widget.onAssetNameChanged,
              items: [null, ...widget.assetNames].map((s) => DropdownMenuItem<String>(
                value: s,
                child: Text(s ?? '전체 자산')
              )).toList()
            )
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              hint: const Text('전체 실행유형'),
              value: widget.selectedExecutionType,
              isExpanded: true,
              onChanged: widget.onExecutionTypeChanged,
              items: [null, ...widget.executionTypes].map((t) => DropdownMenuItem<String>(
                value: t,
                child: Text(t ?? '전체 실행유형')
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
    );
  }
}

// 실행 버튼 위젯
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
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.black,
              disabledIconColor: Colors.black
            )
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

// 데이터 테이블 위젯
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
      return Column(
        children: [
          _buildLegend(context),
          const SizedBox(height: 8),
          Card(
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
          )
        ]
      );
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegend(context),
        const SizedBox(height: 8),
        Expanded(
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            onLoaded: onLoaded,
            onChanged: onChanged,
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
          )
        ),
        _buildPagination(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      width: double.infinity,
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
          if (unsavedChanges)
            const Text(
              '* 저장되지 않은 변경사항',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30)
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30)
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${currentPage + 1} / $totalPages',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
            )
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30)
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null,
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
} 