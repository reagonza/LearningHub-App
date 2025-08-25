import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../attendance_log_model.dart';

class CurrentStatusCard extends StatelessWidget {
  final AttendanceLog? currentStatus;

  const CurrentStatusCard({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            // deja tu método si ya lo usabas así
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A6DD8), Color(0xFF0856B8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Estado Actual',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentStatus == null)
              const Text(
                'No has registrado entrada hoy',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            else ...[
              Row(
                children: [
                  Icon(
                    currentStatus!.status == 'open'
                        ? Icons.work
                        : currentStatus!.status == 'needs_review'
                        ? Icons.error_outline
                        : Icons.work_off,
                    color: currentStatus!.status == 'open'
                        ? const Color(0xFF6DC36D)
                        : currentStatus!.status == 'needs_review'
                        ? const Color(0xFFFFA000)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentStatus!.status == 'open'
                        ? 'Trabajando'
                        : currentStatus!.status == 'needs_review'
                        ? 'Requiere revisión'
                        : 'Jornada completada',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatusRow(
                label: 'Entrada:',
                value: _formatTime(currentStatus!.checkIn),
              ),
              if (currentStatus!.checkOut != null)
                _StatusRow(
                  label: 'Salida:',
                  value: _formatTime(currentStatus!.checkOut!),
                ),
              if ((currentStatus!.pointName ?? '').isNotEmpty)
                _StatusRow(label: 'Punto:', value: currentStatus!.pointName!),
              if (currentStatus!.status == 'open')
                _StatusRow(
                  label: 'Tiempo trabajado:',
                  value: _getCurrentWorkingTime(),
                )
              else if (currentStatus!.minutesWorked != null)
                _StatusRow(
                  label: 'Total trabajado:',
                  value: _formatMinutes(currentStatus!.minutesWorked!),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final formatter = DateFormat('h:mm a');
    return formatter.format(dateTime);
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  String _getCurrentWorkingTime() {
    if (currentStatus == null) return '0h 0m';

    final now = DateTime.now();
    final checkInLocal = currentStatus!.checkIn.toLocal();
    final duration = now.difference(checkInLocal);

    if (duration.isNegative) return '0h 0m';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatusRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
