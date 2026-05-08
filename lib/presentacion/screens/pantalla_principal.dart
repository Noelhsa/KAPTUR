import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/presentacion/screens/auth/pantalla_login.dart';
import 'package:proyecto_kaptur/presentacion/screens/home/pantalla_inicio.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_inspecciones.dart';
import 'package:proyecto_kaptur/presentacion/screens/capacitacion/pantalla_capacitacion.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_nueva_inspecciones.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_evaluacion.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_checklist.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_hallazgos.dart';

class PantallaPrincipal extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const PantallaPrincipal({
    super.key,
    required this.usuario,
  });

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActivo = 0;

  late final List<Widget> _pantallas;

  @override
  void initState() {
    super.initState();
    _pantallas = [
      PantallaInicio(
        usuario: widget.usuario,
        onUserTap: _mostrarMenuUsuario,
      ),
      const PantallaInspecciones(),
    ];

    if (widget.usuario['rol'] == 'Supervisor') {
      _pantallas.add(const PantallaCapacitacion());
    }
  }

  void _mostrarMenuUsuario() {
    final nombre = widget.usuario['nombre'] ?? 'Usuario';
    final apellidos = widget.usuario['apellidos'] ?? '';
    final rol = widget.usuario['rol'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.navy,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$nombre $apellidos',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rol,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language, color: AppColors.navy),
                title: const Text(
                  'Idioma',
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: const Text(
                  'Español',
                  style: TextStyle(color: Colors.black54),
                ),
                onTap: () {},
              ),
              ListTile(
                leading:
                    const Icon(Icons.dark_mode_outlined, color: AppColors.navy),
                title: const Text(
                  'Tema',
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: const Text(
                  'Claro',
                  style: TextStyle(color: Colors.black54),
                ),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
                    builder: (_) => PantallaNuevaInspeccion(
                      usuario: widget.usuario,
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.navy,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, 'Inicio', 0),
          _buildNavItem(Icons.checklist_rounded, 'Auditoría', 1),
          if (widget.usuario['rol'] == 'Supervisor')
            _buildNavItem(Icons.school_rounded, 'Capacitación', 2),
          if (widget.usuario['rol'] == 'Supervisor')
            _buildNavAdd(), // Solo para el Supervisor
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int indice) {
    final activo = _indiceActivo == indice;

    return GestureDetector(
      onTap: () => setState(() => _indiceActivo = indice),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  activo ? Colors.white.withOpacity(0.15) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavAdd() {
    return GestureDetector(
      onTap: _mostrarMenuNuevo,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 22),
      ),
    );
  }
}
