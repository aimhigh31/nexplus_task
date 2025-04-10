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

  final List<String> _softwareTabs = ['데이터관리', '종합현황'];

  // 페이지네이션
  int _currentPage = 0;
  final int _rowsPerPage = 11;
  int _totalPages = 0;

  // 검색 및 필터
  final TextEditingController _searchController = TextEditingController();
  
  // 자산분류 목록
  final List<String> _assetTypes = [
    'AutoCAD', 'ZWCAD', 'NX-UZ', 'CATIA', '금형박사', '망고보드', 
    '캡컷', 'NX', '팀뷰어', 'HADA', 'MS-OFFICE', 'WINDOWS', 
    '아래아한글', 'VMware'
  ];
  
  // 자산명 목록
  final List<String> _assetNames = [
    'Standard', 'Professional', 'Enterprise', 'Ultimate', 
    'Developer', 'Basic', 'Premium'
  ];
  
  // 비용형태 목록
  final List<String> _costTypes = ['연구독', '월구독', '영구'];
  
  // 거래업체 목록
  final List<String> _vendors = [
    '오토데스크', '한컴', '마이크로소프트', '어도비', '지멘스', 
    'PTC', '대성소프트웨어', 'ANSYS', 'DASSAULT', 'IBM', '한국NX'
  ];
  
  // 필터 선택 상태
  String? _selectedAssetType;
  String? _selectedCostType;

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
        assetType: _selectedAssetType,
        costType: _selectedCostType,
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
    final changedRow = event.row;
    final int rowIdx = _gridStateManager!.rows.indexOf(changedRow);
    
    if (rowIdx >= 0 && rowIdx < _softwareData.length) {
      final software = _softwareData[rowIdx];
      SoftwareModel updatedSoftware;
      
      switch (event.column.field) {
        case 'regDate':
          updatedSoftware = software.copyWith(regDate: event.value ?? DateTime.now());
          break;
        case 'assetType':
          updatedSoftware = software.copyWith(assetType: event.value ?? '');
          break;
        case 'assetName':
          updatedSoftware = software.copyWith(assetName: event.value ?? '');
          break;
        case 'specification':
          updatedSoftware = software.copyWith(specification: event.value ?? '');
          break;
        case 'setupPrice':
          updatedSoftware = software.copyWith(setupPrice: event.value ?? 0);
          break;
        case 'annualMaintenancePrice':
          updatedSoftware = software.copyWith(annualMaintenancePrice: event.value ?? 0);
          break;
        case 'costType':
          updatedSoftware = software.copyWith(costType: event.value ?? '');
          break;
        case 'vendor':
          updatedSoftware = software.copyWith(vendor: event.value ?? '');
          break;
        case 'licenseKey':
          updatedSoftware = software.copyWith(licenseKey: event.value ?? '');
          break;
        case 'user':
          updatedSoftware = software.copyWith(user: event.value ?? '');
          break;
        case 'startDate':
          updatedSoftware = software.copyWith(startDate: event.value);
          break;
        case 'endDate':
          updatedSoftware = software.copyWith(endDate: event.value);
          break;
        case 'remarks':
          updatedSoftware = software.copyWith(remarks: event.value ?? '');
          break;
        default:
          return; // 알 수 없는 필드는 처리하지 않음
      }
      
      // isModified 플래그를 설정하여 변경 사항 있음을 표시
      updatedSoftware = updatedSoftware.copyWith(isModified: true);
      
      _softwareData[rowIdx] = updatedSoftware;
      _unsavedChanges = true;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 10), () { 
        if (mounted) setState(() {}); 
      });
    }
  }

  List<PlutoRow> _getPlutoRows() {
    List<PlutoRow> rows = [];
    
    for (var item in _paginatedData()) {
      rows.add(PlutoRow(cells: {
        'checkbox': PlutoCell(value: _selectedSoftwareCodes.contains(item.code)),
        'regDate': PlutoCell(value: item.regDate),
        'code': PlutoCell(value: item.code),
        'assetType': PlutoCell(value: item.assetType),
        'assetName': PlutoCell(value: item.assetName),
        'specification': PlutoCell(value: item.specification),
        'setupPrice': PlutoCell(value: item.setupPrice),
        'annualMaintenancePrice': PlutoCell(value: item.annualMaintenancePrice),
        'costType': PlutoCell(value: item.costType),
        'vendor': PlutoCell(value: item.vendor),
        'licenseKey': PlutoCell(value: item.licenseKey),
        'user': PlutoCell(value: item.user),
        'startDate': PlutoCell(value: item.startDate),
        'endDate': PlutoCell(value: item.endDate),
        'remarks': PlutoCell(value: item.remarks),
      }));
    }
    
    return rows;
  }

  List<PlutoColumn> get _columns {
    return [
      PlutoColumn(
        title: '',
        field: 'checkbox',
        type: PlutoColumnType.text(),
        width: 60,
        enableSorting: false,
        enableFilterMenuItem: false,
        enableEditingMode: false,
        renderer: (rendererContext) {
          return Checkbox(
            value: rendererContext.cell.value ?? false,
            onChanged: (bool? value) {
              _gridStateManager?.changeCellValue(
                rendererContext.cell,
                value,
              );
              _toggleRowSelection(_gridStateManager!.rows.indexOf(rendererContext.row));
            },
          );
        },
      ),
      PlutoColumn(
        title: '등록일',
        field: 'regDate',
        type: PlutoColumnType.date(),
        width: 110,
        enableEditingMode: true,
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: '코드',
        field: 'code',
        type: PlutoColumnType.text(),
        width: 130,
        enableEditingMode: false,
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: '자산분류',
        field: 'assetType',
        type: PlutoColumnType.select(_assetTypes),
        width: 120,
        enableEditingMode: true,
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: '자산명',
        field: 'assetName',
        type: PlutoColumnType.text(),
        width: 150,
        enableEditingMode: true,
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.left,
      ),
      PlutoColumn(
        title: '규격',
        field: 'specification',
        type: PlutoColumnType.text(),
        width: 150,
      ),
      PlutoColumn(
        title: '구축금액',
        field: 'setupPrice',
        type: PlutoColumnType.number(format: '#,###'),
        width: 120,
      ),
      PlutoColumn(
        title: '연유지비',
        field: 'annualMaintenancePrice',
        type: PlutoColumnType.number(format: '#,###'),
        width: 120,
      ),
      PlutoColumn(
        title: '비용형태',
        field: 'costType',
        type: PlutoColumnType.select(_costTypes),
        width: 90,
      ),
      PlutoColumn(
        title: '거래업체',
        field: 'vendor',
        type: PlutoColumnType.text(),
        width: 120,
      ),
      PlutoColumn(
        title: '라이센스키',
        field: 'licenseKey',
        type: PlutoColumnType.text(),
        width: 150,
      ),
      PlutoColumn(
        title: '사용자',
        field: 'user',
        type: PlutoColumnType.text(),
        width: 100,
      ),
      PlutoColumn(
        title: '시작일',
        field: 'startDate',
        type: PlutoColumnType.date(format: 'yyyy-MM-dd'),
        width: 120,
        renderer: (rendererContext) {
          dynamic cellValue = rendererContext.cell.value;
          DateTime? date;
          
          // String이나 다른 타입을 DateTime으로 변환 처리
          if (cellValue is DateTime) {
            date = cellValue;
          } else if (cellValue is String && cellValue.isNotEmpty) {
            try {
              date = DateTime.parse(cellValue);
            } catch (e) {
              // 파싱 실패 시 null로 처리
              date = null;
            }
          }
          
          return Text(
            date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          );
        },
      ),
      PlutoColumn(
        title: '종료일',
        field: 'endDate',
        type: PlutoColumnType.date(format: 'yyyy-MM-dd'),
        width: 120,
        renderer: (rendererContext) {
          dynamic cellValue = rendererContext.cell.value;
          DateTime? date;
          
          // String이나 다른 타입을 DateTime으로 변환 처리
          if (cellValue is DateTime) {
            date = cellValue;
          } else if (cellValue is String && cellValue.isNotEmpty) {
            try {
              date = DateTime.parse(cellValue);
            } catch (e) {
              // 파싱 실패 시 null로 처리
              date = null;
            }
          }
          
          return Text(
            date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          );
        },
      ),
      PlutoColumn(
        title: '비고',
        field: 'remarks',
        type: PlutoColumnType.text(),
        width: 150,
      ),
    ];
  }

  void _addEmptyRow() {
    int newNo = _softwareData.isEmpty ? 1 : _softwareData.map((v) => v.no).fold(0, (max, current) => current > max ? current : max) + 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final newCode = SoftwareModel.generateSoftwareCode(today, newNo);

    final newSoftware = SoftwareModel(
      no: newNo,
      regDate: today,
      code: newCode,
      assetCode: '',
      assetType: _assetTypes.first,
      assetName: '',
      specification: '',
      setupPrice: 0,
      annualMaintenancePrice: 0,
      costType: _costTypes.first,
      vendor: '',
      licenseKey: '',
      user: '',
      quantity: 1,
      unitPrice: 0,
      totalPrice: 0,
      lotCode: '',
      detail: '',
      startDate: today,
      endDate: today.add(const Duration(days: 365)),
      remarks: '',
      isSaved: false,
      isModified: true,
    );

    setState(() {
      _softwareData.insert(0, newSoftware);
      _currentPage = 0;
      _totalPages = (_softwareData.length / _rowsPerPage).ceil();
      _unsavedChanges = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPlutoGrid();
    });
  }

  Future<void> _saveAllData() async {
    final unsavedItems = _softwareData.where((v) => !v.isSaved || v.isModified).toList();
    if (unsavedItems.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    int successCount = 0;
    int failCount = 0;

    // API 요청 호출
    for (final item in unsavedItems) {
      try {
        SoftwareModel? result;
        if (item.isSaved) {
          // 기존 데이터 업데이트
          result = await _apiService.updateSoftware(item);
        } else {
          // 새 데이터 추가
          result = await _apiService.addSoftware(item);
        }

        if (result != null) {
          successCount++;
          // 저장된 데이터로 업데이트
          final index = _softwareData.indexWhere((v) => v.no == item.no);
          if (index != -1) {
            _softwareData[index] = result.copyWith(isSaved: true, isModified: false);
          }
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
        debugPrint('소프트웨어 데이터 저장 중 오류: $e');
      }
    }

    // UI 업데이트
    if (mounted) {
      setState(() {
        _isLoading = false;
        _unsavedChanges = false;
        _totalPages = (_softwareData.length / _rowsPerPage).ceil();
        if (_currentPage >= _totalPages && _totalPages > 0) {
          _currentPage = _totalPages - 1;
        }
      });
      _refreshPlutoGrid();
    }
  }

  void _deleteSelectedRows() {
    if (_selectedSoftwareCodes.isEmpty) return;
    final codesToDelete = List<String>.from(_selectedSoftwareCodes);

    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('행 삭제'),
        content: Text('선택한 ${codesToDelete.length}개 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소')
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제')
          ),
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

    // API 호출
    for (final code in codes) {
      try {
        bool success = await _apiService.deleteSoftwareByCode(code);
        if (success) {
          successCount++;
          _softwareData.removeWhere((d) => d.code == code);
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
        debugPrint('소프트웨어 삭제 중 오류: $e');
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
      if (rows.isNotEmpty) { 
        _gridStateManager!.setCurrentCell(rows.first.cells.values.first, 0); 
      }
    }
  }

  void _updateSelectedState() { 
    setState(() { _hasSelectedItems = _selectedSoftwareCodes.isNotEmpty; }); 
  }

  void _toggleRowSelection(int rowIdx) {
    if (rowIdx < 0 || rowIdx >= _paginatedData().length) return;
    final data = _paginatedData()[rowIdx];
    final code = data.code;
    if (code == null) return;
    
    setState(() {
      if (_selectedSoftwareCodes.contains(code)) {
        _selectedSoftwareCodes.remove(code);
      } else {
        _selectedSoftwareCodes.add(code);
      }
      _hasSelectedItems = _selectedSoftwareCodes.isNotEmpty;
    });
    
    if (_gridStateManager != null) {
      _gridStateManager!.changeCellValue(
        _gridStateManager!.rows[rowIdx].cells['checkbox']!,
        _selectedSoftwareCodes.contains(code),
        force: true
      );
    }
  }

  // 엑셀 내보내기
  Future<void> _exportToExcel() async {
    try {
      setState(() => _isLoading = true);
      
      // Excel 생성
      final excel = Excel.createExcel();
      final sheet = excel['소프트웨어 자산'];
      
      // 헤더 생성
      List<String> headers = [
        'No', '등록일', '코드', '자산분류', '자산코드', '자산명', '규격', 
        '구축금액', '연유지비', '비용형태', '거래업체', '라이센스키', 
        '사용자', '시작일', '종료일', '비고'
      ];
      
      // 헤더 스타일 설정
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
      
      // 데이터 추가
      for (var i = 0; i < _softwareData.length; i++) {
        final data = _softwareData[i];
        List<dynamic> rowData = [
          data.no,
          DateFormat('yyyy-MM-dd').format(data.regDate),
          data.code,
          data.assetType,
          data.assetCode,
          data.assetName,
          data.specification,
          data.setupPrice,
          data.annualMaintenancePrice,
          data.costType,
          data.vendor,
          data.licenseKey,
          data.user,
          data.startDate != null ? DateFormat('yyyy-MM-dd').format(data.startDate!) : '',
          data.endDate != null ? DateFormat('yyyy-MM-dd').format(data.endDate!) : '',
          data.remarks,
        ];
        
        for (var j = 0; j < rowData.length; j++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: j,
            rowIndex: i + 1,
          ));
          
          if (rowData[j] is num) {
            cell.value = IntCellValue(rowData[j] is int ? rowData[j] : rowData[j].toInt());
          } else {
            cell.value = TextCellValue(rowData[j].toString());
          }
        }
      }

      // 자동 열 너비
      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15.0);
      }
      
      // 엑셀 파일 생성 및 다운로드
      final bytes = excel.encode();
      if (bytes != null) {
        final now = DateTime.now();
        final fileName = '소프트웨어_자산_${DateFormat('yyyyMMdd_HHmmss').format(now)}.xlsx';
        
        if (kIsWeb) {
          await FileSaver.instance.saveFile(
            name: fileName,
            bytes: Uint8List.fromList(bytes),
            ext: 'xlsx',
            mimeType: MimeType.microsoftExcel,
          );
        } else {
          String? result = await FilePicker.platform.saveFile(
            dialogTitle: '엑셀 파일 저장',
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: ['xlsx'],
          );
          
          if (result != null) {
            File(result)
              ..createSync(recursive: true)
              ..writeAsBytesSync(bytes);
          }
        }
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('엑셀 내보내기 중 오류: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 엑셀 가져오기
  Future<void> _importFromExcel() async {
    try {
      setState(() => _isLoading = true);
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      
      if (result != null) {
        Uint8List bytes;
        
        if (kIsWeb) {
          bytes = result.files.single.bytes!;
        } else {
          File file = File(result.files.single.path!);
          bytes = file.readAsBytesSync();
        }
        
        // 엑셀 디코딩
        final excel = Excel.decodeBytes(bytes);
        if (excel.tables.isNotEmpty) {
          final sheet = excel.tables.keys.first;
          
          // 헤더 확인
          final headers = <String>[];
          for (var cell in excel.tables[sheet]!.rows[0]) {
            headers.add(cell?.value.toString() ?? '');
          }
          
          // 필수 필드 확인
          final requiredHeaders = ['자산분류', '자산코드', '자산명'];
          bool hasRequired = requiredHeaders.every((h) => headers.contains(h));
          
          if (!hasRequired) {
            // 필수 필드 없음 - 처리 중단
            if (mounted) {
              setState(() => _isLoading = false);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('필수 필드 누락'),
                  content: const Text('엑셀 파일에 필수 필드(자산분류, 자산코드, 자산명)가 포함되어 있지 않습니다.'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            }
            return;
          }
          
          // 데이터 파싱
          List<SoftwareModel> importedData = [];
          int startNo = _softwareData.isEmpty ? 1 : _softwareData.map((v) => v.no).fold(0, (max, current) => current > max ? current : max) + 1;
          
          for (var i = 1; i < excel.tables[sheet]!.rows.length; i++) {
            final row = excel.tables[sheet]!.rows[i];
            
            // 기본값 설정
            int no = startNo + i - 1;
            DateTime regDate = DateTime.now();
            String assetType = '';
            String assetCode = '';
            String assetName = '';
            String specification = '';
            double setupPrice = 0;
            double annualMaintenancePrice = 0;
            String costType = _costTypes.first;
            String vendor = '';
            String licenseKey = '';
            String user = '';
            DateTime? startDate;
            DateTime? endDate;
            String remarks = '';
            
            // 데이터 매핑
            for (var j = 0; j < headers.length && j < row.length; j++) {
              if (row[j] == null || row[j]?.value == null) continue;
              
              final header = headers[j];
              dynamic rawValue = row[j]!.value;
              final value = rawValue.toString();
              
              switch (header) {
                case '등록일':
                  try {
                    if (rawValue is DateTime) {
                      regDate = rawValue;
                    } else {
                      regDate = DateFormat('yyyy-MM-dd').parse(value);
                    }
                  } catch (e) {
                    debugPrint('등록일 파싱 오류: $e');
                  }
                  break;
                case '자산분류':
                  assetType = value;
                  break;
                case '자산코드':
                  assetCode = value;
                  break;
                case '자산명':
                  assetName = value;
                  break;
                case '규격':
                  specification = value;
                  break;
                case '구축금액':
                  try {
                    setupPrice = double.parse(value.replaceAll(',', ''));
                  } catch (e) {
                    debugPrint('구축금액 파싱 오류: $e');
                  }
                  break;
                case '연유지비':
                  try {
                    annualMaintenancePrice = double.parse(value.replaceAll(',', ''));
                  } catch (e) {
                    debugPrint('연유지비 파싱 오류: $e');
                  }
                  break;
                case '비용형태':
                  costType = value;
                  break;
                case '거래업체':
                  vendor = value;
                  break;
                case '라이센스키':
                  licenseKey = value;
                  break;
                case '사용자':
                  user = value;
                  break;
                case '시작일':
                  try {
                    if (rawValue is DateTime) {
                      startDate = rawValue;
                    } else if (value.isNotEmpty) {
                      startDate = DateFormat('yyyy-MM-dd').parse(value);
                    }
                  } catch (e) {
                    debugPrint('시작일 파싱 오류: $e');
                  }
                  break;
                case '종료일':
                  try {
                    if (rawValue is DateTime) {
                      endDate = rawValue;
                    } else if (value.isNotEmpty) {
                      endDate = DateFormat('yyyy-MM-dd').parse(value);
                    }
                  } catch (e) {
                    debugPrint('종료일 파싱 오류: $e');
                  }
                  break;
                case '비고':
                  remarks = value;
                  break;
              }
            }
            
            // 필수 필드 확인
            if (assetType.isNotEmpty && assetCode.isNotEmpty && assetName.isNotEmpty) {
              // 코드 생성 (자동)
              final code = SoftwareModel.generateSoftwareCode(regDate, no);
              
              importedData.add(SoftwareModel(
                no: no,
                code: code,
                regDate: regDate,
                assetCode: assetCode,
                assetType: assetType,
                assetName: assetName,
                specification: specification,
                setupPrice: setupPrice,
                annualMaintenancePrice: annualMaintenancePrice,
                costType: costType,
                vendor: vendor,
                licenseKey: licenseKey,
                user: user,
                quantity: 1,
                unitPrice: 0,
                totalPrice: 0,
                lotCode: '',
                detail: '',
                startDate: startDate,
                endDate: endDate,
                remarks: remarks,
                isSaved: false,
                isModified: true,
              ));
            }
          }
          
          // 데이터 저장
          if (importedData.isNotEmpty) {
            setState(() {
              _softwareData.insertAll(0, importedData);
              _currentPage = 0;
              _totalPages = (_softwareData.length / _rowsPerPage).ceil();
              _unsavedChanges = true;
            });
            _refreshPlutoGrid();
            
            // 다이얼로그 표시
            if (mounted) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('엑셀 가져오기 완료'),
                  content: Text('${importedData.length}개 항목이 가져와졌습니다.\n변경 사항을 저장하려면 "데이터 저장" 버튼을 클릭하세요.'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _saveAllData();
                      },
                      child: const Text('저장하기'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('닫기'),
                    ),
                  ],
                ),
              );
            }
          } else {
            // 유효한 데이터 없음
            if (mounted) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('가져오기 실패'),
                  content: const Text('유효한 데이터가 없습니다. 파일 형식을 확인하세요.'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            }
          }
        }
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('엑셀 가져오기 중 오류: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 필터 디자인을 솔루션 개발 페이지와 완전히 동일하게 수정
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
                _loadSoftwareData();
              },
            ),
          ),
          const SizedBox(width: 12),

          // 비용형태 필터
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
              value: _selectedCostType,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('전체'),
                ),
                ..._costTypes.map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCostType = value;
                  _currentPage = 0;
                });
                _loadSoftwareData();
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
                  _loadSoftwareData();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // 데이터가 없을 때 표시할 뷰
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

  // 타이틀과 버튼 등 행동 UI 빌드
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
                '소프트웨어 자산',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '전체 ${_softwareData.length}개 항목, ${_currentPage + 1}/${_totalPages} 페이지',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          // 실행 버튼들 그룹
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
                label: Text('행 삭제${_hasSelectedItems ? ' (${_selectedSoftwareCodes.length})' : ''}'),
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

  // 범례 추가 (솔루션 개발 페이지와 동일한 스타일)
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

  // 데이터 탭 UI 빌드
  Widget _buildDataTab() {
    return Column(
      children: [
        // 1. 필터 (맨 위에 배치)
        _buildFilterBar(),
        
        // 2. 타이틀과 실행 버튼 (한 줄에 표시)
        _buildTitleAndActions(),
        
        // 3. 범례 (데이터 테이블 바로 위에 배치)
        if (_softwareData.isNotEmpty) _buildLegend(),
        
        // 4. 데이터 테이블 (Expanded로 남은 공간 채움)
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _softwareData.isEmpty
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
                      // 좌우 스크롤 활성화
                      scrollbar: const PlutoGridScrollbarConfig(
                        isAlwaysShown: true,
                        scrollbarThickness: 8,
                        scrollbarRadius: Radius.circular(4),
                      ),
                      columnSize: const PlutoGridColumnSizeConfig(
                        autoSizeMode: PlutoAutoSizeMode.none, // 좌우 스크롤 가능하도록 설정
                      ),
                    ),
                    mode: PlutoGridMode.normal,
                  ),
                ),
        ),
        
        // 5. 페이지 네비게이션 (맨 아래에 배치)
        if (_softwareData.isNotEmpty) _buildPageNavigator(),
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
        elevation: 0,
        backgroundColor: const Color(0xFFF0F0F5),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // 데이터 관리 탭
          _buildDataTab(),
          // 종합 현황 탭 (소프트웨어 대시보드와 연결)
          SoftwareDashboardPage(softwareData: _softwareData),
        ],
      ),
    );
  }

  // 데이터 저장 함수
  Future<void> _saveData() async {
    try {
      setState(() => _isLoading = true);
      
      final List<SoftwareModel> modifiedItems = _softwareData.where((item) => item.isModified).toList();
      
      if (modifiedItems.isEmpty) {
        debugPrint('변경된 항목이 없음');
        setState(() => _isLoading = false);
        return;
      }
      
      int successCount = 0;
      List<String> failedCodes = [];
      
      // 각 항목 저장
      for (final item in modifiedItems) {
        try {
          if (item.code == null || item.code!.isEmpty) {
            // 새 항목 추가
            final result = await _apiService.addSoftware(item);
            if (result != null) {
              successCount++;
              
              // 목록에서 해당 항목 업데이트
              final index = _softwareData.indexWhere((i) => i == item);
              if (index >= 0) {
                _softwareData[index] = result;
              }
            } else {
              failedCodes.add('신규 항목');
            }
          } else {
            // 기존 항목 수정
            final result = await _apiService.updateSoftware(item);
            if (result != null) {
              successCount++;
              
              // 목록에서 해당 항목 업데이트
              final index = _softwareData.indexWhere((i) => i.code == item.code);
              if (index >= 0) {
                _softwareData[index] = result;
              }
            } else {
              failedCodes.add(item.code!);
            }
          }
        } catch (e) {
          debugPrint('항목 저장 실패 ${item.code}: $e');
          failedCodes.add(item.code ?? '신규 항목');
        }
      }
      
      // 결과 표시
      setState(() {
        _isLoading = false;
        _unsavedChanges = failedCodes.isNotEmpty;
      });
      
      // 변경 상태 메시지
      if (successCount > 0) {
        debugPrint('$successCount개 항목 저장 성공');
      }
      
      if (failedCodes.isNotEmpty) {
        debugPrint('${failedCodes.length}개 항목 저장 실패: ${failedCodes.join(', ')}');
      }
      
      // 그리드 새로고침
      _refreshPlutoGrid();
      
    } catch (e) {
      debugPrint('데이터 저장 중 오류: $e');
      setState(() => _isLoading = false);
    }
  }
}

