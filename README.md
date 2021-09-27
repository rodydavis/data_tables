[![Buy Me A Coffee](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg)](https://www.buymeacoffee.com/rodydavis)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WSH3GVC49GNNJ)
![github pages](https://github.com/rodydavis/data_tables/workflows/github%20pages/badge.svg)
[![GitHub stars](https://img.shields.io/github/stars/rodydavis/data_tables?color=blue)](https://github.com/rodydavis/data_tables)
[![data_tables](https://img.shields.io/pub/v/data_tables.svg)](https://pub.dev/packages/data_tables)

# data_tables

- Full Screen Paginated Data Tables for Tablets/Desktops
- Mobile ListView with Action Buttons for Sorting and Selecting All
- Supports Dark Mode
- From Json

Online Demo: https://rodydavis.github.io/data_tables/
### Usage
Date:27/sep/22021 Plugin not updated so you can add dependency like this if you have any error in version 2.5.0
```dart 
  data_tables:
    git:
      url: https://github.com/dwpsoft/data_tables.git
```
## Getting Started

- You can optionally build the listview for mobile with a builder, by default it creates a ExpansionTile with the remaining columns as children
- The tablet breakpoint can also be set.

  `bool showMobileListView;` - When set to false it will always show a data table

  `int sortColumnIndex;` - Current Sorted Column

  `bool sortAscending;` - Sort Order

  `ValueChanged<bool> onSelectAll;` - Called for Selecting and Deselecting All

  `ValueChanged<int> onRowsPerPageChanged;` - Called when rows change on data table or last row reached on mobile.

  `int rowsPerPage;` - Default Rows per page

  `Widget header;` - Widget header for Desktop and Tablet Data Table

  `List<DataColumn> columns;` - List of Columns (Must match length of DataCells in DataSource)

  `IndexedWidgetBuilder mobileItemBuilder;` - Optional Item builder for the list view for Mobile

  `Size tabletBreakpoint;` - Tablet breakpoint for the screen width and height

  `List<Widget> actions, selectedActions;` - Actions that show when items are selected or not

  `RefreshCallback onRefresh;` - If not null the list view will be wrapped in a RefreshIndicator

## Screenshots

![](https://github.com/rodydavis/data_tables/blob/master/screenshots/1.PNG)

![](https://github.com/rodydavis/data_tables/blob/master/screenshots/2.PNG)

![](https://github.com/rodydavis/data_tables/blob/master/screenshots/3.PNG)

![](https://github.com/rodydavis/data_tables/blob/master/screenshots/4.PNG)

![](https://github.com/rodydavis/data_tables/blob/master/screenshots/5.PNG)
