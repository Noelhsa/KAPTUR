import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/datos/datasourses/api_servicios.dart';
import 'pantalla_detalle_inspecciones.dart';
import 'pantalla_generacion_reporte.dart';

class PantallaInspecciones extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onUserTap;

  const PantallaInspecciones({
    super.key,
    required this.usuario,
    required this.onUserTap,
  });

  @override
  State<PantallaInspecciones> createState() => _PantallaInspeccionesState();
}

class _PantallaInspeccionesState extends State<PantallaInspecciones> {
  final ApiService _api = ApiService();

  String _filtroActivo = 'Todos';
  bool _cargando = true;
  String? _error;

  List<Map<String, dynamic>> _auditorias = [];

  final List<String> _filtros = [
    'Todos',
    'Pendiente',
    'En revisión',
    'Aprobada',
    'Rechazada',
  ];

  @override
  void initState() {
    super.initState();
    _cargarAuditorias();
  }

  Future<void> _cargarAuditorias() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final respuesta = await _api.obtenerAuditorias();

      final idSupervisorRaw =
          widget.usuario['id_usuario'] ?? widget.usuario['id'];

      final auditoriasFiltradas = idSupervisorRaw == null
          ? respuesta
          : respuesta.where((a) {
              return a['id_supervisor']?.toString() ==
                  idSupervisorRaw.toString();
            }).toList();

      if (!mounted) return;

      setState(() {
        _auditorias = auditoriasFiltradas;
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

  List<Map<String, dynamic>> get _auditoriasFiltradas {
    if (_filtroActivo == 'Todos') return _auditorias;

    return _auditorias.where((auditoria) {
      final estado = _traducirEstado(auditoria['estado']?.toString() ?? '');
      return estado == _filtroActivo;
    }).toList();
  }

  String _traducirEstado(String estado) {
    switch (estado) {
      case 'BORRADOR':
        return 'Pendiente';
      case 'EN_REVISION':
        return 'En revisión';
      case 'APROBADA':
        return 'Aprobada';
      case 'RECHAZADA':
        return 'Rechazada';
      case 'CERRADA':
        return 'Completada';
      default:
        return estado.isEmpty ? 'Sin estado' : estado;
    }
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'Sin fecha';

    final texto = fecha.toString();

    if (texto.length >= 10) {
      return texto.substring(0, 10);
    }

    return texto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFiltros(),
            Expanded(
              child: _buildContenido(),
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
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.10)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AUDITORÍAS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  letterSpacing: 4,
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
          ),
          GestureDetector(
            onTap: widget.onUserTap,
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.navy,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      height: 54,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                color: activo ? AppColors.orange : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      activo ? AppColors.orange : Colors.grey.withOpacity(0.16),
                ),
                boxShadow: activo
                    ? [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.20),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                filtro,
                style: TextStyle(
                  color: activo ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
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

    if (_auditoriasFiltradas.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargarAuditorias,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 180),
            Icon(
              Icons.checklist_rounded,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _filtroActivo == 'Todos'
                    ? 'No hay auditorías registradas'
                    : 'No hay auditorías en estado $_filtroActivo',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarAuditorias,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        itemCount: _auditoriasFiltradas.length,
        itemBuilder: (context, index) {
          return _buildTarjeta(_auditoriasFiltradas[index]);
        },
      ),
    );
  }

  Widget _buildTarjeta(Map<String, dynamic> auditoria) {
    final id = auditoria['id_auditoria']?.toString() ?? '';
    final estadoOriginal = auditoria['estado']?.toString() ?? '';
    final estado = _traducirEstado(estadoOriginal);

    final instalacion =
        auditoria['instalacion']?.toString() ?? 'Sin instalación';
    final tipoInstalacion =
        auditoria['tipo_instalacion']?.toString() ?? 'Sin tipo';
    final parteInstalacion =
        auditoria['parte_instalacion']?.toString() ?? 'Toda la instalación';
    final fecha = _formatearFecha(auditoria['fecha_hora_inicio']);

    return GestureDetector(
      onTap: () {
        final idAuditoria = int.tryParse(id);
        if (idAuditoria == null) return;

        final folio = idAuditoria.toString().padLeft(6, '0');

        if (estadoOriginal == 'BORRADOR') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PantallaGeneracionReporte(
                idAuditoria: idAuditoria,
                folio: folio,
                usuario: widget.usuario,
              ),
            ),
          ).then((_) => _cargarAuditorias());
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PantallaDetalleInspeccion(
                idAuditoria: idAuditoria,
                folio: folio,
                usuario: widget.usuario,
              ),
            ),
          ).then((_) => _cargarAuditorias());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _colorEstado(estado),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auditoría #$id',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildInfoLinea(
                    Icons.business_outlined,
                    instalacion,
                  ),
                  const SizedBox(height: 3),
                  _buildInfoLinea(
                    Icons.category_outlined,
                    tipoInstalacion,
                  ),
                  const SizedBox(height: 3),
                  _buildInfoLinea(
                    Icons.location_on_outlined,
                    parteInstalacion,
                  ),
                  const SizedBox(height: 3),
                  _buildInfoLinea(
                    Icons.calendar_today_outlined,
                    fecha,
                  ),
                  const SizedBox(height: 8),
                  _buildEstadoPill(estado),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade500,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLinea(IconData icon, String texto) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey.shade500,
          size: 13,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
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
              _error ?? 'Error al cargar auditorías',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarAuditorias,
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

  Widget _buildEstadoPill(String estado) {
    final color = _colorEstado(estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return AppColors.orange;
      case 'En revisión':
        return AppColors.info;
      case 'Aprobada':
        return AppColors.success;
      case 'Rechazada':
        return AppColors.danger;
      case 'Completada':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
