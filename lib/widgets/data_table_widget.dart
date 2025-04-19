import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart' hide Border;

/// 공통으로 사용할 데이터 테이블 위젯
/// 모든 페이지에서 일관된 스타일과 기능을 제공합니다.
class CommonDataTableWidget extends StatelessWidget {
  /// 테이블 컬럼 정의
  final List<PlutoColumn> columns;
  
  /// 테이블 행 데이터
  final List<PlutoRow> rows;
  
  /// 데이터가 비어있을 때 표시할 메시지
  final String emptyMessage;
  
  /// 셀 변경 이벤트 핸들러
  final Function(PlutoGridOnChangedEvent)? onChanged;
  
  /// 그리드 로드 완료 이벤트 핸들러
  final Function(PlutoGridOnLoadedEvent)? onLoaded;
  
  /// 행 선택 이벤트 핸들러
  final Function(PlutoGridOnRowCheckedEvent)? onRowChecked;
  
  /// 변경되지 않은 데이터가 있는지 여부
  final bool hasUnsavedChanges;
  
  /// 범례 아이템 정의
  final List<LegendItem> legendItems;
  
  /// 현재 페이지 번호 (0부터 시작)
  final int currentPage;
  
  /// 총 페이지 수
  final int totalPages;
  
  /// 페이지 변경 이벤트 핸들러
  final Function(int) onPageChanged;
  
  const CommonDataTableWidget({
    Key? key,
    required this.columns,
    required this.rows,
    this.emptyMessage = '표시할 데이터가 없습니다.',
    this.onChanged,
    this.onLoaded,
    this.onRowChecked,
    this.hasUnsavedChanges = false,
    this.legendItems = const [],
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 범례
        if (legendItems.isNotEmpty || hasUnsavedChanges)
          _buildLegend(context),
          
        // 데이터 테이블
        Expanded(
          child: rows.isEmpty 
            ? _buildEmptyState() 
            : _buildDataTable(),
        ),
        
        // 페이지네이션
        if (rows.isNotEmpty && totalPages > 0)
          _buildPagination(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
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
          const Text('범례:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...legendItems.map((item) => _buildLegendItem(item.label, item.color)),
          if (hasUnsavedChanges)
            const Text(
              '* 저장되지 않은 변경사항',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            emptyMessage,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    debugPrint('데이터 테이블 빌드: ${rows.length}행, onChanged ${onChanged != null ? '등록됨' : '미등록'}');
    return PlutoGrid(
      columns: columns,
      rows: rows,
      onLoaded: onLoaded,
      onChanged: (PlutoGridOnChangedEvent event) {
        debugPrint('PlutoGrid 셀 변경 이벤트: ${event.column.field} = ${event.value}');
        if (onChanged != null) {
          onChanged!(event);
        }
      },
      onRowChecked: onRowChecked,
      configuration: PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          cellTextStyle: const TextStyle(fontSize: 12),
          columnTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          rowHeight: 45,
          columnHeight: 45,
          rowColor: Colors.white,
          oddRowColor: Colors.grey.shade50,
          gridBorderColor: Colors.grey.shade300,
          gridBackgroundColor: Colors.transparent,
          borderColor: Colors.grey.shade300,
          activatedColor: Colors.blue.shade100,
          activatedBorderColor: Colors.blue.shade300,
          inactivatedBorderColor: Colors.grey.shade300,
        ),
        scrollbar: const PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.none,
        ),
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveDown,
        columnFilter: PlutoGridColumnFilterConfig(
          filters: const [
            ...FilterHelper.defaultFilters,
          ],
          debounceMilliseconds: 300,
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
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
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${currentPage + 1} / $totalPages',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null,
            color: Colors.blue,
            disabledColor: Colors.grey.shade400,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
          ),
        ],
      ),
    );
  }
}

/// 범례 아이템 정의를 위한 클래스
class LegendItem {
  final String label;
  final Color color;
  
  const LegendItem({
    required this.label,
    required this.color,
  });
} 