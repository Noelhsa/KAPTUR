import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/presentacion/screens/home/pantalla_inicio.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_inspecciones.dart';
import 'package:proyecto_kaptur/presentacion/screens/capacitacion/pantalla_capacitacion.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_nueva_inspecciones.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_evaluacion.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_checklist.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_hallazgos.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActivo = 0;

  final List<Widget> _pantallas = const [
    PantallaInicio(),
    PantallaInspecciones(),
    PantallaCapacitacion(),
  ];

  void _mostrarMenuNuevo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Línea indicadora
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Crear nuevo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            _buildOpcionMenu(
              icon: Icons.verified_user_outlined,
              titulo: 'Mi verificación',
              subtitulo: 'Aprobar o rechazar una inspección',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PantallaNuevaInspeccion(),
                  ),
                );
              },
            ),
            _buildOpcionMenu(
              icon: Icons.engineering_outlined,
              titulo: 'Evaluación',
              subtitulo: 'Evaluar EPP de trabajadores',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PantallaEvaluacion(),
                  ),
                );
              },
            ),
            _buildOpcionMenu(
              icon: Icons.checklist_outlined,
              titulo: 'Checklist',
              subtitulo: 'Controles críticos de seguridad',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PantallaChecklist(),
                  ),
                );
              },
            ),
            _buildOpcionMenu(
              icon: Icons.report_problem_outlined,
              titulo: 'Hallazgos',
              subtitulo: 'Registrar un hallazgo de seguridad',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PantallaHallazgos(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionMenu({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceActivo,
        children: _pantallas,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, 'Inicio', 0),
          _buildNavItem(Icons.checklist_rounded, 'Inspecciones', 1),
          _buildNavItem(Icons.school_rounded, 'Capacitación', 2),
          _buildNavAdd(),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int indice) {
    final activo = _indiceActivo == indice;
    return GestureDetector(
      onTap: () => setState(() => _indiceActivo = indice),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: activo ? AppColors.orange : AppColors.textHint,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: activo ? AppColors.orange : AppColors.textHint,
                fontSize: 11,
                fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavAdd() {
    return GestureDetector(
      onTap: _mostrarMenuNuevo,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.orange,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}