// --- 컴포넌트 위젯 정의 ---

// 소프트웨어 필터 위젯
class SoftwareFilterWidget extends StatefulWidget {
  final TextEditingController searchController;
  final String? selectedAssetType;
  final String? selectedCostType;
  final List<String> assetTypes;
  final List<String> costTypes;
  final ValueChanged<String?> onAssetTypeChanged;
  final ValueChanged<String?> onCostTypeChanged;
  final VoidCallback onSearchChanged;

  const SoftwareFilterWidget({
    super.key,
    required this.searchController,
    required this.selectedAssetType,
    required this.selectedCostType,
    required this.assetTypes,
    required this.costTypes,
    required this.onAssetTypeChanged,
    required this.onCostTypeChanged,
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
              value: widget.selectedAssetType,
              isExpanded: true,
              onChanged: widget.onAssetTypeChanged,
              items: [null, ...widget.assetTypes].map((s) => DropdownMenuItem<String>(
                value: s,
                child: Text(s ?? '전체 자산')
              )).toList()
            )
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              hint: const Text('전체 실행유형'),
              value: widget.selectedCostType,
              isExpanded: true,
              onChanged: widget.onCostTypeChanged,
              items: [null, ...widget.costTypes].map((t) => DropdownMenuItem<String>(
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

// 페이지 네비게이션 위젯
Widget _buildPagination() {
  return DataTableWidget(
    columns: [
      PlutoColumn(
        title: '페이지',
        field: 'page',
        type: PlutoColumnType.text(),
        width: 100,
      ),
    ],
    rows: [
      PlutoRow(cells: {
        'page': PlutoCell(value: '1'),
      }),
      PlutoRow(cells: {
        'page': PlutoCell(value: '2'),
      }),
      PlutoRow(cells: {
        'page': PlutoCell(value: '3'),
      }),
    ],
    unsavedChanges: false,
    onCellChanged: (event) {},
    onLoaded: (event) {},
    currentPage: 0,
    totalPages: 3,
    onPageChanged: (page) {},
  );
} 