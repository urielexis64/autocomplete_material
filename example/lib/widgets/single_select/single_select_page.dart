import 'package:autocomplete_material_example/widgets/single_select/single_select_autocomplete.dart';
import 'package:flutter/material.dart';

/// This page contains the example of the single select autocomplete widget.
/// It shows how to use the widget and how to handle the selected item.
class SingleSelectPage extends StatefulWidget {
  const SingleSelectPage({super.key});

  @override
  State<SingleSelectPage> createState() => _SingleSelectPageState();
}

class _SingleSelectPageState extends State<SingleSelectPage> {
  String? selectedItem;

  String get textToShow => selectedItem ?? 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Autocomplete Material Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleSelectAutocomplete(
              onChanged: (selectedValue) {
                setState(() {
                  selectedItem = selectedValue;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Text(
              'Selected Item: $textToShow',
              style: const TextStyle(fontSize: 16.0, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
