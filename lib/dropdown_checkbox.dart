import 'package:flutter/material.dart';

class DropdownCheckbox extends StatefulWidget {
  const DropdownCheckbox({
    required this.items,
    required this.onChanged,
    this.searchHintText = 'Search',
    this.okText = 'OK',
    this.cancelText = 'Cancel',
    this.height,
    this.popupHeight,
    super.key,
  });
  final List<(String value, String label)> items;
  final String searchHintText;
  final String okText;
  final String cancelText;
  final double? height;
  final double? popupHeight;
  final void Function(List<String>) onChanged;

  @override
  DropdownCheckboxState createState() => DropdownCheckboxState();
}

class DropdownCheckboxState extends State<DropdownCheckbox> {
  late List<(String value, String label)> _filteredItems;
  List<String> _selectedCheckboxItems = [];
  String _searchQuery = '';
  final List<String> _tempSelectedItems = [];
  late List<(String value, String label)> _originalItemsOrder; // 元の順序を保持するリスト
  List<bool> _dividerPositions = []; // 水平線の位置を管理するリスト

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
            (item) =>
                // $2: label
                item.$2.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    });
  }

  void _updateSelectedText() {
    setState(() {});
  }

  void _prioritizeSelectedItems() {
    // リストの各要素をインデックスとともにマップにする
    final originalIndexMap = <String, int>{};
    for (var i = 0; i < _originalItemsOrder.length; i++) {
      // $1: value
      originalIndexMap[_originalItemsOrder[i].$1] = i;
    }

    // 水平線の位置をリセット
    _dividerPositions = List.generate(_filteredItems.length, (index) => false);

    // カスタムソート関数で並び替えを行う
    _filteredItems.sort((a, b) {
      // $1: value
      final aSelected = _tempSelectedItems.contains(a.$1);
      final bSelected = _tempSelectedItems.contains(b.$1);

      // チェックされた項目を優先して並び替える条件
      if (aSelected && !bSelected) {
        return -1;
      } else if (!aSelected && bSelected) {
        return 1;
      } else {
        // チェック状態が同じ場合は元の順序を維持する
        // $1: value
        final aIndex = originalIndexMap[a.$1]!;
        final bIndex = originalIndexMap[b.$1]!;
        return aIndex.compareTo(bIndex);
      }
    });

    // 水平線の位置を記録する
    var dividerAdded = false;
    for (var i = 0; i < _filteredItems.length; i++) {
      final item = _filteredItems[i];
      final isSelected = _tempSelectedItems.contains(item.$1);
      if (!isSelected && !dividerAdded && _tempSelectedItems.isNotEmpty) {
        _dividerPositions[i] = true;
        dividerAdded = true;
      }
    }
  }

  void _removeItem(String value) {
    setState(() {
      _selectedCheckboxItems.remove(value);
      _updateSelectedText();
    });
  }

  void _clearAll() {
    setState(() {
      _selectedCheckboxItems.clear();
      _updateSelectedText();
    });
  }

  // OK押下の処理
  void _applySelection() {
    setState(() {
      _selectedCheckboxItems = List.from(_tempSelectedItems);
      _updateSelectedText();

      // 返す
      widget.onChanged(_selectedCheckboxItems);
    });
  }

  // キャンセル押下の処理
  void _cancelSelection() {
    setState(_tempSelectedItems.clear);
  }

  @override
  Widget build(BuildContext context) {
    final dropdownHeight = widget.height ?? 60;
    final popupHeight = widget.popupHeight ?? 300;

    // タグ用
    // _selectedCheckboxItems の順序を _originalItemsOrder に基づいて並べ替え
    final sortedSelectedItems = _originalItemsOrder
        .where((item) => _selectedCheckboxItems.contains(item.$1))
        .toList();

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

              // _selectedCheckboxItemsにあるvalueをaddする
              _selectedCheckboxItems.forEach(_tempSelectedItems.add);

              return [
                PopupMenuItem<int>(
                  enabled: false,
                  child: SizedBox(
                    height: popupHeight,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        final itemsWidgets = <Widget>[];

                        var dividerAdded = false;
                        for (var i = 0; i < _filteredItems.length; i++) {
                          final item = _filteredItems[i];
                          final isSelected =
                              _tempSelectedItems.contains(item.$1);
                          // 水平線
                          if (_dividerPositions[i] && !dividerAdded) {
                            itemsWidgets.add(const Divider());
                            dividerAdded = true;
                          }
                          itemsWidgets.add(
                            CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(item.$2),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _tempSelectedItems.add(item.$1);
                                  } else {
                                    _tempSelectedItems.remove(item.$1);
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
                              padding: const EdgeInsets.all(8),
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
                border: Border.all(),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sortedSelectedItems.map((item) {
                          // タグ
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Chip(
                              label: Text(item.$2),
                              // バツボタン
                              deleteIcon: const Icon(
                                Icons.clear,
                                size: 18,
                              ),
                              onDeleted: () {
                                // $1: value
                                _removeItem(item.$1);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_selectedCheckboxItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
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
