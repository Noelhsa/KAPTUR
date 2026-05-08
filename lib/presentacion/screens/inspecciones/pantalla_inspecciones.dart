import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/presentacion/screens/auth/pantalla_login.dart';
import 'pantalla_detalle_inspecciones.dart';

class PantallaInspecciones extends StatefulWidget {
  const PantallaInspecciones({super.key});

  @override
  State<PantallaInspecciones> createState() => _PantallaInspeccionesState();
}

class _PantallaInspeccionesState extends State<PantallaInspecciones> {
  String _filtroActivo = 'Todos';

  final List<String> _filtros = [
    'Todos',
    'Pendiente',
    'Completado',
    'En progreso',
    'Por confirmar',
  ];

  final List<Map<String, String>> _inspecciones = [
    {
      'id': '001',
      'titulo': 'Verificación mensual de mantenimiento',
      'area': 'Área 3A',
      'fecha': '19/04/2025',
      'estado': 'Pendiente',
    },
    {
      'id': '002',
      'titulo': 'Revisión de suministros eléctricos',
      'area': 'Área 1B',
      'fecha': '18/04/2025',
      'estado': 'Completado',
    },
    {
      'id': '003',
      'titulo': 'Inspección de equipo de soldadura',
      'area': 'Área 2C',
      'fecha': '17/04/2025',
      'estado': 'En progreso',
    },
    {
      'id': '004',
      'titulo': 'Control de inventario de herramientas',
      'area': 'Bodega',
      'fecha': '16/04/2025',
      'estado': 'Por confirmar',
    },
    {
      'id': '005',
      'titulo': 'Revisión de sistemas de seguridad',
      'area': 'Área 3A',
      'fecha': '15/04/2025',
      'estado': 'Completado',
    },
  ];

  List<Map<String, String>> get _inspeccionesFiltradas {
    if (_filtroActivo == 'Todos') return _inspecciones;
    return _inspecciones.where((i) => i['estado'] == _filtroActivo).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Asegúrate de que el fondo sea blanco o claro
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFiltros(),
            Expanded(
              child: _inspeccionesFiltradas.isEmpty
                  ? _buildVacio()
                  : _buildLista(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco o claro para la cabecera
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AUDITORÍAS', // Título de auditorías
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  letterSpacing: 4,
                  color: Colors
                      .black, // Título en color negro para contraste en el tema claro
                ),
          ),
          GestureDetector(
            onTap: _mostrarMenuUsuario, // Acción del icono de usuario
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue, // Color del avatar de usuario
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos para el menú de usuario, filtros y listas
  void _mostrarMenuUsuario() {
    final nombre = "Nombre"; // Obtén el nombre de `widget.usuario`
    final apellidos = "Apellido"; // Obtén el apellido de `widget.usuario`
    final rol = "Jefe"; // Obtén el rol de `widget.usuario`

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
                    backgroundColor: Colors.blue,
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
                            color: Colors.black,
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
                leading: const Icon(Icons.language, color: Colors.blue),
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
                    const Icon(Icons.dark_mode_outlined, color: Colors.blue),
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

  // Métodos para filtros y listas
  Widget _buildFiltros() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filtros.length,
        itemBuilder: (context, index) {
          final filtro = _filtros[index];
          final activo = filtro == _filtroActivo;
          return GestureDetector(
            onTap: () => setState(() => _filtroActivo = filtro),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: activo ? Colors.orange : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      activo ? Colors.orange : Colors.white.withOpacity(0.07),
                ),
              ),
              child: Text(
                filtro,
                style: TextStyle(
                  color: activo ? Colors.white : Colors.black,
                  fontSize: 12,
                  fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLista() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _inspeccionesFiltradas.length,
      itemBuilder: (context, index) {
        return _buildTarjeta(_inspeccionesFiltradas[index]);
      },
    );
  }

  Widget _buildTarjeta(Map<String, String> inspeccion) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaDetalleInspeccion(inspeccion: inspeccion),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco para las tarjetas
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.07)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.checklist_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inspeccion['titulo'] ?? '',
                    style: const TextStyle(
                      color: Colors.black, // Título claro
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.black,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        inspeccion['area'] ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.black,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        inspeccion['fecha'] ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildEstadoPill(inspeccion['estado'] ?? ''),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.checklist_rounded,
            color: Colors.black,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Sin inspecciones $_filtroActivo',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoPill(String estado) {
    Color color;
    Color bg;
    switch (estado) {
      case 'Pendiente':
        color = Colors.orange;
        bg = Colors.orange.withOpacity(0.12);
        break;
      case 'Completado':
        color = Colors.green;
        bg = Colors.green.withOpacity(0.12);
        break;
      case 'En progreso':
        color = Colors.blue;
        bg = Colors.blue.withOpacity(0.12);
        break;
      case 'Por confirmar':
        color = Colors.yellow;
        bg = Colors.yellow.withOpacity(0.12);
        break;
      default:
        color = Colors.black;
        bg = Colors.grey.withOpacity(0.12);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
