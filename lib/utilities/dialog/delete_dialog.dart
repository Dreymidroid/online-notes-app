import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<bool> showDeleteDiag(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Delete Note',
    content: 'Are you sure you want to Delete this note ?',
    optionsBuilder: () => {
      'Cancel': false,
      'Confirm': true
    },
  ).then((value) => value ?? false);
}