import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) async {
  return showGenericDialog<void>(
    content: text,
    context: context,
    optionsBuilder: () => {
      'OK': null
    },
    title: 'An Error Occurred',
  );
}
