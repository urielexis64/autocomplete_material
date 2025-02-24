import 'package:flutter/material.dart';

class CreatableOptions<T> {
  CreatableOptions({
    required this.isCreatable,
    required this.queryToObject,
    this.widgetBuilder,
  });

  final bool Function(String query) isCreatable;
  final Widget Function(T)? widgetBuilder;
  final T Function(String query) queryToObject;
}
