import 'package:flutter/material.dart';

/// Tarjeta de “feature” consistente con el estilo de la app.
/// - Usa `Card` con bordes suaves y padding 16 (como en Attendance/Home).
/// - Icono dentro de un contenedor con tono del `primary`.
/// - Títulos/descr. con los mismos tamaños/colores utilizados.
/// - Ripple correcto (InkWell) y accesible.
/// - Parámetro opcional `accentColor` por si quieres variar el color.
Widget featureCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  Color? accentColor, // opcional
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  // Color de acento: por defecto usa el primario del tema
  final Color accent = accentColor ?? colorScheme.primary;

  // Texto secundario coherente con el resto de pantallas
  const TextStyle subtitleStyle = TextStyle(fontSize: 12);

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias, // asegura que el ripple respete el radio
    child: InkWell(
      onTap: onTap,
      // feedback de foco/hover en desktop/web
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==== Icono con “pill” y tono del primary ====
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // Fondo con el color primario en baja opacidad
                color: accent.withValues(alpha: 0.12),
                // Borde sutil para dar definición
                border: Border.all(color: accent.withValues(alpha: 0.20)),
              ),
              child: Icon(icon, size: 26, color: accent),
            ),

            const SizedBox(width: 12),

            // ==== Título + subtítulo ====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título consistente (18, bold)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: subtitleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ==== Flecha sutil ====
            Icon(Icons.arrow_forward_ios, size: 16, semanticLabel: 'Abrir'),
          ],
        ),
      ),
    ),
  );
}
