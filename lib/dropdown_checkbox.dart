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
  late List<String> _originalItemsOrder; // 元の順序を保持するリスト

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
    _originalItemsOrder = List.from(widget.items); // 初期化時に元の順序を保存
  }

  // 検索フィルタ
  void _updateSearchQuery(String query, StateSetter setState) {
    setState(() {
      _searchQuery = query;
      _filteredItems = _originalItemsOrder
          .where(
              (item) => item.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  void _updateSelectedText() {
    setState(() {});
  }

  void _prioritizeSelectedItems() {
    // リストの各要素をインデックスとともにマップにする
    Map<String, int> originalIndexMap = {};
    for (int i = 0; i < _originalItemsOrder.length; i++) {
      originalIndexMap[_originalItemsOrder[i]] = i;
    }

    // カスタムソート関数で並び替えを行う
    _filteredItems.sort((a, b) {
      bool aSelected = _tempSelectedItems.contains(a);
      bool bSelected = _tempSelectedItems.contains(b);

      // チェックされた項目を優先して並び替える条件
      if (aSelected && !bSelected) {
        return -1;
      } else if (!aSelected && bSelected) {
        return 1;
      } else {
        // チェック状態が同じ場合は元の順序を維持する
        int aIndex = originalIndexMap[a]!;
        int bIndex = originalIndexMap[b]!;
        return aIndex.compareTo(bIndex);
      }
    });
  }

  void _removeItem(String item) {
    setState(() {
      _selectedCheckboxItems.remove(item);
      _updateSelectedText();
    });
  }

  void _clearAll() {
    setState(() {
      _selectedCheckboxItems.clear();
      _updateSelectedText();
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
    double popupHeight = widget.popupHeight ?? 300;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: dropdownHeight,
          width: MediaQuery.of(context).size.width * 0.5,
          child: PopupMenuButton<int>(
            onOpened: () {
              // 開いた瞬間に並び替え
              _filteredItems = List.from(_originalItemsOrder);
              _prioritizeSelectedItems();
            },
            itemBuilder: (context) {
              _tempSelectedItems.clear();
              for (final item in _selectedCheckboxItems) {
                _tempSelectedItems.add(item);
              }
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
                            // 水平線
                            itemsWidgets.add(const Divider());
                            dividerAdded = true;
                          }
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
                                  // チェックボックスの操作後は並び替えをしない
                                });
                              },
                            ),
                          );
                        }
                        if (_tempSelectedItems.isEmpty) {
                          // 水平線消す
                          itemsWidgets.removeWhere(
                            (widget) => widget is Divider,
                          );
                        }

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                // フォーカスを自動でセットする
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: widget.searchHintText,
                                  // 虫眼鏡
                                  suffixIcon: const Icon(Icons.search),
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
                                // キャンセル
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _cancelSelection();
                                  },
                                  child: Text(widget.cancelText),
                                ),
                                // OK
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _applySelection();
                                  },
                                  child: Text(widget.okText),
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _selectedCheckboxItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Chip(
                              label: Text(item),
                              deleteIcon: const Icon(
                                Icons.clear,
                                size: 18,
                              ),
                              onDeleted: () {
                                _removeItem(item);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  if (_selectedCheckboxItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
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
                    // バツボタン
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearAll,
                    ),
                  // 下向きボタン
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
