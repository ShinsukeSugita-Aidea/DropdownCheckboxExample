import 'package:example/dropdown_checkbox.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ダミーデータ作成
    final List<(String value, String label)> items = List.generate(
      50,
      (index) => ('item_${index + 1}', 'Item ${index + 1}'),
    );

    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('チェックボックス実験'),
      ),
      body: Center(
        child: DropdownCheckbox(
            items: items,
            onChanged: (list) {
              for (final item in list) {
                print(item);
              }
            }),
      ),
    ));
  }
}
