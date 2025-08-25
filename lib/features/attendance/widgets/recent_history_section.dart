import 'package:flutter/material.dart';

import '../attendance_log_model.dart';

/// --------------------------------------------------------------
/// RecentHistorySection
/// --------------------------------------------------------------
/// Muestra el historial de asistencia agrupado por día con:
/// - Fecha amigable en español (abreviada por defecto)
/// - Hora de check-in y check-out por registro
/// - Total trabajado formateado (si tu modelo expone `formattedTotalHours`)
///
/// Uso:
///   RecentHistorySection(
///     logs: history,           // List<AttendanceLog>
///     abbreviated: true,        // true: "lun 25 de ago 2025", false: "lunes 25 de agosto 2025"
///   )
class RecentHistorySection extends StatelessWidget {
  const RecentHistorySection({
    super.key,
    required this.logs,
    this.abbreviated = true,
    this.title = 'Historial reciente',
    this.emptyText = 'No hay registros recientes.',
  });

  /// Lista de registros a mostrar.
  final List<AttendanceLog> logs;

  /// Controla el formato de fecha:
  /// - true  => "lun 25 de ago 2025"
  /// - false => "lunes 25 de agosto 2025"
  final bool abbreviated;

  /// Título del bloque.
  final String title;

  /// Texto a mostrar cuando no hay registros.
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    // Agrupar por día usando la fecha de check-in.
    final Map<DateTime, List<AttendanceLog>> byDay = {};
    for (final log in logs) {
      final key = _dateOnly(log.checkIn);
      final list = byDay.putIfAbsent(key, () => []);
      list.add(log);
    }

    // Ordenar días (descendente: más reciente primero).
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            if (logs.isEmpty)
              Text(emptyText, style: Theme.of(context).textTheme.bodyMedium)
            else
              // Lista agrupada por fecha
              Column(
                children: [
                  for (final day in days) ...[
                    // Encabezado de fecha amigable (ES)
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
                      child: Text(
                        _formatFriendlyDate(day, abbreviated: abbreviated),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Registros del día (ordenados por hora de check-in descendente)
                    ..._buildDayLogs(context, byDay[day]!),
                    // Separador entre días
                    const Divider(height: 24),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers de UI
  // ---------------------------------------------------------------------------

  List<Widget> _buildDayLogs(
    BuildContext context,
    List<AttendanceLog> dayLogs,
  ) {
    final sorted = [...dayLogs]..sort((a, b) => b.checkIn.compareTo(a.checkIn));
    return [
      for (final log in sorted)
        _HistoryTile(
          log: log,
          // Punto (si está disponible)
          point: log.pointName ?? '-',
          // Horarios
          checkInText: _formatTime(log.checkIn),
          checkOutText: _formatTime(log.checkOut),
          // Duración (si tu modelo tiene el getter; de lo contrario, se puede omitir)
          totalText: _safeTotal(log),
        ),
    ];
  }

  /// Devuelve solo la parte de fecha (00:00:00) en local time.
  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Formatea una fecha amigable en español.
  /// - abreviado: "lun 25 de ago 2025"
  /// - largo:     "lunes 25 de agosto 2025"
  String _formatFriendlyDate(DateTime d, {required bool abbreviated}) {
    // DateTime.weekday: 1=lun ... 7=dom
    const weekdaysShort = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
    const weekdaysLong = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];

    const monthsShort = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    const monthsLong = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    final wd = (d.weekday - 1).clamp(0, 6);
    final diames = d.day;
    final mes = d.month - 1;

    if (abbreviated) {
      return '${weekdaysShort[wd]} $diames de ${monthsShort[mes]} ${d.year}';
    } else {
      return '${weekdaysLong[wd]} $diames de ${monthsLong[mes]} ${d.year}';
    }
  }

  /// Formatea una hora `DateTime?` a "hh:mm am/pm".
  /// Si viene null, devuelve "—".
  String _formatTime(DateTime? dt) {
    if (dt == null) return '—';
    int hh = dt.hour % 12;
    if (hh == 0) hh = 12;
    final ampm = dt.hour < 12 ? 'am' : 'pm';
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(hh)}:${two(dt.minute)} $ampm';
  }

  /// Retorna el total formateado si existe el getter, sino '—'.
  String _safeTotal(AttendanceLog log) {
    try {
      // Si añadiste el getter `formattedTotalHours` al modelo, úsalo:
      // (de lo contrario, puedes calcular con checkIn/checkOut afuera)
      // ignore: unnecessary_cast
      final has = (log as dynamic).formattedTotalHours;
      if (has is String && has.isNotEmpty) return has;
      return has?.toString() ?? '—';
    } catch (_) {
      return '—';
    }
  }
}

/// Tile individual del historial con:
/// - Punto (título)
/// - Subtítulo: "Entrada: 08:30 am · Salida: 12:15 pm · Total: 3h 45m"
/// - Ícono según estado (open/closed/otro)
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.log,
    required this.point,
    required this.checkInText,
    required this.checkOutText,
    required this.totalText,
  });

  final AttendanceLog log;
  final String point;
  final String checkInText;
  final String checkOutText;
  final String totalText;

  @override
  Widget build(BuildContext context) {
    final isClosed = log.status.toLowerCase() == 'closed';
    final isOpen = log.status.toLowerCase() == 'open';

    IconData icon;
    if (isClosed) {
      icon = Icons.logout; // salida
    } else if (isOpen) {
      icon = Icons.login; // entrada
    } else {
      icon = Icons.schedule; // en revisión, etc.
    }

    return ListTile(
      leading: Icon(icon),
      title: Text(point),
      subtitle: Text(
        'Entrada: $checkInText · Salida: $checkOutText · Total: $totalText',
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
