// search_field.dart
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final VoidCallback? onTap;

  const SearchField({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.onTap, // <-- ADD THIS
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      onTap: onTap, // <-- PASS IT TO THE TextField
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: onClear,
        ),
      ),
    );
  }
}
