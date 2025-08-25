import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learninghub_app/features/profile/profile_controller.dart';

import '../attendance/attendance_controller.dart';
import '../attendance/attendance_page.dart';
import '../auth/auth_controller.dart';

import 'widgets/feature_card_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Perfil / saludo
    final profileCtrl = ref.watch(profileControllerProvider);
    final userName = profileCtrl.value?.displayName ?? 'Usuario';

    // Asistencia (mismo provider que la pantalla de registro)
    final vm = ref.watch(attendanceControllerProvider);

    ref.listen(attendanceControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'))),
      );
    });

    PreferredSizeWidget _buildAppBar() {
      return AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Toma el notifier ANTES del await
              final auth = ref.read(authControllerProvider.notifier);

              try {
                await auth.signOut();
                // IMPORTANTE:
                // No uses `ref` aquí después del await.
                // Si quieres feedback, usa el context (verificado con mounted).
                if (!context.mounted) return;
                // Opcional: mostrar un mensaje corto (la navegación la hace el router)
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Sesión cerrada')),
                // );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No se pudo cerrar sesión: $e')),
                );
              }
            },
          ),
        ],
      );
    }

    Widget _welcomeCard() {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(child: Icon(Icons.person, size: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Bienvenido, $userName!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Aquí tienes un resumen de tu asistencia.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    String _fmtDateTime(DateTime? d) {
      if (d == null) return '-';
      String two(int x) => x.toString().padLeft(2, '0');
      int hour12 = d.hour % 12;
      if (hour12 == 0) hour12 = 12;
      final ampm = d.hour < 12 ? 'am' : 'pm';
      return '${two(d.day)}/${two(d.month)}/${d.year} ${two(hour12)}:${two(d.minute)} $ampm';
    }

    Widget _attendanceSummary() {
      return vm.when(
        loading: () => const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
        ),
        error: (e, _) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.error_outline),
                const SizedBox(width: 8),
                Expanded(child: Text('No se pudo cargar la asistencia: $e')),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () =>
                      ref.read(attendanceControllerProvider.notifier).refresh(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          final s = data.status;
          final w = data.weekSummary;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu asistencia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Último check‑in',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmtDateTime(s['lastOpenAt'] as DateTime?),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s['lastOpenPoint'] as String? ?? '-',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Días trabajados esta semana',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (w['daysWorked'] as int? ?? 0).toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget _features() {
      return Column(
        children: [
          featureCard(
            context: context,
            icon: Icons.qr_code_scanner,
            title: 'Registro de Asistencia',
            subtitle: 'Escanea el código QR para registrar tu asistencia',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendancePage()),
              );
              // No hace falta _loadStats(); el provider se mantiene y la otra pantalla ya refresca.
            },
          ),
          // Agrega más FeatureCards si deseas...
        ],
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(attendanceControllerProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _welcomeCard(),
              const SizedBox(height: 12),
              _attendanceSummary(),
              const SizedBox(height: 12),
              _features(),
            ],
          ),
        ),
      ),
    );
  }
}
