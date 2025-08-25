import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learninghub_app/features/attendance/widgets/recent_history_section.dart';

import 'attendance_controller.dart';
import 'attendance_log_model.dart';
import 'qr_scanner_page.dart';

class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(attendanceControllerProvider);

    ref.listen(attendanceControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'))),
      );
    });

    Future<void> _onScanPressed() async {
      final code = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => QRScannerPage(
            onQRScanned: (c) async => Navigator.of(context).pop(c),
          ),
        ),
      );
      if (code != null && code.isNotEmpty) {
        await ref.read(attendanceControllerProvider.notifier).scan(code);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('QR procesado')));
        }
      }
    }

    Widget _stat(String label, String value, {String? sub}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ],
      );
    }

    String _fmtDateTime(DateTime? d) {
      if (d == null) return '-';
      int hour12 = d.hour % 12;
      if (hour12 == 0) hour12 = 12;
      final ampm = d.hour < 12 ? 'am' : 'pm';
      String two(int x) => x.toString().padLeft(2, '0');
      return '${two(d.day)}/${two(d.month)}/${d.year} ${two(hour12)}:${two(d.minute)} $ampm';
    }

    String _fmtMinutes(int m) {
      final h = m ~/ 60;
      final mm = m % 60;
      return '${h}h ${mm}m';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia')),
      body: vm.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudo cargar la asistencia'),
              const SizedBox(height: 8),
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(attendanceControllerProvider.notifier).refresh(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (data) {
          final status = data.status;
          final week = data.weekSummary;
          final history = data.history;

          DateTime? _asDT(dynamic v) {
            if (v == null) return null;
            if (v is DateTime) return v;
            if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
            return null;
          }

          final lastOpenAt = _asDT(status['lastOpenAt']);
          final lastOpenPoint = status['lastOpenPoint']?.toString();
          final lastClosed = status['lastClosed'] as AttendanceLog?;
          final openCount = status['openCount'] as int? ?? 0;

          final completed = data.hasCompleteToday;
          final canScan =
              !completed; // si la jornada de HOY ya está completada => desactivar

          Widget header() {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado de hoy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _stat(
                          'Check‑in abierto:',
                          openCount > 0 ? 'Sí' : 'No',
                          sub: lastOpenPoint ?? '-',
                        ),
                        _stat('Hora de entrada:', _fmtDateTime(lastOpenAt)),
                        _stat(
                          'Último Check-out:',
                          _fmtDateTime(
                            lastClosed?.checkOut ?? lastClosed?.checkIn,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Resumen semanal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _stat(
                          'Días trabajados',
                          (week['daysWorked'] as int? ?? 0).toString(),
                        ),
                        _stat(
                          'Minutos totales',
                          (week['totalMinutes'] as int? ?? 0).toString(),
                          sub:
                              'Promedio/día: ${(week['averageMinutesPerDay'] as int? ?? 0)}',
                        ),
                        _stat(
                          'Tiempo total',
                          _fmtMinutes(week['totalMinutes'] as int? ?? 0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          Widget actions() {
            return Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(
                      completed
                          ? 'Jornada completada'
                          : (data.hasCheckInToday
                                ? 'Escanear Salida'
                                : 'Escanear Entrada'),
                    ),
                    onPressed: canScan ? _onScanPressed : null,
                  ),
                ),
              ],
            );
          }

          Widget historyList() {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historial reciente',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (history.isEmpty)
                      const Text('No hay registros recientes.')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: history.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, i) {
                          final log = history[i];
                          final isOpen = log.status == 'open';
                          return ListTile(
                            leading: Icon(isOpen ? Icons.login : Icons.logout),
                            title: Text(
                              '${isOpen ? 'Entrada' : 'Salida'} — ${log.pointName ?? '-'}',
                            ),
                            subtitle: Text(
                              _fmtDateTime(isOpen ? log.checkIn : log.checkOut),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(attendanceControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                header(),
                const SizedBox(height: 12),
                actions(),
                const SizedBox(height: 12),
                RecentHistorySection(logs: history, abbreviated: true),
              ],
            ),
          );
        },
      ),
    );
  }
}
