import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<void> showPasswordResetDialog(BuildContext context) {
  return showGenericDialog(context: context, title: 'Password Reset', content: 'Check Your Email', optionsBuilder: () => {
    'Ok': null
  });
}