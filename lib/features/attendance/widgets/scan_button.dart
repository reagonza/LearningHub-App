import 'package:flutter/material.dart';
import '../attendance_log_model.dart';

class ScanButton extends StatelessWidget {
  final AttendanceLog? currentStatus;
  final VoidCallback onPressed;

  const ScanButton({
    super.key,
    required this.currentStatus,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (currentStatus?.status == 'completed') {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: currentStatus?.status == 'active'
                ? [Colors.orange, Colors.deepOrange]
                : [const Color(0xFF6DC36D), const Color(0xFF3FB93F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color:
                  (currentStatus?.status == 'active'
                          ? Colors.orange
                          : const Color(0xFF6DC36D))
                      .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.qr_code_scanner, size: 28),
          label: Text(
            currentStatus?.status == 'active'
                ? 'Escanear para Salida'
                : 'Escanear para Entrada',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }
}
