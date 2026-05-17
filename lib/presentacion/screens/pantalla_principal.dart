import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/presentacion/screens/auth/pantalla_login.dart';
import 'package:proyecto_kaptur/presentacion/screens/home/pantalla_inicio.dart';
import 'package:proyecto_kaptur/presentacion/screens/home/inicio_jefe.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_inspecciones.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/auditoria_jefe.dart';
import 'package:proyecto_kaptur/presentacion/screens/capacitacion/pantalla_capacitacion.dart';
import 'package:proyecto_kaptur/presentacion/screens/trabajadores/pantalla_trabajadores.dart';
import 'package:proyecto_kaptur/presentacion/screens/inspecciones/pantalla_nueva_inspecciones.dart';

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

    final rol = widget.usuario['rol'];

    if (rol == 'Jefe') {
      _pantallas = [
        InicioJefe(
          usuario: widget.usuario,
          onUserTap: _mostrarMenuUsuario,
        ),
        AuditoriaJefe(
          usuario: widget.usuario,
          onUserTap: _mostrarMenuUsuario,
        ),
        PantallaTrabajadores(
          usuario: widget.usuario,
          onUserTap: _mostrarMenuUsuario,
        ),
      ];
    } else {
      _pantallas = [
        PantallaInicio(
          usuario: widget.usuario,
          onUserTap: _mostrarMenuUsuario,
        ),
        PantallaInspecciones(
          usuario: widget.usuario,
          onUserTap: _mostrarMenuUsuario,
        ),
      ];

      if (rol == 'Supervisor') {
        _pantallas.add(
          PantallaCapacitacion(
            usuario: widget.usuario,
            onUserTap: _mostrarMenuUsuario,
          ),
        );
      }
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Crear nuevo',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _buildOpcionNuevaClaro(
                icon: Icons.verified_user_outlined,
                titulo: 'Nueva auditoría',
                subtitulo: 'Crear una nueva auditoría de seguridad',
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpcionNuevaClaro({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.withOpacity(0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppColors.navy,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade500,
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
    final rol = widget.usuario['rol'];
    final esJefe = rol == 'Jefe';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.navy,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, 'Inicio', 0),
          _buildNavItem(
            esJefe ? Icons.history_rounded : Icons.checklist_rounded,
            esJefe ? 'Historial' : 'Auditoría',
            1,
          ),
          if (esJefe) _buildNavItem(Icons.groups_rounded, 'Trabajadores', 2),
          if (rol == 'Supervisor')
            _buildNavItem(Icons.school_rounded, 'Capacitación', 2),
          if (rol == 'Supervisor') _buildNavAdd(),
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
