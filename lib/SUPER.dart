import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DropdownCheckboxExample(),
    );
  }
}

class DropdownCheckboxExample extends StatefulWidget {
  const DropdownCheckboxExample({super.key});

  @override
  DropdownCheckboxExampleState createState() => DropdownCheckboxExampleState();
}

class DropdownCheckboxExampleState extends State<DropdownCheckboxExample> {
  final List<String> _items = List.generate(50, (index) => 'Item ${index + 1}');
  List<String> _filteredItems = [];
  List<String> _selectedCheckboxItems = [];
  String _searchQuery = "";
  final List<String> _tempSelectedItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(_items);
  }

  void _updateSearchQuery(String query, StateSetter setState) {
    setState(() {
      _searchQuery = query;
      _filteredItems = _items
          .where(
              (item) => item.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      _prioritizeSelectedItems();
    });
  }

  void _updateSelectedText() {
    setState(() {});
  }

  void _prioritizeSelectedItems() {
    _filteredItems.sort((a, b) {
      bool aSelected = _tempSelectedItems.contains(a);
      bool bSelected = _tempSelectedItems.contains(b);
      if (aSelected && !bSelected) {
        return -1;
      } else if (!aSelected && bSelected) {
        return 1;
      } else {
        return 0;
      }
    });
  }

  // タグみたいな部分からの削除
  void _removeItem(String item) {
    setState(() {
      _selectedCheckboxItems.remove(item);
      _updateSelectedText();
      _prioritizeSelectedItems();
    });
  }

  // xボタンでの全部消す
  void _clearAll() {
    setState(() {
      _selectedCheckboxItems.clear();
      _updateSelectedText();
      _prioritizeSelectedItems();
    });
  }

  void _applySelection() {
    setState(() {
      _selectedCheckboxItems = List.from(_tempSelectedItems);
      _updateSelectedText();
    });
  }

  void _cancelSelection() {
    setState(() {
      _tempSelectedItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown with Checkboxes and Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              child: PopupMenuButton<int>(
                onSelected: (value) {
                  _applySelection();
                },
                itemBuilder: (context) {
                  // 反映
                  _tempSelectedItems.clear(); // 一度全部削除して
                  for (final item in _selectedCheckboxItems) {
                    // 反映
                    _tempSelectedItems.add(item);
                  }
                  // 優先度反映
                  _prioritizeSelectedItems();
                  // 枠タップのたびに走る
                  return [
                    PopupMenuItem<int>(
                      enabled: false,
                      child: SizedBox(
                        height: 300,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            List<Widget> itemsWidgets = [];

                            bool dividerAdded = false;
                            for (int i = 0; i < _filteredItems.length; i++) {
                              String item = _filteredItems[i];
                              bool isSelected =
                                  _tempSelectedItems.contains(item);
                              if (!isSelected &&
                                  !dividerAdded &&
                                  _tempSelectedItems.isNotEmpty) {
                                // 水平線
                                itemsWidgets
                                    .add(const Divider(color: Colors.black));
                                dividerAdded = true;
                              }
                              itemsWidgets.add(
                                // チェックのあるボタン
                                CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(item),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _tempSelectedItems.add(item);
                                      } else {
                                        _tempSelectedItems.remove(item);
                                      }
                                      _prioritizeSelectedItems();
                                    });
                                  },
                                ),
                              );
                            }

                            if (_tempSelectedItems.isEmpty) {
                              itemsWidgets
                                  .removeWhere((widget) => widget is Divider);
                            }

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: "Search",
                                      suffixIcon: Icon(Icons.search),
                                    ),
                                    onChanged: (query) {
                                      _updateSearchQuery(query, setState);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: ListView(children: itemsWidgets),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _cancelSelection();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _applySelection();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ];
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // タグみたいな部分
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _selectedCheckboxItems.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: Chip(
                                  label: Text(item),
                                  onDeleted: () {
                                    _removeItem(item);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      if (_selectedCheckboxItems.isNotEmpty)
                        // 数字部分の表示
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            '${_selectedCheckboxItems.length}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      if (_selectedCheckboxItems.isNotEmpty)
                        IconButton(
                          // xボタン
                          icon: const Icon(Icons.clear),
                          onPressed: _clearAll,
                        ),
                      // 逆三角形
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
