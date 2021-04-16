import 'package:flutter/material.dart';

import 'ui/mobile_paged_listview.dart';
import 'ui/stateless_datatable.dart';

const _kTabletBreakpoint = Size(480, 480);

class NativeDataTable extends StatelessWidget {
  const NativeDataTable({
    required this.columns,
    required this.rows,
    this.rowsPerPage = PaginatedDataTable.defaultRowsPerPage,
    this.header,
    this.showSelect = true,
    this.showSort = true,
    this.onRowsPerPageChanged,
    this.totalItems,
    this.onSelectAll,
    this.sortAscending,
    this.sortColumnIndex,
    this.mobileItemBuilder,
    this.tabletBreakpoint = _kTabletBreakpoint,
    this.actions,
    this.firstRowIndex = 0,
    this.selectedActions,
    this.onRefresh,
    this.mobileFetchNextRows = 100,
    this.handlePrevious,
    this.handleNext,
    this.rowCountApproximate = false,
    this.noItems,
    this.mobileIsLoading,
    this.mobileSlivers,
    this.alwaysShowDataTable = false,
  });

  NativeDataTable.fromJson({
    required List<Map<String, dynamic>> items,
    List<String>? columnKeys,
    DataColumn Function(String key)? columnBuilder,
    DataRow Function(Map<String, dynamic> item)? rowBuilder,
    DataCell Function(String key, dynamic value)? cellBuilder,
    this.rowsPerPage = PaginatedDataTable.defaultRowsPerPage,
    this.header,
    this.showSelect = true,
    this.showSort = true,
    this.onRowsPerPageChanged,
    this.onSelectAll,
    this.sortAscending,
    this.sortColumnIndex,
    this.mobileItemBuilder,
    this.totalItems,
    this.tabletBreakpoint = _kTabletBreakpoint,
    this.actions,
    this.firstRowIndex = 0,
    this.selectedActions,
    this.onRefresh,
    this.mobileFetchNextRows = 100,
    this.handlePrevious,
    this.handleNext,
    this.rowCountApproximate = false,
    this.noItems,
    this.mobileIsLoading,
    this.mobileSlivers,
    this.alwaysShowDataTable = false,
  })  : assert(items.isNotEmpty || columnKeys != null),
        columns = (columnKeys ?? items[0].keys.toList()).map((e) {
          if (columnBuilder != null) return columnBuilder(e);
          return DataColumn(label: Text(e));
        }).toList(),
        rows = items.isEmpty
            ? []
            : items.map((e) {
                if (rowBuilder != null) return rowBuilder(e);
                return DataRow(
                    cells: e.entries.map((e) {
                  if (cellBuilder != null) return cellBuilder(e.key, e.value);
                  return DataCell(Text(e.value.toString()));
                }).toList());
              }).toList();

  NativeDataTable.builder({
    required this.columns,
    this.rowsPerPage = PaginatedDataTable.defaultRowsPerPage,
    required int itemCount,
    required DataRowBuilder itemBuilder,
    this.totalItems,
    this.header,
    this.onRowsPerPageChanged,
    this.onSelectAll,
    this.sortAscending,
    this.showSelect = true,
    this.showSort = true,
    this.sortColumnIndex,
    this.mobileItemBuilder,
    this.tabletBreakpoint = _kTabletBreakpoint,
    this.actions,
    this.selectedActions,
    this.firstRowIndex = 0,
    this.onRefresh,
    this.mobileFetchNextRows = 100,
    this.handlePrevious,
    this.handleNext,
    this.rowCountApproximate = false,
    this.noItems,
    this.mobileIsLoading,
    this.mobileSlivers,
    this.alwaysShowDataTable = false,
  }) : rows = _buildRows(itemCount, itemBuilder);

  final int? sortColumnIndex;
  final bool? sortAscending;
  final ValueChanged<bool?>? onSelectAll;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final int? totalItems;
  final int rowsPerPage;
  final int firstRowIndex;

  /// Visible on Tablet/Desktop
  final Widget? header;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final IndexedWidgetBuilder? mobileItemBuilder;
  final Size tabletBreakpoint;
  final List<Widget>? actions, selectedActions;
  final int mobileFetchNextRows;
  final RefreshCallback? onRefresh;
  final VoidCallback? handlePrevious, handleNext;

  /// Set this to [true] for using this with a api
  final bool rowCountApproximate;
  final bool showSelect, showSort;
  final Widget? noItems;
  final Widget? mobileIsLoading;
  final List<Widget>? mobileSlivers;
  final bool alwaysShowDataTable;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= tabletBreakpoint.width &&
        size.height >= tabletBreakpoint.height;
    if (alwaysShowDataTable || isTablet) {
      return StatelessDataTable(
        rows: rows,
        firstRowIndex: firstRowIndex,
        totalItems: totalItems,
        header: header,
        showCheckboxColumn: showSelect,
        handleNext: handleNext,
        handlePrevious: handlePrevious,
        rowsPerPage: rowsPerPage,
        onRowsPerPageChanged: onRowsPerPageChanged,
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending ?? false,
        onSelectAll: showSelect ? onSelectAll : null,
        columns: columns,
        // ignore: avoid_redundant_argument_values
        shrinkWrap: false,
        rowCountApproximate: rowCountApproximate,
        actions: [
          ...actions ?? [],
          Container(
            child: onRefresh == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                  ),
          ),
        ],
        selectedActions: selectedActions,
      );
    }

    return PagedListView(
      rows: rows,
      slivers: mobileSlivers,
      columns: columns,
      showSelect: showSelect,
      showSort: showSort,
      loadNext: handleNext,
      mobileItemBuilder: mobileItemBuilder,
      actions: actions,
      selectedActions: selectedActions,
      onSelectAll: onSelectAll,
      rowsPerPage: rowsPerPage,
      sortAscending: sortAscending,
      sortColumnIndex: sortColumnIndex,
      onRefresh: onRefresh,
      isRowCountApproximate: rowCountApproximate,
      isLoading: mobileIsLoading,
      noItems: noItems,
    );
  }

  static List<DataRow> _buildRows(int count, DataRowBuilder builder) {
    List<DataRow> _rows = [];

    for (int i = 0; i < count; i++) {
      _rows.add(builder(i));
    }

    return _rows;
  }
}

typedef DataRowBuilder = DataRow Function(int index);
