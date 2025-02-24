import 'package:flutter/material.dart';

/// Options for creating new items in an autocomplete widget.
///
/// This class provides configuration options for handling the creation of new items
/// when a user enters text that doesn't match any existing items.
class CreatableOptions<T> {
  /// Creates a [CreatableOptions] instance.
  ///
  /// The [isCreatable] function determines whether the current query can be used to create a new item.
  /// The [queryToObject] function converts the query string into a new item of type [T].
  ///
  /// Optional [widgetBuilder] can be provided to customize the widget shown for creating new items.
  CreatableOptions({
    required this.isCreatable,
    required this.queryToObject,
    this.widgetBuilder,
  });

  /// Function that determines whether the current query can be used to create a new item.
  final bool Function(String query) isCreatable;

  /// Function that builds a custom widget for the creatable item option.
  ///
  /// If not provided, a default ListTile will be shown.
  final Widget Function(T)? widgetBuilder;

  /// Function that converts the query string into a new item of type [T].
  final T Function(String query) queryToObject;
}
