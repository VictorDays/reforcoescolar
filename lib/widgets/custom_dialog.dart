import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isConfirm;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.isConfirm = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isConfirm ? Colors.red : Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text(isConfirm ? 'Excluir' : 'OK'),
        ),
      ],
    );
  }
}