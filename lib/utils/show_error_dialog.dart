import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String errorMsg) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('An error has occured.'),
        content: Text(errorMsg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
