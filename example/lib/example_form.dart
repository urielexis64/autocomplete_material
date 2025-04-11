import 'package:autocomplete_material/autocomplete_material.dart';
import 'package:autocomplete_material_example/widgets/single_select/single_select_page.dart';
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
            Semantics(
              label: 'SingleSelectButton',
              child: TextButton(
                child: Text('Single Select'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SingleSelectPage(),
                    ),
                  );
                },
              ),
            ),
            AutocompleteMaterial.multiple(
              items: const [1, 2, 3, 4, 5],
              onItemsChanged: (selectedItems) {},
            ),
            AutocompleteMaterial.searchAsync(
              onAsyncQuery: (query) async => [1, 2, 3, 4, 5],
              onChanged: (int? value) {},
            ),
            AutocompleteMaterial.multipleSearchAsync(
              onAsyncQuery: (query) async => [1, 2, 3, 4, 5],
              onItemsChanged: (List<int> value) {},
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
