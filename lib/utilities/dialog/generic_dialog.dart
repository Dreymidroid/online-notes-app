import 'package:flutter/material.dart';

typedef DialogOptBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptBuilder optionsBuilder,
}) {
  final options = optionsBuilder;
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options().keys.map((e) {
          final value = options()[e];
          return TextButton(
            onPressed: () {
              if (value != null) {
                Navigator.of(context).pop(value);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(e),
          );
        }).toList(),
      );
    },
  );
}
