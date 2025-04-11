import 'package:flutter/material.dart';

import 'example_form.dart';

// coverage:ignore-start
void main() {
  runApp(const AutocompleteMaterialExample());
}
// coverage:ignore-end

class AutocompleteMaterialExample extends StatelessWidget {
  const AutocompleteMaterialExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ExampleForm(),
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
    );
  }
}
