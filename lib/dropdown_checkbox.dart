import 'package:flutter/material.dart';

class DropdownCheckbox extends StatefulWidget {
  final List<String> items;
  final String searchHintText;
  final String okText;
  final String cancelText;
  final double? height;
  final double? popupHeight;

  const DropdownCheckbox({
    required this.items,
    this.searchHintText = 'Search',
    this.okText = 'OK',
    this.cancelText = 'Cancel',
    this.height,
    this.popupHeight,
    Key? key,
  }) : super(key: key);

  @override
  DropdownCheckboxState createState() => DropdownCheckboxState();
}

class DropdownCheckboxState extends State<DropdownCheckbox> {
  late List<String> _filteredItems;
  List<String> _selectedCheckboxItems = [];
  String _searchQuery = "";
  final List<String> _tempSelectedItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
  }

  void _updateSearchQuery(String query, StateSetter setState) {
    setState(() {
      _searchQuery = query;
      _filteredItems = widget.items
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

  void _removeItem(String item) {
    setState(() {
      _selectedCheckboxItems.remove(item);
      _updateSelectedText();
      _prioritizeSelectedItems();
    });
  }

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
    double dropdownHeight = widget.height ?? 60;
    double popupHeight = widget.popupHeight ?? 300; // 追加

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: dropdownHeight,
          width: MediaQuery.of(context).size.width * 0.5,
          // ポップアップのボタン
          child: PopupMenuButton<int>(
            onSelected: (value) {
              _applySelection();
            },
            itemBuilder: (context) {
              // 変更を適用
              _tempSelectedItems.clear();
              for (final item in _selectedCheckboxItems) {
                _tempSelectedItems.add(item);
              }
              // アイテムの優先順位を設定
              _prioritizeSelectedItems();
              // 枠タップのたびに以下の処理が走る
              return [
                PopupMenuItem<int>(
                  enabled: false,
                  child: SizedBox(
                    height: popupHeight,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        List<Widget> itemsWidgets = [];

                        bool dividerAdded = false;
                        for (int i = 0; i < _filteredItems.length; i++) {
                          String item = _filteredItems[i];
                          bool isSelected = _tempSelectedItems.contains(item);
                          if (!isSelected &&
                              !dividerAdded &&
                              _tempSelectedItems.isNotEmpty) {
                            // 水平線を追加
                            itemsWidgets.add(
                              const Divider(),
                            );
                            dividerAdded = true;
                          }
                          // チェックボックスのあるボタンを含める
                          itemsWidgets.add(
                            CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
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
                        // 水平線
                        if (_tempSelectedItems.isEmpty) {
                          itemsWidgets.removeWhere(
                            (widget) => widget is Divider,
                          );
                        }

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: widget.searchHintText, // 検索のテキストを使用
                                  suffixIcon: const Icon(Icons.search),
                                ),
                                onChanged: (query) {
                                  _updateSearchQuery(query, setState);
                                },
                                // フォーカスを自動でセットする
                                autofocus: true,
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
                                  child: Text(
                                    widget.cancelText,
                                    style: TextStyle(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _applySelection();
                                  },
                                  child: Text(
                                    widget.okText,
                                  ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    // タグみたいな部分
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _selectedCheckboxItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Chip(
                              label: Text(item),
                              // 削除のバツアイコン
                              deleteIcon: const Icon(
                                Icons.clear,
                                size: 18,
                              ), //
                              onDeleted: () {
                                _removeItem(item);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // 左右の隙間
                  const SizedBox(
                    width: 10.0,
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
                    // xボタン
                    IconButton(
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
    );
  }
}
