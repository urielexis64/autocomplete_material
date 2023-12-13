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
            const AutocompleteMaterial.single(
              items: ['a', 'b', 'c', 'd', 'e'],
            ),
            const AutocompleteMaterial.multiple(
              items: [1, 2, 3, 4, 5],
            ),
            AutocompleteMaterial.searchAsync(
              onAsyncQuery: (query) async => [1, 2, 3, 4, 5],
            ),
            AutocompleteMaterial.multipleSearchAsync(
              onAsyncQuery: (query) async => [1, 2, 3, 4, 5],
              decoration: const AutocompleteDecoration(
                  hintText: 'Single', border: OutlineInputBorder()),
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
