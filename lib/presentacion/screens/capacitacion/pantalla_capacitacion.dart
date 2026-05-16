import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/datos/datasourses/api_servicios.dart';

class PantallaCapacitacion extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onUserTap;

  const PantallaCapacitacion({
    super.key,
    required this.usuario,
    required this.onUserTap,
  });

  @override
  State<PantallaCapacitacion> createState() => _PantallaCapacitacionState();
}

class _PantallaCapacitacionState extends State<PantallaCapacitacion> {
  final ApiService _api = ApiService();
  final TextEditingController _buscarController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _cargando = true;
  bool _actualizandoEstado = false;
  String? _error;
  String _busqueda = '';

  List<Map<String, dynamic>> _personas = [];

  @override
  void initState() {
    super.initState();
    _cargarCapacitacion();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int? get _idSupervisor {
    final idRaw = widget.usuario['id_usuario'] ?? widget.usuario['id'];

    if (idRaw == null) return null;

    return int.tryParse(idRaw.toString());
  }

  Future<void> _cargarCapacitacion() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final idSupervisor = _idSupervisor;

      if (idSupervisor == null) {
        throw Exception('No se encontró el ID del supervisor');
      }

      final personas =
          await _api.obtenerPersonasCapacitacionSupervisor(idSupervisor);

      if (!mounted) return;

      setState(() {
        _personas = personas;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _cargando = false;
      });
    }
  }

  List<Map<String, dynamic>> get _personasFiltradas {
    if (_busqueda.trim().isEmpty) {
      return _personas;
    }

    final busqueda = _busqueda.toLowerCase();

    return _personas.where((persona) {
      final nombre = '${persona['nombre'] ?? ''} ${persona['apellidos'] ?? ''}'
          .toLowerCase();
      final motivo = (persona['motivo'] ?? '').toString().toLowerCase();
      final estado =
          _estadoTexto(persona['estado']?.toString() ?? '').toLowerCase();
      final auditoria =
          'auditoría ${persona['id_auditoria'] ?? ''}'.toLowerCase();

      return nombre.contains(busqueda) ||
          motivo.contains(busqueda) ||
          estado.contains(busqueda) ||
          auditoria.contains(busqueda);
    }).toList();
  }

  int get _total => _personas.length;

  int get _pendientes =>
      _personas.where((p) => p['estado']?.toString() == 'PENDIENTE').length;

  int get _enProceso =>
      _personas.where((p) => p['estado']?.toString() == 'EN_PROCESO').length;

  int get _completados =>
      _personas.where((p) => p['estado']?.toString() == 'COMPLETADO').length;

  Future<void> _mostrarCambioEstado(Map<String, dynamic> persona) async {
    if (_actualizandoEstado) return;

    final estadoActual = persona['estado']?.toString() ?? 'PENDIENTE';

    final nuevoEstado = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
              const SizedBox(height: 22),
              const Text(
                'Cambiar estado',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Selecciona el avance de capacitación de esta persona.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              _buildOpcionEstado(
                context: context,
                titulo: 'Pendiente',
                estado: 'PENDIENTE',
                estadoActual: estadoActual,
                icono: Icons.schedule_rounded,
                color: AppColors.orange,
              ),
              _buildOpcionEstado(
                context: context,
                titulo: 'En proceso',
                estado: 'EN_PROCESO',
                estadoActual: estadoActual,
                icono: Icons.play_circle_outline_rounded,
                color: AppColors.info,
              ),
              _buildOpcionEstado(
                context: context,
                titulo: 'Completado',
                estado: 'COMPLETADO',
                estadoActual: estadoActual,
                icono: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ],
          ),
        );
      },
    );

    if (nuevoEstado == null || nuevoEstado == estadoActual) return;

    await _actualizarEstado(persona, nuevoEstado);
  }

  Widget _buildOpcionEstado({
    required BuildContext context,
    required String titulo,
    required String estado,
    required String estadoActual,
    required IconData icono,
    required Color color,
  }) {
    final seleccionado = estado == estadoActual;

    return GestureDetector(
      onTap: () => Navigator.pop(context, estado),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionado ? color.withOpacity(0.10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                seleccionado ? color.withOpacity(0.35) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icono,
                color: color,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (seleccionado)
              Icon(
                Icons.check_rounded,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _actualizarEstado(
    Map<String, dynamic> persona,
    String nuevoEstado,
  ) async {
    final idCapacitacionRaw = persona['id_capacitacion'];
    final idCapacitacion = int.tryParse(idCapacitacionRaw.toString());

    if (idCapacitacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el ID de capacitación'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _actualizandoEstado = true);

    try {
      await _api.actualizarEstadoCapacitacion(
        idCapacitacion: idCapacitacion,
        estado: nuevoEstado,
        observaciones: persona['observaciones']?.toString(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a ${_estadoTexto(nuevoEstado)}'),
          backgroundColor: _colorEstado(nuevoEstado),
        ),
      );

      await _cargarCapacitacion();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _actualizandoEstado = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Column(
          children: [
            _buildEncabezado(context),
            Expanded(
              child: _buildContenido(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    return RefreshIndicator(
      onRefresh: _cargarCapacitacion,
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
              'Consulta el personal clasificado como inseguro durante las auditorías y da seguimiento a su capacitación.',
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
            if (_personas.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: _buildSinDatos(),
              )
            else if (_personasFiltradas.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: _buildSinResultados(),
              )
            else
              ..._personasFiltradas.map((persona) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _TarjetaPersonaCapacitacion(
                    persona: persona,
                    onTap: () => _mostrarCambioEstado(persona),
                    estadoTexto: _estadoTexto(
                      persona['estado']?.toString() ?? 'PENDIENTE',
                    ),
                    estadoColor: _colorEstado(
                      persona['estado']?.toString() ?? 'PENDIENTE',
                    ),
                    fechaTexto: _formatFecha(persona['fecha_asignacion']),
                  ),
                );
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezado(BuildContext context) {
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
              'CAPACITACIÓN',
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
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
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
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 14,
      ),
      cursorColor: AppColors.orange,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, motivo, estado o auditoría',
        hintStyle: TextStyle(
          color: AppColors.navy.withOpacity(0.45),
          fontSize: 13,
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ResumenCapacitacion(
                titulo: 'Total',
                cantidad: _total.toString(),
                icono: Icons.groups_2_outlined,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ResumenCapacitacion(
                titulo: 'Pendientes',
                cantidad: _pendientes.toString(),
                icono: Icons.schedule_rounded,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ResumenCapacitacion(
                titulo: 'En proceso',
                cantidad: _enProceso.toString(),
                icono: Icons.play_circle_outline_rounded,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ResumenCapacitacion(
                titulo: 'Completados',
                cantidad: _completados.toString(),
                icono: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSinDatos() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            color: AppColors.navy.withOpacity(0.25),
            size: 52,
          ),
          const SizedBox(height: 12),
          Text(
            'No hay personas enviadas a capacitación.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.62),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando una auditoría tenga personas clasificadas como inseguras, aparecerán aquí automáticamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.45),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
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

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.danger,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Error al cargar capacitación',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy.withOpacity(0.65),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarCapacitacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  String _estadoTexto(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'EN_PROCESO':
        return 'En proceso';
      case 'COMPLETADO':
        return 'Completado';
      default:
        return estado;
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return AppColors.orange;
      case 'EN_PROCESO':
        return AppColors.info;
      case 'COMPLETADO':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  String _formatFecha(dynamic fecha) {
    if (fecha == null) return 'Sin fecha';

    final texto = fecha.toString();

    if (texto.length >= 10) {
      return texto.substring(0, 10);
    }

    return texto;
  }
}

class _ResumenCapacitacion extends StatelessWidget {
  final String titulo;
  final String cantidad;
  final IconData icono;
  final Color color;

  const _ResumenCapacitacion({
    required this.titulo,
    required this.cantidad,
    required this.icono,
    required this.color,
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
            color: color,
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            cantidad,
            style: TextStyle(
              color: color,
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
  final Map<String, dynamic> persona;
  final VoidCallback onTap;
  final String estadoTexto;
  final Color estadoColor;
  final String fechaTexto;

  const _TarjetaPersonaCapacitacion({
    required this.persona,
    required this.onTap,
    required this.estadoTexto,
    required this.estadoColor,
    required this.fechaTexto,
  });

  @override
  Widget build(BuildContext context) {
    final nombreCompleto =
        '${persona['nombre'] ?? ''} ${persona['apellidos'] ?? ''}'.trim();

    final motivo = (persona['motivo'] ?? 'Sin motivo registrado').toString();
    final idAuditoria = persona['id_auditoria']?.toString() ?? '—';
    final instalacion = persona['instalacion']?.toString() ?? 'Sin instalación';
    final area =
        persona['parte_instalacion']?.toString() ?? 'Toda la instalación';

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: estadoColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person_add_alt_1_rounded,
                color: estadoColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreCompleto.isEmpty
                        ? 'Persona sin nombre'
                        : nombreCompleto,
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
                  const SizedBox(height: 10),
                  _infoLinea(
                    Icons.fact_check_outlined,
                    'Auditoría #$idAuditoria',
                  ),
                  const SizedBox(height: 4),
                  _infoLinea(
                    Icons.business_outlined,
                    instalacion,
                  ),
                  const SizedBox(height: 4),
                  _infoLinea(
                    Icons.location_on_outlined,
                    area,
                  ),
                  const SizedBox(height: 4),
                  _infoLinea(
                    Icons.calendar_today_outlined,
                    'Asignado: $fechaTexto',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      estadoTexto,
                      style: TextStyle(
                        color: estadoColor,
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
              Icons.edit_rounded,
              color: AppColors.navy.withOpacity(0.35),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoLinea(IconData icon, String texto) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.navy.withOpacity(0.42),
          size: 13,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.56),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
