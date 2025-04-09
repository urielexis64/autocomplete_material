import 'package:autocomplete_material/autocomplete_material.dart';
import 'package:flutter/material.dart';

class ExampleForm extends StatelessWidget {
  const ExampleForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete Material Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AutocompleteMaterial.single(
              items: const ['a', 'b', 'c', 'd', 'e'],
              onChanged: (String? value) {
                debugPrint(value);
              },
            ),
            AutocompleteMaterial.multiple(
              items: const [1, 2, 3, 4, 5],
              onItemsChanged: (value) {
                debugPrint(value.join(', '));
              },
            ),
            AutocompleteMaterial.searchAsync(
              onAsyncQuery: (query) => Future.delayed(
                const Duration(seconds: 1),
                () => [1, 2, 3, 4, 5],
              ),
              onChanged: (int? value) => debugPrint('$value'),
            ),
            AutocompleteMaterial.multipleSearchAsync(
              onAsyncQuery: (String? query) => Future.delayed(
                const Duration(seconds: 1),
                () => [1, 2, 3, 4, 5],
              ),
              onItemsChanged: (value) {
                debugPrint(value.join(', '));
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text('BottomAppBar'),
          ),
        ),
      ),
    );
  }
}
