import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';

class PantallaCapacitacion extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  final VoidCallback? onUserTap;

  const PantallaCapacitacion({
    super.key,
    this.usuario,
    this.onUserTap,
  });

  @override
  State<PantallaCapacitacion> createState() => _PantallaCapacitacionState();
}

class _PantallaCapacitacionState extends State<PantallaCapacitacion> {
  final TextEditingController _buscarController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _personas = [
    {
      'nombre': 'Juan Pérez Hernández',
      'motivo':
          'No utilizó correctamente el casco de seguridad durante la auditoría.',
      'estado': 'Pendiente',
    },
    {
      'nombre': 'María López García',
      'motivo': 'Requiere reforzar el procedimiento de bloqueo y etiquetado.',
      'estado': 'Pendiente',
    },
    {
      'nombre': 'Carlos Ramírez Torres',
      'motivo':
          'Se detectó desconocimiento en el uso adecuado del equipo de protección personal.',
      'estado': 'En proceso',
    },
    {
      'nombre': 'Ana Martínez Ruiz',
      'motivo':
          'Necesita capacitación sobre identificación de riesgos en área operativa.',
      'estado': 'Pendiente',
    },
    {
      'nombre': 'Luis Fernando Morales',
      'motivo':
          'Debe reforzar el cumplimiento de procedimientos de seguridad antes de ingresar al área de trabajo.',
      'estado': 'Pendiente',
    },
    {
      'nombre': 'Sofía Hernández Castillo',
      'motivo':
          'Presentó dudas durante la auditoría sobre el uso correcto del permiso de trabajo.',
      'estado': 'En proceso',
    },
  ];

  String _busqueda = '';

  @override
  void dispose() {
    _buscarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _personasFiltradas {
    if (_busqueda.trim().isEmpty) {
      return _personas;
    }

    return _personas.where((persona) {
      final nombre = persona['nombre']!.toLowerCase();
      final motivo = persona['motivo']!.toLowerCase();
      final busqueda = _busqueda.toLowerCase();

      return nombre.contains(busqueda) || motivo.contains(busqueda);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Column(
          children: [
            _buildEncabezado(),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 18),
                    const Text(
                      'Personas enviadas a capacitación',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Consulta el personal que requiere reforzar conocimientos o procedimientos de seguridad.',
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.65),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildBuscador(),
                    const SizedBox(height: 18),
                    _buildResumen(),
                    const SizedBox(height: 18),
                    if (_personasFiltradas.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: _buildSinResultados(),
                      )
                    else
                      ..._personasFiltradas.map((persona) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _TarjetaPersonaCapacitacion(
                            nombre: persona['nombre']!,
                            motivo: persona['motivo']!,
                            estado: persona['estado']!,
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    final nombreUsuario = widget.usuario?['nombre']?.toString() ?? 'Usuario';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'CAPACITACIONES',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.onUserTap,
            child: Row(
              children: [
                Text(
                  nombreUsuario,
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.orange,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuscador() {
    return TextField(
      controller: _buscarController,
      onChanged: (valor) {
        setState(() {
          _busqueda = valor;
        });
      },
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o motivo',
        hintStyle: TextStyle(
          color: AppColors.navy.withOpacity(0.45),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.navy.withOpacity(0.55),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResumen() {
    final total = _personas.length;
    final pendientes =
        _personas.where((persona) => persona['estado'] == 'Pendiente').length;
    final enProceso =
        _personas.where((persona) => persona['estado'] == 'En proceso').length;

    return Row(
      children: [
        Expanded(
          child: _ResumenCapacitacion(
            titulo: 'Total',
            cantidad: total.toString(),
            icono: Icons.groups_2_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ResumenCapacitacion(
            titulo: 'Pendientes',
            cantidad: pendientes.toString(),
            icono: Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ResumenCapacitacion(
            titulo: 'En proceso',
            cantidad: enProceso.toString(),
            icono: Icons.play_circle_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSinResultados() {
    return Center(
      child: Text(
        'No se encontraron personas con esa búsqueda.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.navy.withOpacity(0.6),
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ResumenCapacitacion extends StatelessWidget {
  final String titulo;
  final String cantidad;
  final IconData icono;

  const _ResumenCapacitacion({
    required this.titulo,
    required this.cantidad,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icono,
            color: AppColors.orange,
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            cantidad,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaPersonaCapacitacion extends StatelessWidget {
  final String nombre;
  final String motivo;
  final String estado;

  const _TarjetaPersonaCapacitacion({
    required this.nombre,
    required this.motivo,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final bool pendiente = estado == 'Pendiente';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.orange,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Motivo:',
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  motivo,
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.68),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: pendiente
                        ? AppColors.orange.withOpacity(0.12)
                        : Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    estado,
                    style: TextStyle(
                      color:
                          pendiente ? AppColors.orange : Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.navy.withOpacity(0.35),
            size: 16,
          ),
        ],
      ),
    );
  }
}
