import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
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
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class HardwareManagementPage extends StatefulWidget {
  const HardwareManagementPage({super.key});

  @override
  State<HardwareManagementPage> createState() => _HardwareManagementPageState();
}

class _HardwareManagementPageState extends State<HardwareManagementPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  final List<String> _hardwareTabs = ['데이터관리', '대시보드'];

  // 페이지네이션
  int _currentPage = 0;
  final int _rowsPerPage = 11;
  int _totalPages = 0;

  // 검색 및 필터
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _assetNameController = TextEditingController();
  final List<String> _assetTypes = ['서버', '데스크탑 PC', '노트북', '모니터', '네트워크 스위치', '프린터', '기타'];
  final List<String> _executionTypes = ['신규구매', '사용불출', '수리중', '홀딩', '폐기'];
  String? _selectedAssetType;
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
    _assetNameController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHardwareData() async {
    setState(() { _isLoading = true; });
    try {
      debugPrint('하드웨어 데이터 로드 시작');
      // API 호출 구현
      final hardwareData = await _apiService.getHardwareData(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        assetType: _selectedAssetType,
        assetName: _assetNameController.text.isNotEmpty ? _assetNameController.text : null,
        executionType: _selectedExecutionType,
      );

      debugPrint('하드웨어 데이터 로드 결과: ${hardwareData.length}개 항목');
      
      if (hardwareData.isEmpty) {
        debugPrint('하드웨어 데이터 없음: API 응답이 비어있음');
      } else {
        debugPrint('첫 번째 하드웨어 항목: ${hardwareData.first.code}');
      }

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
        setState(() { 
          _isLoading = false; 
          _hardwareData = [];
          _totalPages = 0;
        });
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
      case 'assetType': updatedData = currentData.copyWith(assetType: event.value, isModified: true); break;
      case 'assetName': updatedData = currentData.copyWith(assetName: event.value, isModified: true); break;
      case 'specification': updatedData = currentData.copyWith(specification: event.value, isModified: true); break;
      case 'unitPrice': 
        final unitPriceValue = double.tryParse(event.value.toString()) ?? currentData.unitPrice;
        updatedData = currentData.copyWith(unitPrice: unitPriceValue, isModified: true); 
        break;
      case 'executionType': updatedData = currentData.copyWith(executionType: event.value, isModified: true); break;
      case 'quantity': 
        final quantityValue = int.tryParse(event.value.toString()) ?? currentData.quantity;
        updatedData = currentData.copyWith(quantity: quantityValue, isModified: true); 
        break;
      case 'purchaseDate': updatedData = currentData.copyWith(purchaseDate: event.value, isModified: true); break;
      case 'serialNumber': updatedData = currentData.copyWith(serialNumber: event.value, isModified: true); break;
      case 'warrantyDate': updatedData = currentData.copyWith(warrantyDate: event.value, isModified: true); break;
      case 'currentUser': updatedData = currentData.copyWith(currentUser: event.value, isModified: true); break;
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
      final unitPrice = data.unitPrice ?? 0.0;
      final totalPrice = unitPrice * data.quantity;
      
      rows.add(PlutoRow(
        cells: {
          'selected': PlutoCell(value: _selectedHardwareCodes.contains(data.code)),
          'regDate': PlutoCell(value: data.regDate),
          'code': PlutoCell(value: data.code ?? ''),
          'assetCode': PlutoCell(value: data.assetCode),
          'assetType': PlutoCell(value: data.assetType ?? _assetTypes.first),
          'assetName': PlutoCell(value: data.assetName),
          'specification': PlutoCell(value: data.specification),
          'unitPrice': PlutoCell(value: unitPrice),
          'quantity': PlutoCell(value: data.quantity),
          'totalPrice': PlutoCell(value: totalPrice),
          'executionType': PlutoCell(value: data.executionType),
          'purchaseDate': PlutoCell(value: data.purchaseDate),
          'serialNumber': PlutoCell(value: data.serialNumber ?? ''),
          'warrantyDate': PlutoCell(value: data.warrantyDate),
          'currentUser': PlutoCell(value: data.currentUser ?? ''),
          'qrButton': PlutoCell(value: '출력'),
          'remarks': PlutoCell(value: data.remarks),
        },
      ));
    }
    return rows;
  }

  List<PlutoColumn> get _columns {
    return [
      PlutoColumn(title: '', field: 'selected', type: PlutoColumnType.text(), width: 40, enableEditingMode: false, textAlign: PlutoColumnTextAlign.center, renderer: (ctx) => _buildCheckboxRenderer(ctx)),
      PlutoColumn(title: '등록일', field: 'regDate', type: PlutoColumnType.date(), width: 100, enableEditingMode: true),
      PlutoColumn(title: '코드', field: 'code', type: PlutoColumnType.text(), width: 120, enableEditingMode: false),
      PlutoColumn(title: '자산코드', field: 'assetCode', type: PlutoColumnType.text(), width: 100, enableEditingMode: true),
      PlutoColumn(title: '자산분류', field: 'assetType', type: PlutoColumnType.select(_assetTypes), width: 100, enableEditingMode: true),
      PlutoColumn(title: '자산명', field: 'assetName', type: PlutoColumnType.text(), width: 120, enableEditingMode: true),
      PlutoColumn(title: '규격', field: 'specification', type: PlutoColumnType.text(), width: 120, enableEditingMode: true),
      PlutoColumn(title: '단가', field: 'unitPrice', type: PlutoColumnType.number(), width: 80, enableEditingMode: true, formatter: (value) => value != null ? NumberFormat('#,###').format(value) : ''),
      PlutoColumn(title: '수량', field: 'quantity', type: PlutoColumnType.number(), width: 60, enableEditingMode: true),
      PlutoColumn(title: '금액', field: 'totalPrice', type: PlutoColumnType.text(), width: 80, enableEditingMode: false, formatter: (value) => value != null ? NumberFormat('#,###').format(value) : ''),
      PlutoColumn(title: '실행유형', field: 'executionType', type: PlutoColumnType.select(_executionTypes), width: 100, enableEditingMode: true),
      PlutoColumn(title: '구매일', field: 'purchaseDate', type: PlutoColumnType.date(), width: 100, enableEditingMode: true),
      PlutoColumn(title: '시리얼넘버', field: 'serialNumber', type: PlutoColumnType.text(), width: 120, enableEditingMode: true),
      PlutoColumn(title: '무상보증일', field: 'warrantyDate', type: PlutoColumnType.date(), width: 100, enableEditingMode: true),
      PlutoColumn(title: '현재사용자', field: 'currentUser', type: PlutoColumnType.text(), width: 100, enableEditingMode: true),
      PlutoColumn(title: 'QR현품표', field: 'qrButton', type: PlutoColumnType.text(), width: 80, enableEditingMode: false, renderer: (ctx) => _buildQrButtonRenderer(ctx)),
      PlutoColumn(title: '비고', field: 'remarks', type: PlutoColumnType.text(), width: 150, enableEditingMode: true),
    ];
  }

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
      assetType: _assetTypes.first,
      assetName: '',
      specification: '',
      unitPrice: 0.0,
      executionType: _executionTypes.first,
      quantity: 1,
      lotCode: '',
      detail: '',
      serialNumber: '',
      purchaseDate: today,
      warrantyDate: today.add(const Duration(days: 365)), // 기본 1년 무상보증
      currentUser: '',
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
    }
  }

  // 엑셀 내보내기
  Future<void> _exportToExcel() async {
    if (_hardwareData.isEmpty) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 엑셀 생성
      final excel = Excel.createExcel();
      final sheet = excel['하드웨어 관리'];

      // 헤더 설정
      final headers = [
        'No', '등록일', '코드', '자산코드', '자산분류', '자산명',
        '규격', '단가', '수량', '금액', '실행유형', '구매일', 
        '시리얼넘버', '무상보증일', '현재사용자', '비고'
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
      final numberFormat = NumberFormat('#,###');

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
            .value = TextCellValue(data.assetType ?? '');
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(data.assetName);
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = TextCellValue(data.specification);
        
        // 단가 필드 - null 처리
        final unitPrice = data.unitPrice ?? 0.0;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = TextCellValue(numberFormat.format(unitPrice));
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = TextCellValue(data.quantity.toString());
        
        // 금액 필드 - null 처리
        final totalPrice = unitPrice * data.quantity;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = TextCellValue(numberFormat.format(totalPrice));
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
            .value = TextCellValue(data.executionType);
        
        // 구매일 필드 - null 처리
        final purchaseDateStr = data.purchaseDate != null 
            ? dateFormat.format(data.purchaseDate!) 
            : '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex))
            .value = TextCellValue(purchaseDateStr);
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: rowIndex))
            .value = TextCellValue(data.serialNumber ?? '');
        
        // 무상보증일 필드 - null 처리
        final warrantyDateStr = data.warrantyDate != null 
            ? dateFormat.format(data.warrantyDate!) 
            : '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: rowIndex))
            .value = TextCellValue(warrantyDateStr);
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: rowIndex))
            .value = TextCellValue(data.currentUser ?? '');
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: rowIndex))
            .value = TextCellValue(data.remarks);
      }

      // 열 너비 자동 조정
      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15.0);
      }
      sheet.setColumnWidth(6, 25.0); // 규격 열은 더 넓게
      sheet.setColumnWidth(12, 25.0); // 시리얼넘버 열은 더 넓게
      sheet.setColumnWidth(15, 25.0); // 비고 열은 더 넓게

      // 엑셀 저장
      final fileBytes = excel.save(fileName: '하드웨어관리_${dateFormat.format(DateTime.now())}.xlsx');
      
      if (fileBytes != null) {
        await FileSaver.instance.saveFile(
          name: '하드웨어관리_${dateFormat.format(DateTime.now())}',
          bytes: Uint8List.fromList(fileBytes),
          ext: 'xlsx',
          mimeType: MimeType.microsoftExcel
        );
      }
    } catch (e) {
      debugPrint('엑셀 내보내기 오류: $e');
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

      // 헤더 검증 - 새 컬럼 추가
      final requiredHeaders = [
        'No', '등록일', '코드', '자산코드', '자산분류', '자산명',
        '규격', '단가', '수량', '금액', '실행유형', '구매일', 
        '시리얼넘버', '무상보증일', '현재사용자', '비고'
      ];

      final headerRow = rows[0];
      // 최소한의 필수 헤더만 검증 (자산코드, 자산명, 실행유형)
      final minColumns = [0, 3, 5, 10]; // No, 자산코드, 자산명, 실행유형 컬럼 인덱스
      for (final idx in minColumns) {
        if (idx >= headerRow.length || headerRow[idx] == null) {
          throw Exception('필수 헤더가 누락되었습니다. 템플릿을 확인하세요.');
        }
      }

      // 데이터 파싱
      final newItems = <HardwareModel>[];
      final dateFormat = DateFormat('yyyy-MM-dd');

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || row.length < minColumns.length) continue;

        try {
          final noCell = row[0]?.value?.toString() ?? '';
          if (noCell.isEmpty) continue;

          final no = int.tryParse(noCell) ?? 0;
          
          // 필수 및 옵션 필드 추출
          final regDateStr = row.length > 1 ? row[1]?.value?.toString() ?? '' : '';
          final code = row.length > 2 ? row[2]?.value?.toString() ?? '' : '';
          final assetCode = row.length > 3 ? row[3]?.value?.toString() ?? '' : '';
          final assetType = row.length > 4 ? row[4]?.value?.toString() ?? '' : '';
          final assetName = row.length > 5 ? row[5]?.value?.toString() ?? '' : '';
          final specification = row.length > 6 ? row[6]?.value?.toString() ?? '' : '';
          final unitPriceStr = row.length > 7 ? row[7]?.value?.toString() ?? '' : '';
          final quantityStr = row.length > 8 ? row[8]?.value?.toString() ?? '' : '';
          final executionType = row.length > 10 ? row[10]?.value?.toString() ?? '' : '';
          final purchaseDateStr = row.length > 11 ? row[11]?.value?.toString() ?? '' : '';
          final serialNumber = row.length > 12 ? row[12]?.value?.toString() ?? '' : '';
          final warrantyDateStr = row.length > 13 ? row[13]?.value?.toString() ?? '' : '';
          final currentUser = row.length > 14 ? row[14]?.value?.toString() ?? '' : '';
          final remarks = row.length > 15 ? row[15]?.value?.toString() ?? '' : '';

          // 필수 값 확인
          if (assetCode.isEmpty || assetName.isEmpty || executionType.isEmpty) {
            debugPrint('행 $i: 필수 필드(자산코드, 자산명, 실행유형) 누락');
            continue;
          }

          // 날짜 파싱 (등록일)
          DateTime regDate;
          try {
            regDate = regDateStr.isNotEmpty ? DateTime.parse(regDateStr) : DateTime.now();
          } catch (e) {
            try {
              regDate = regDateStr.isNotEmpty ? dateFormat.parse(regDateStr) : DateTime.now();
            } catch (e) {
              regDate = DateTime.now();
            }
          }
          
          // 구매일 파싱
          DateTime? purchaseDate;
          if (purchaseDateStr.isNotEmpty) {
            try {
              purchaseDate = DateTime.parse(purchaseDateStr);
            } catch (e) {
              try {
                purchaseDate = dateFormat.parse(purchaseDateStr);
              } catch (e) {
                purchaseDate = null;
              }
            }
          }
          
          // 무상보증일 파싱
          DateTime? warrantyDate;
          if (warrantyDateStr.isNotEmpty) {
            try {
              warrantyDate = DateTime.parse(warrantyDateStr);
            } catch (e) {
              try {
                warrantyDate = dateFormat.parse(warrantyDateStr);
              } catch (e) {
                warrantyDate = null;
              }
            }
          }

          // 수량 파싱
          final quantity = int.tryParse(quantityStr) ?? 1;
          
          // 단가 파싱
          double? unitPrice;
          if (unitPriceStr.isNotEmpty) {
            unitPrice = double.tryParse(unitPriceStr.replaceAll(RegExp(r'[^\d.]'), ''));
          }
          
          // 코드 생성 (비어있는 경우)
          final finalCode = code.isNotEmpty ? 
                         code : 
                         HardwareModel.generateHardwareCode(regDate, no);

          newItems.add(HardwareModel(
            no: no,
            regDate: regDate,
            code: finalCode,
            assetCode: assetCode,
            assetType: assetType,
            assetName: assetName,
            specification: specification,
            unitPrice: unitPrice,
            executionType: executionType,
            quantity: quantity,
            purchaseDate: purchaseDate,
            serialNumber: serialNumber,
            warrantyDate: warrantyDate,
            currentUser: currentUser,
            lotCode: '',
            detail: '',
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
      } else {
      }
    } catch (e) {
      debugPrint('엑셀 가져오기 오류: $e');
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

  // 데이터가 없을 때 표시할 위젯
  Widget _buildEmptyDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.computer_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '하드웨어 데이터가 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아래 버튼을 클릭하여 새 하드웨어 정보를 추가해보세요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
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

  // 필터 위젯
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // 자산분류 필터
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '자산분류',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: _selectedAssetType,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ..._assetTypes.map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAssetType = value;
                  _currentPage = 0;
                });
                _loadHardwareData();
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // 실행유형 필터
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '실행유형',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              value: _selectedExecutionType,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ..._executionTypes.map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedExecutionType = value;
                  _currentPage = 0;
                });
                _loadHardwareData();
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
                  _loadHardwareData();
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
                '하드웨어 자산',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '전체 ${_hardwareData.length}개 항목, ${_currentPage + 1}/${_totalPages} 페이지',
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
                label: Text('행 삭제${_hasSelectedItems ? ' (${_selectedHardwareCodes.length})' : ''}'),
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
                onPressed: _showAdminPasswordDialog,
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

  // 데이터 테이블 위젯
  Widget _buildDataTable() {
    return PlutoGrid(
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
    );
  }

  // QR 버튼 렌더러 수정
  Widget _buildQrButtonRenderer(PlutoColumnRendererContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          final rowIdx = context.rowIdx;
          if (rowIdx < 0 || rowIdx >= _paginatedData().length) return;
          
          final hardware = _paginatedData()[rowIdx];
          // BuildContext를 직접 가져오기
          _showQrTagPopup(this.context, hardware);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(60, 28),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 12),
        ),
        child: const Text('출력'),
      ),
    );
  }

  // QR 현품표 팝업 표시
  void _showQrTagPopup(BuildContext context, HardwareModel hardware) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.grey[200], // 살짝 회색 배경
        content: Container(
          width: 600, // 너비 조정
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '전산자산 현품표',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // QR 코드 및 정보 표시
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // QR 코드 - 크기 유지
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: QrImageView(
                      data: hardware.assetCode,
                      version: QrVersions.auto,
                      size: 150,
                      padding: const EdgeInsets.all(5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 정보 테이블 - 테두리 개선
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FixedColumnWidth(80), // 좁게 조정
                          1: FlexColumnWidth(3),
                        },
                        children: [
                          _buildTableRow('자산코드', hardware.assetCode),
                          _buildTableRow('자산분류', hardware.assetType ?? ''),
                          _buildTableRow('자산명', hardware.assetName),
                          _buildTableRow('규격', hardware.specification),
                          _buildTableRow('구매일', hardware.purchaseDate != null 
                            ? DateFormat('yyyy-MM-dd').format(hardware.purchaseDate!) 
                            : ''),
                          _buildTableRow('시리얼넘버', hardware.serialNumber ?? ''),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 출력 버튼
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _printQrTag(hardware),
                  icon: const Icon(Icons.print),
                  label: const Text('출력하기'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 테이블 행 생성 헬퍼 함수
  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: Text(
              value,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  // PDF 생성 및 출력 함수 개선
  Future<void> _printQrTag(HardwareModel hardware) async {
    try {
      // 한글 폰트 데이터 로드
      final fontData = await rootBundle.load('assets/fonts/NanumGothic-Regular.ttf');
      final fontBytes = fontData.buffer.asUint8List(fontData.offsetInBytes, fontData.lengthInBytes);
      
      // QR 코드 이미지 생성
      final qrPainter = QrPainter(
        data: hardware.assetCode,
        version: QrVersions.auto,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );
      
      // QR 코드를 이미지로 변환
      final qrSize = 150.0; // 크기 조정
      final qrImageRecorder = ui.PictureRecorder();
      final qrImageCanvas = Canvas(qrImageRecorder);
      
      qrPainter.paint(qrImageCanvas, Size(qrSize, qrSize));
      final qrImagePicture = qrImageRecorder.endRecording();
      final qrImage = await qrImagePicture.toImage(qrSize.toInt(), qrSize.toInt());
      final qrImageByteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);
      
      if (qrImageByteData == null) {
        throw Exception('QR 코드 이미지 생성 실패');
      }
      
      final qrImageBytes = qrImageByteData.buffer.asUint8List();
      
      // PDF 직접 생성
      final pdf = pw.Document();
      
      // 한글 폰트 등록
      final koreanFont = pw.Font.ttf(fontBytes.buffer.asByteData());
      
      // 날짜 포맷터
      final dateFormat = DateFormat('yyyy-MM-dd');
      
      // PDF 테마 설정 (한글 폰트 적용)
      final themeData = pw.ThemeData.withFont(
        base: koreanFont,
        bold: koreanFont,
        italic: koreanFont,
        boldItalic: koreanFont,
      );
      
      // 라운드 테두리와 배경색 정의
      final contentDecoration = pw.BoxDecoration(
        color: PdfColors.grey200, // 살짝 회색 배경
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      );
      
      // PDF 페이지 추가
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          theme: themeData,
          margin: const pw.EdgeInsets.all(16),
          build: (pw.Context context) {
            return pw.Container(
              decoration: contentDecoration,
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Center(
                    child: pw.Text(
                      '전산자산 현품표',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // QR 코드 이미지 - 팝업과 동일한 비율
                      pw.Container(
                        width: 160,
                        height: 160,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          border: pw.Border.all(color: PdfColors.grey),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Center(
                          child: pw.Image(
                            pw.MemoryImage(qrImageBytes),
                            width: 150,
                            height: 150,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      
                      // 정보 테이블 - 비율 동일하게
                      pw.Expanded(
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Table(
                            border: pw.TableBorder.all(
                              color: PdfColors.grey,
                              width: 0.5,
                            ),
                            columnWidths: {
                              0: const pw.FixedColumnWidth(80), // 좁게 조정
                              1: const pw.FlexColumnWidth(3),
                            },
                            children: [
                              _buildPdfTableRow('자산코드', hardware.assetCode),
                              _buildPdfTableRow('자산분류', hardware.assetType ?? ''),
                              _buildPdfTableRow('자산명', hardware.assetName),
                              _buildPdfTableRow('규격', hardware.specification),
                              _buildPdfTableRow('구매일', hardware.purchaseDate != null 
                                ? dateFormat.format(hardware.purchaseDate!) 
                                : ''),
                              _buildPdfTableRow('시리얼넘버', hardware.serialNumber ?? ''),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
      
      // 바로 출력 대화상자 열기 (버튼 없음)
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          return pdf.save();
        },
      );
    } catch (e) {
      debugPrint('PDF 출력 오류: $e');
      // 오류 발생시 사용자에게 알림
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('출력 오류'),
            content: Text('현품표 출력 중 오류가 발생했습니다: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }
  
  // PDF용 테이블 행 생성
  pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          child: pw.Text(
            value,
            softWrap: true,
            style: pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

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
        elevation: 0,
        backgroundColor: const Color(0xFFF0F0F5),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildDataManagementTab(),
          HardwareDashboardPage(hardwareData: _hardwareData),
        ],
      ),
    );
  }

  Widget _buildDataManagementTab() {
    return Column(
      children: [
        // 1. 필터 영역
        _buildFilterBar(),
        
        // 2. 타이틀 및 버튼 영역
        _buildTitleAndActions(),
        
        // 3. 데이터 테이블 영역
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hardwareData.isEmpty
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
                      scrollbar: const PlutoGridScrollbarConfig(
                        isAlwaysShown: true,
                        scrollbarThickness: 8,
                        scrollbarRadius: Radius.circular(4),
                      ),
                      columnSize: const PlutoGridColumnSizeConfig(
                        autoSizeMode: PlutoAutoSizeMode.none,
                      ),
                    ),
                    mode: PlutoGridMode.normal,
                  ),
                ),
        ),
        
        // 4. 페이지네이션 영역
        if (_hardwareData.isNotEmpty) _buildPageNavigator(),
      ],
    );
  }

  // 데이터 관리 탭 뷰의 필터 위젯 - 필터만 포함하도록 수정
  Widget _buildFilters() {
    return _buildFilterBar();
  }
} 