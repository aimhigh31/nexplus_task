import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:intl/intl.dart';
import '../models/software_model.dart';
import '../services/api_service.dart';
import 'software_dashboard_page.dart';
import 'dart:async';
import 'package:excel/excel.dart' hide Border, BorderStyle, TextStyle, Color;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/data_table_widget.dart';

class SoftwareManagementPage extends StatefulWidget {
  const SoftwareManagementPage({super.key});

  @override
  State<SoftwareManagementPage> createState() => _SoftwareManagementPageState();
}

class _SoftwareManagementPageState extends State<SoftwareManagementPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  final List<String> _softwareTabs = ['데이터 관리', '종합현황'];

  // 페이지네이션
  int _currentPage = 0;
  final int _rowsPerPage = 11;
  int _totalPages = 0;

  // 검색 및 필터
  final TextEditingController _searchController = TextEditingController();
  final List<String> _assetNames = ['Windows', 'MS Office', 'AutoCAD', 'Adobe Creative Cloud', 'Oracle', 'SQL Server', 'SAP', 'VMware', 'Anti-Virus', '기타'];
  final List<String> _executionTypes = ['신규구매', '라이선스 연장', '업그레이드', '유지보수', '만료'];
  String? _selectedAssetName;
  String? _selectedExecutionType;

  // 데이터
  List<SoftwareModel> _softwareData = [];
  List<String> _selectedSoftwareCodes = [];

  // 상태
  bool _isLoading = true;
  bool _hasSelectedItems = false;
  PlutoGridStateManager? _gridStateManager;
  bool _unsavedChanges = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _softwareTabs.length, vsync: this);
    _loadSoftwareData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSoftwareData() async {
    setState(() { _isLoading = true; });
    
    try {
      final softwareData = await _apiService.getSoftwareData(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        assetName: _selectedAssetName,
        executionType: _selectedExecutionType,
      );
      
      if (mounted) {
        setState(() {
          _softwareData = softwareData;
          _totalPages = (_softwareData.length / _rowsPerPage).ceil();
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
      debugPrint('소프트웨어 데이터 로드 오류: $e');
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  List<SoftwareModel> _paginatedData() {
    if (_softwareData.isEmpty) return [];
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage > _softwareData.length)
        ? _softwareData.length
        : startIndex + _rowsPerPage;
    if (startIndex >= _softwareData.length) {
      if (_currentPage > 0) { _currentPage = 0; return _paginatedData(); }
      return [];
    }
    return _softwareData.sublist(startIndex, endIndex);
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
    final dataIdx = _softwareData.indexWhere((d) => d.code == code);
    if (dataIdx == -1) return;

    final currentData = _softwareData[dataIdx];
    SoftwareModel updatedData;

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
      case 'unitPrice': 
        final priceValue = double.tryParse(event.value.toString()) ?? currentData.unitPrice;
        updatedData = currentData.copyWith(
          unitPrice: priceValue, 
          totalPrice: priceValue * currentData.quantity,
          isModified: true
        ); 
        break;
      case 'totalPrice': 
        final totalValue = double.tryParse(event.value.toString()) ?? currentData.totalPrice;
        updatedData = currentData.copyWith(totalPrice: totalValue, isModified: true); 
        break;
      case 'lotCode': updatedData = currentData.copyWith(lotCode: event.value, isModified: true); break;
      case 'detail': updatedData = currentData.copyWith(detail: event.value, isModified: true); break;
      case 'contractStartDate': updatedData = currentData.copyWith(contractStartDate: event.value, isModified: true); break;
      case 'contractEndDate': updatedData = currentData.copyWith(contractEndDate: event.value, isModified: true); break;
      case 'remarks': updatedData = currentData.copyWith(remarks: event.value, isModified: true); break;
      default: return;
    }
    _softwareData[dataIdx] = updatedData;
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
          'selected': PlutoCell(value: _selectedSoftwareCodes.contains(data.code)),
          'regDate': PlutoCell(value: data.regDate),
          'code': PlutoCell(value: data.code ?? ''),
          'assetCode': PlutoCell(value: data.assetCode),
          'assetName': PlutoCell(value: data.assetName),
          'specification': PlutoCell(value: data.specification),
          'executionType': PlutoCell(value: data.executionType),
          'quantity': PlutoCell(value: data.quantity),
          'unitPrice': PlutoCell(value: data.unitPrice),
          'totalPrice': PlutoCell(value: data.totalPrice),
          'lotCode': PlutoCell(value: data.lotCode),
          'detail': PlutoCell(value: data.detail),
          'contractStartDate': PlutoCell(value: data.contractStartDate),
          'contractEndDate': PlutoCell(value: data.contractEndDate),
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
      PlutoColumn( title: '자산명', field: 'assetName', type: PlutoColumnType.select(_assetNames), width: 150, enableEditingMode: true ),
      PlutoColumn( title: '규격', field: 'specification', type: PlutoColumnType.text(), width: 120, enableEditingMode: true ),
      PlutoColumn( title: '실행유형', field: 'executionType', type: PlutoColumnType.select(_executionTypes), width: 100, enableEditingMode: true ),
      PlutoColumn( title: '수량', field: 'quantity', type: PlutoColumnType.number(), width: 80, enableEditingMode: true ),
      PlutoColumn( title: '단가', field: 'unitPrice', type: PlutoColumnType.number(format: '#,###.##'), width: 100, enableEditingMode: true ),
      PlutoColumn( title: '금액', field: 'totalPrice', type: PlutoColumnType.number(format: '#,###.##'), width: 100, enableEditingMode: true ),
      PlutoColumn( title: 'LOT코드', field: 'lotCode', type: PlutoColumnType.text(), width: 100, enableEditingMode: true ),
      PlutoColumn( title: '세부내용', field: 'detail', type: PlutoColumnType.text(), width: 200, enableEditingMode: true ),
      PlutoColumn( title: '계약시작일', field: 'contractStartDate', type: PlutoColumnType.date(), width: 120, enableEditingMode: true ),
      PlutoColumn( title: '계약종료일', field: 'contractEndDate', type: PlutoColumnType.date(), width: 120, enableEditingMode: true ),
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
    int newNo = _softwareData.map((d) => d.no).fold(0, (max, c) => c > max ? c : max) + 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final newCode = 'SW-${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}-${newNo.toString().padLeft(3, '0')}';
    
    final softwareModel = SoftwareModel(
      no: newNo,
      code: newCode,
      regDate: today,
      assetCode: '',
      assetName: _assetNames.first,
      specification: '',
      executionType: _executionTypes.first,
      quantity: 1,
      unitPrice: 0.0,
      totalPrice: 0.0,
      lotCode: '',
      detail: '',
      remarks: '',
      isModified: true,
    );
    
    setState(() {
      _softwareData.insert(0, softwareModel);
      _currentPage = 0;
      _totalPages = (_softwareData.length / _rowsPerPage).ceil();
      _unsavedChanges = true;
    });
    
    _refreshPlutoGrid();
  }

  Future<void> _saveAllData() async {
    if (_gridStateManager == null) return;
    setState(() { _isLoading = true; });

    List<SoftwareModel> toCreate = _softwareData.where((d) => !d.isSaved).toList();
    List<SoftwareModel> toUpdate = _softwareData.where((d) => d.isSaved && d.isModified).toList();
    int totalToSave = toCreate.length + toUpdate.length;
    int successCount = 0;
    int failCount = 0;

    if (totalToSave == 0) {
      setState(() { _isLoading = false; _unsavedChanges = false; });
      return;
    }

    try {
      // 신규 항목 생성
      for (var item in toCreate) {
        try {
          final result = await _apiService.addSoftware(item);
          if (result != null) {
            successCount++;
            final idx = _softwareData.indexWhere((d) => d.code == item.code);
            if (idx != -1) {
              _softwareData[idx] = result.copyWith(isSaved: true, isModified: false);
            }
          } else {
            failCount++;
          }
        } catch (e) {
          failCount++;
          debugPrint('소프트웨어 추가 실패: $e');
        }
      }

      // 기존 항목 업데이트
      for (var item in toUpdate) {
        try {
          final result = await _apiService.updateSoftware(item);
          if (result != null) {
            successCount++;
            final idx = _softwareData.indexWhere((d) => d.code == item.code);
            if (idx != -1) {
              _softwareData[idx] = result.copyWith(isModified: false);
            }
          } else {
            failCount++;
          }
        } catch (e) {
          failCount++;
          debugPrint('소프트웨어 수정 실패: $e');
        }
      }

      // 전체 데이터 다시 로드
      if (mounted) {
        _loadSoftwareData();
      }
    } catch (e) {
      debugPrint('소프트웨어 데이터 저장 중 오류: $e');
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _deleteSelectedRows() {
    if (_selectedSoftwareCodes.isEmpty) return;
    final codesToDelete = List<String>.from(_selectedSoftwareCodes);
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

  void _deleteCodesSequentially(List<String> codes) async {
    int successCount = 0;
    int failCount = 0;
    
    for (final code in codes) {
      try {
        final success = await _apiService.deleteSoftwareByCode(code);
        if (success) {
          successCount++;
          _softwareData.removeWhere((d) => d.code == code);
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
        debugPrint('소프트웨어 삭제 실패: $e');
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _selectedSoftwareCodes.clear();
        _hasSelectedItems = false;
        _totalPages = (_softwareData.length / _rowsPerPage).ceil();
        if (_totalPages == 0) _currentPage = 0;
        else if (_currentPage >= _totalPages) _currentPage = _totalPages - 1;
      });
      _refreshPlutoGrid();
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
      if (_selectedSoftwareCodes.contains(code)) _selectedSoftwareCodes.remove(code);
      else _selectedSoftwareCodes.add(code);
      _hasSelectedItems = _selectedSoftwareCodes.isNotEmpty;
    });
    _refreshPlutoGrid();
  }

  void _updateSelectedState() { 
    setState(() { _hasSelectedItems = _selectedSoftwareCodes.isNotEmpty; }); 
  }

  // 엑셀 내보내기
  Future<void> _exportToExcel() async {
    if (_softwareData.isEmpty) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 엑셀 생성
      final excel = Excel.createExcel();
      final sheet = excel['소프트웨어 자산'];

      // 헤더 설정
      final headers = [
        'No', '등록일', '자산코드', '자산명', '사양', '실행유형',
        '수량', '단가', '금액', 'LOT 번호', '세부내용',
        '계약시작일', '계약종료일', '비고'
      ];

      // 헤더 스타일
      final headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );

      // 헤더 추가
      for (var i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = TextCellValue(headers[i])
          ..cellStyle = headerStyle;
      }

      // 날짜 포맷
      final dateFormat = DateFormat('yyyy-MM-dd');

      // 데이터 추가
      for (var i = 0; i < _softwareData.length; i++) {
        final data = _softwareData[i];
        final rowIndex = i + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(data.no.toString());

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(dateFormat.format(data.regDate));

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(data.assetCode);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(data.assetName);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = TextCellValue(data.specification);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = TextCellValue(data.executionType);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = TextCellValue(data.quantity.toString());

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = TextCellValue(data.unitPrice.toStringAsFixed(0));

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
          .value = TextCellValue(data.totalPrice.toStringAsFixed(0));

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
          .value = TextCellValue(data.lotCode ?? '');

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
          .value = TextCellValue(data.detail);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex))
          .value = TextCellValue(data.contractStartDate != null ? 
            dateFormat.format(data.contractStartDate!) : '');

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: rowIndex))
          .value = TextCellValue(data.contractEndDate != null ? 
            dateFormat.format(data.contractEndDate!) : '');

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: rowIndex))
          .value = TextCellValue(data.remarks);
      }

      // 열 너비 조정
      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15.0);
      }
      sheet.setColumnWidth(10, 30.0); // 세부내용 열은 더 넓게

      // 파일 저장
      final excelBytes = excel.encode();
      if (excelBytes != null) {
        final dateTimeStr = DateTime.now().toString().split('.').first.replaceAll(RegExp(r'[^\d]'), '');
        final fileName = '소프트웨어자산_${dateTimeStr}';

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

  // 엑셀 가져오기 비밀번호 확인
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

  // 엑셀 가져오기
  Future<void> _importFromExcel() async {
    // 관리자 비밀번호 확인
    final isAuthorized = await _showAdminPasswordDialog();
    if (!isAuthorized) return;
    
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
        'No', '등록일', '자산코드', '자산명', '사양', '실행유형',
        '수량', '단가', '금액', 'LOT 번호', '세부내용',
        '계약시작일', '계약종료일', '비고'
      ];

      final headerRow = rows[0];
      for (var i = 0; i < requiredHeaders.length; i++) {
        if (i >= headerRow.length || 
            headerRow[i]?.value.toString().trim() != requiredHeaders[i]) {
          throw Exception('열 헤더가 예상과 다릅니다. 템플릿을 확인하세요.');
        }
      }

      // 데이터 파싱
      final newItems = <SoftwareModel>[];
      final dateFormat = DateFormat('yyyy-MM-dd');

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || row.length < requiredHeaders.length) continue;

        try {
          final noCell = row[0]?.value?.toString() ?? '';
          if (noCell.isEmpty) continue;

          final no = int.tryParse(noCell) ?? 0;
          if (no <= 0) continue;

          final regDateStr = row[1]?.value?.toString() ?? '';
          final regDate = regDateStr.isNotEmpty 
              ? dateFormat.parse(regDateStr) 
              : DateTime.now();

          final assetCode = row[2]?.value?.toString() ?? '';
          final code = assetCode.isNotEmpty 
              ? assetCode 
              : 'SW-${DateFormat('yyyyMMdd').format(regDate)}-${no.toString().padLeft(3, '0')}';

          final assetName = row[3]?.value?.toString() ?? '';
          final specification = row[4]?.value?.toString() ?? '';
          final executionType = row[5]?.value?.toString() ?? '';
          
          final quantityStr = row[6]?.value?.toString() ?? '1';
          final quantity = int.tryParse(quantityStr) ?? 1;
          
          final unitPriceStr = row[7]?.value?.toString() ?? '0';
          final unitPrice = double.tryParse(unitPriceStr) ?? 0;
          
          final totalPriceStr = row[8]?.value?.toString() ?? '';
          final totalPrice = totalPriceStr.isNotEmpty 
              ? (double.tryParse(totalPriceStr) ?? unitPrice * quantity) 
              : unitPrice * quantity;
          
          final lotCode = row[9]?.value?.toString() ?? '';
          final detail = row[10]?.value?.toString() ?? '';
          
          final contractStartDateStr = row[11]?.value?.toString() ?? '';
          final contractStartDate = contractStartDateStr.isNotEmpty 
              ? dateFormat.parse(contractStartDateStr) 
              : regDate;
          
          final contractEndDateStr = row[12]?.value?.toString() ?? '';
          DateTime? contractEndDate;
          if (contractEndDateStr.isNotEmpty) {
            try {
              contractEndDate = dateFormat.parse(contractEndDateStr);
            } catch (_) {}
          }
          
          final remarks = row[13]?.value?.toString() ?? '';

          newItems.add(SoftwareModel(
            no: no,
            regDate: regDate,
            code: code,
            assetCode: assetCode,
            assetName: assetName,
            specification: specification,
            executionType: executionType,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
            lotCode: lotCode,
            detail: detail,
            contractStartDate: contractStartDate,
            contractEndDate: contractEndDate,
            remarks: remarks,
            isSaved: false,
            isModified: true,
          ));
        } catch (e) {
          debugPrint('행 $i 파싱 오류: $e');
        }
      }

      if (newItems.isNotEmpty) {
        setState(() {
          _softwareData.addAll(newItems);
          _softwareData.sort((a, b) => b.no.compareTo(a.no));
          _totalPages = (_softwareData.length / _rowsPerPage).ceil();
          _currentPage = 0;
          _unsavedChanges = true;
        });
        _refreshPlutoGrid();
      }
      
      setState(() { _isLoading = false; });
    } catch (e) {
      debugPrint('엑셀 가져오기 오류: $e');
      setState(() { _isLoading = false; });
    }
  }

  // 데이터 탭 UI 빌드 (컴포넌트 사용)
  Widget _buildDataTab() {
    return Column(
      children: [
        // 필터 위젯
        SoftwareFilterWidget(
          searchController: _searchController,
          selectedAssetName: _selectedAssetName,
          selectedExecutionType: _selectedExecutionType,
          assetNames: _assetNames,
          executionTypes: _executionTypes,
          onAssetNameChanged: (value) { setState(() { _selectedAssetName = value; _currentPage = 0; _loadSoftwareData(); }); },
          onExecutionTypeChanged: (value) { setState(() { _selectedExecutionType = value; _currentPage = 0; _loadSoftwareData(); }); },
          onSearchChanged: () { setState(() { _currentPage = 0; _loadSoftwareData(); }); },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('소프트웨어 관리', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  if (_softwareData.isNotEmpty) Text('전체 ${_softwareData.length}개 항목, ${_currentPage + 1}/${_totalPages} 페이지', style: TextStyle(color: Colors.grey[600])),
                ]
              ),
              ActionButtonsWidget(
                onAddRow: _addEmptyRow,
                onSaveData: _saveAllData,
                onDeleteRows: _deleteSelectedRows,
                onExportExcel: _exportToExcel,
                onImportExcel: _importFromExcel,
                hasSelectedItems: _hasSelectedItems,
                selectedItemCount: _selectedSoftwareCodes.length,
                unsavedChanges: _unsavedChanges,
              ),
            ]
          ),
        ),
        Expanded(
          child: _isLoading ? const Center(child: CircularProgressIndicator()) : _softwareData.isEmpty
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
                  unsavedChanges: _unsavedChanges,
                  onCellChanged: _handleCellChanged,
                  onLoaded: (event) { _gridStateManager = event.stateManager; _gridStateManager!.setShowColumnFilter(false); },
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onPageChanged: _changePage,
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
        title: const Text('소프트웨어 관리'),
        titleSpacing: 16.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _softwareTabs.map((tabName) => Tab(text: tabName)).toList(),
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
          const SoftwareDashboardPage(),
        ],
      ),
    );
  }
}

// --- 컴포넌트 위젯 정의 ---

// 소프트웨어 필터 위젯
class SoftwareFilterWidget extends StatefulWidget {
  final TextEditingController searchController;
  final String? selectedAssetName;
  final String? selectedExecutionType;
  final List<String> assetNames;
  final List<String> executionTypes;
  final ValueChanged<String?> onAssetNameChanged;
  final ValueChanged<String?> onExecutionTypeChanged;
  final VoidCallback onSearchChanged;

  const SoftwareFilterWidget({
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
  State<SoftwareFilterWidget> createState() => _SoftwareFilterWidgetState();
}

class _SoftwareFilterWidgetState extends State<SoftwareFilterWidget> {
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
        LegendItem(label: '신규', color: Colors.blue.shade100),
        LegendItem(label: '수정', color: Colors.amber.shade100),
      ],
    );
  }
} 