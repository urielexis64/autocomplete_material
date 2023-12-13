import 'package:flutter/material.dart';

import 'example_form.dart';

void main() {
  runApp(const AutocompleteMaterialExample());
}

class AutocompleteMaterialExample extends StatelessWidget {
  const AutocompleteMaterialExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ExampleForm());
  }
}
