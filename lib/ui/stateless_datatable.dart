import 'dart:ui';

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class StatelessDataTable extends StatelessWidget {
  StatelessDataTable({
    Key? key,
    this.header,
    this.actions,
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.showCheckboxColumn = true,
    this.sortAscending = true,
    this.totalItems,
    this.onSelectAll,
    this.firstRowIndex = 0,
    this.onPageChanged,
    this.shrinkWrap = false,
    this.selectedActions,
    this.rowCountApproximate = false,
    this.rowsPerPage = defaultRowsPerPage,
    this.handlePrevious,
    this.handleNext,
    this.availableRowsPerPage = const <int>[defaultRowsPerPage, defaultRowsPerPage * 2, defaultRowsPerPage * 5, defaultRowsPerPage * 10],
    this.onRowsPerPageChanged,
    this.dragStartBehavior = DragStartBehavior.down,
  })  : assert(columns.isNotEmpty),
        assert(sortColumnIndex == null || (sortColumnIndex >= 0 && sortColumnIndex < columns.length)),
        assert(rowsPerPage > 0),
        assert(() {
          if (onRowsPerPageChanged != null) {
            assert(availableRowsPerPage.contains(rowsPerPage));
          }
          return true;
        }()),
        super(key: key);

  final VoidCallback? handleNext, handlePrevious;
  final Widget? header;
  final bool showCheckboxColumn;
  final List<Widget>? actions, selectedActions;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool shrinkWrap;
  final int? sortColumnIndex;
  final int? totalItems;
  final bool sortAscending;
  final ValueSetter<bool?>? onSelectAll;
  final ValueChanged<int?>? onPageChanged;
  final int rowsPerPage;
  static const int defaultRowsPerPage = 10;
  final List<int> availableRowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final DragStartBehavior dragStartBehavior;
  final int firstRowIndex;
  final bool rowCountApproximate;
  final Map<int, DataRow> _rows = <int, DataRow>{};

  DataRow _getBlankRowFor(int index) => DataRow.byIndex(index: index, cells: columns.map<DataCell>((DataColumn column) => DataCell.empty).toList());

  DataRow _getProgressIndicatorRowFor(int index) {
    bool haveProgressIndicator = false;
    final List<DataCell> cells = columns.map<DataCell>((DataColumn column) {
      if (!column.numeric) {
        haveProgressIndicator = true;
        return const DataCell(CircularProgressIndicator());
      }
      return DataCell.empty;
    }).toList();
    if (!haveProgressIndicator) {
      haveProgressIndicator = true;
      cells[0] = const DataCell(CircularProgressIndicator());
    }
    return DataRow.byIndex(index: index, cells: cells);
  }

  List<DataRow> _getRows(int firstRowIndex, int rowsPerPage) {
    final List<DataRow> result = <DataRow>[];
    final int nextPageFirstRowIndex = firstRowIndex + rowsPerPage;
    bool haveProgressIndicator = false;
    for (int index = firstRowIndex; index < nextPageFirstRowIndex; index += 1) {
      DataRow? row;
      if (index < rows.length || rowCountApproximate) {
        try {
          row = _rows.putIfAbsent(index, () => rows[index]);
        } catch (e) {
          print("Row not found => $e");
        }
        if (row == null && !haveProgressIndicator) {
          row ??= _getProgressIndicatorRowFor(index);
          haveProgressIndicator = true;
        }
        row ??= _getBlankRowFor(index);
        result.add(row);
      }
    }
    //show no data
    if (result.isEmpty) {
      var cells = columns.map<DataCell>((DataColumn column) => DataCell.empty).toList();
      cells[cells.length ~/ 2] = const DataCell(Text('no data'));
      result.add(DataRow.byIndex(index: 0, cells: cells));
    }

    return result;
  }

  final GlobalKey _tableKey = GlobalKey();

  int get _selectedRowCount => rows.where((d) => d.selected).toSet().toList().length;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    final List<Widget> headerWidgets = <Widget>[];
    double startPadding = 24;

    if (_selectedRowCount == 0) {
      if (header != null) {
        headerWidgets.add(Expanded(child: header!));
        if (header is ButtonBar) {
          startPadding = 12.0;
        }
      }
    } else {
      headerWidgets.add(Expanded(
        child: Text(localizations.selectedRowCountTitle(_selectedRowCount)),
      ));
    }
    if (selectedActions != null && _selectedRowCount != 0) {
      headerWidgets.addAll(selectedActions!.map<Widget>((Widget action) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 24.0 - 8.0 * 2.0),
          child: action,
        );
      }).toList());
    } else if (actions != null) {
      headerWidgets.addAll(actions!.map<Widget>((Widget action) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 24.0 - 8.0 * 2.0),
          child: action,
        );
      }).toList());
    }

    final TextStyle? footerTextStyle = themeData.textTheme.bodySmall;
    final List<Widget> footerWidgets = <Widget>[];
    if (onRowsPerPageChanged != null) {
      final List<Widget> _footerChildren =
          availableRowsPerPage.where((int value) => value <= rows.length || value == rowsPerPage).map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(value: value, child: Text('$value'));
      }).toList();
      footerWidgets.addAll(<Widget>[
        Container(width: 14),
        Text(localizations.rowsPerPageTitle),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                items: _footerChildren as List<DropdownMenuItem<int>>?,
                value: rowsPerPage,
                onChanged: onRowsPerPageChanged,
                style: footerTextStyle,
              ),
            ),
          ),
        ),
      ]);
    }
    footerWidgets.addAll(<Widget>[
      Container(width: 32),
      Text(localizations.pageRowsInfoTitle(firstRowIndex + 1, firstRowIndex + rowsPerPage, totalItems ?? rows.length, rowCountApproximate)),
      Container(width: 32),
      IconButton(
          icon: const Icon(Icons.chevron_left),
          padding: EdgeInsets.zero,
          tooltip: localizations.previousPageTooltip,
          onPressed: firstRowIndex <= 0 ? null : handlePrevious),
      Container(width: 24),
      IconButton(
          icon: const Icon(Icons.chevron_right),
          padding: EdgeInsets.zero,
          tooltip: localizations.nextPageTooltip,
          onPressed: (!rowCountApproximate && (firstRowIndex + rowsPerPage >= (totalItems ?? rows.length))) ? null : handleNext),
      Container(width: 14),
    ]);

    if (shrinkWrap) {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (showCheckboxColumn)
              Semantics(
                container: true,
                child: DefaultTextStyle(
                  style: _selectedRowCount > 0
                      ? themeData.textTheme.titleMedium!.copyWith(color: themeData.colorScheme.secondary)
                      : themeData.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w400),
                  child: IconTheme.merge(
                    data: const IconThemeData(opacity: 0.54),
                    child: ButtonTheme(
                      child: Ink(
                        height: 64,
                        color: _selectedRowCount > 0 ? themeData.secondaryHeaderColor : null,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(start: startPadding, end: 14),
                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: headerWidgets),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              dragStartBehavior: dragStartBehavior,
              child: Builder(
                builder: (BuildContext context) {
                  final rows = _getRows(firstRowIndex, rowsPerPage);
                  return DataTable(
                    showCheckboxColumn: showCheckboxColumn,
                    key: _tableKey,
                    columns: columns,
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: sortAscending,
                    onSelectAll: onSelectAll,
                    rows: rows,
                  );
                },
              ),
            ),
            DefaultTextStyle(
              style: footerTextStyle!,
              child: IconTheme.merge(
                data: const IconThemeData(opacity: 0.54),
                child: Container(
                  height: 56,
                  child: SingleChildScrollView(
                    dragStartBehavior: dragStartBehavior,
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Row(
                      children: footerWidgets,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (showCheckboxColumn)
            Semantics(
              container: true,
              child: DefaultTextStyle(
                style: _selectedRowCount > 0
                    ? themeData.textTheme.titleMedium!.copyWith(color: themeData.colorScheme.secondary)
                    : themeData.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w400),
                child: IconTheme.merge(
                  data: const IconThemeData(opacity: 0.54),
                  child: ButtonTheme(
                    child: Ink(
                      height: 64,
                      color: _selectedRowCount > 0 ? themeData.secondaryHeaderColor : null,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(start: startPadding, end: 14),
                        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: headerWidgets),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
              flex: 8,
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                        key: _tableKey,
                        columns: columns,
                        sortColumnIndex: sortColumnIndex,
                        sortAscending: sortAscending,
                        onSelectAll: onSelectAll,
                        rows: _getRows(firstRowIndex, rowsPerPage)),
                  ),
                ),
              ),
          ),
          DefaultTextStyle(
            style: footerTextStyle!,
            child: IconTheme.merge(
              data: const IconThemeData(opacity: 0.54),
              child: SizedBox(
                height: 56,
                child: SingleChildScrollView(
                  dragStartBehavior: dragStartBehavior,
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: footerWidgets,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
