import 'package:flutter/material.dart';

class AttendanceDialogs {
  static void showSuccessDialog(
    BuildContext context,
    String message,
    VoidCallback onClose,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(
          Icons.check_circle,
          color: Color(0xFF6DC36D),
          size: 48,
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onClose();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0A6DD8),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.error, color: Colors.red, size: 48),
        content: Text(error, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0A6DD8),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
