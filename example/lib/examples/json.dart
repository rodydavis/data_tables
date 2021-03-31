import 'dart:convert';

import 'package:data_tables/data_tables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JsonExample extends StatefulWidget {
  @override
  _JsonExampleState createState() => _JsonExampleState();
}

class _JsonExampleState extends State<JsonExample> {
  int _rowsPerPage = 100;
  int _sortColumnIndex;
  bool _sortAscending = true;
  List<Map<String, dynamic>> _items = [];
  int _rowsOffset = 0;

  @override
  void initState() {
    getJsonList('https://jsonplaceholder.typicode.com/todos').then((value) {
      if (mounted) {
        setState(() {
          _items = value;
        });
      }
    });

    super.initState();
  }

  Future<List<Map<String, dynamic>>> getJsonList(String target) async {
    final url = Uri.parse(target);
    final response = await http.get(url);
    return List.from(json.decode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Table Example'),
      ),
      // body: buildDataTable(),
      body: _items == null || _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : NativeDataTable.fromJson(
              showCheckboxColumn: false,
              rowsPerPage: 40,
              items: _items,
            ),
    );
  }
}
