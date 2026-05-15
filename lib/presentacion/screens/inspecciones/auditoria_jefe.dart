import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/datos/datasourses/api_servicios.dart';

class AuditoriaJefe extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback? onUserTap;

  const AuditoriaJefe({
    super.key,
    required this.usuario,
    this.onUserTap,
  });

  @override
  State<AuditoriaJefe> createState() => _AuditoriaJefeState();
}

class _AuditoriaJefeState extends State<AuditoriaJefe> {
  final ApiService _api = ApiService();

  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _auditorias = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final idJefeRaw = widget.usuario['id_usuario'];

      if (idJefeRaw == null) {
        throw Exception('No se encontró el ID del jefe');
      }

      final idJefe = int.parse(idJefeRaw.toString());

      final auditorias = await _api.obtenerHistorialAuditoriasJefe(idJefe);

      if (!mounted) return;

      setState(() {
        _auditorias = auditorias;
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

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'Sin fecha';

    final texto = fecha.toString();

    if (texto.length >= 16) {
      return texto.substring(0, 16).replaceAll('T', ' ');
    }

    if (texto.length >= 10) {
      return texto.substring(0, 10);
    }

    return texto;
  }

  String _traducirEstado(String estado) {
    switch (estado) {
      case 'BORRADOR':
        return 'Borrador';
      case 'CERRADA':
        return 'Cerrada';
      case 'EN_REVISION':
        return 'En revisión';
      case 'APROBADA':
        return 'Aprobada';
      case 'RECHAZADA':
        return 'Rechazada';
      default:
        return estado;
    }
  }

  bool _esSi(dynamic valor) {
    return valor == true || valor == 1 || valor.toString() == '1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
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
          bottom: BorderSide(color: Colors.grey.withOpacity(0.12)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'HISTORIAL DE AUDITORÍAS',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.8,
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: widget.onUserTap,
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.navy,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarHistorial,
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

    if (_auditorias.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargarHistorial,
        child: ListView(
          children: [
            const SizedBox(height: 180),
            Icon(
              Icons.history_rounded,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'No hay auditorías aprobadas en el historial',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarHistorial,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _auditorias.length,
        itemBuilder: (context, index) {
          return _buildTarjetaHistorial(_auditorias[index]);
        },
      ),
    );
  }

  Widget _buildTarjetaHistorial(Map<String, dynamic> auditoria) {
    final id = auditoria['id_auditoria']?.toString() ?? '';
    final instalacion =
        auditoria['instalacion']?.toString() ?? 'Sin instalación';
    final tipoInstalacion =
        auditoria['tipo_instalacion']?.toString() ?? 'Sin tipo';
    final parteInstalacion =
        auditoria['parte_instalacion']?.toString() ?? 'Sin parte';
    final supervisor = auditoria['supervisor']?.toString() ?? 'Sin supervisor';
    final jefe = auditoria['jefe']?.toString() ?? 'Sin jefe';
    final estado = auditoria['estado']?.toString() ?? '';
    final fechaInicio = _formatearFecha(auditoria['fecha_hora_inicio']);
    final fechaFin = _formatearFecha(auditoria['fecha_hora_fin']);
    final fechaAprobacion = _formatearFecha(auditoria['fecha_hora_aprobacion']);
    final observaciones =
        auditoria['observaciones_generales']?.toString() ?? 'Sin observaciones';
    final comentario =
        auditoria['comentario']?.toString() ?? 'Sin comentario del jefe';

    final ptObtenido = _esSi(auditoria['pt_obtenido']) ? 'Sí' : 'No';
    final ptVigente = _esSi(auditoria['pt_vigente']) ? 'Sí' : 'No';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Auditoría #$id',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildEstadoPill(estado),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfo(Icons.business_outlined, instalacion),
          _buildInfo(Icons.category_outlined, tipoInstalacion),
          _buildInfo(Icons.location_on_outlined, parteInstalacion),
          _buildInfo(Icons.person_outline, 'Supervisor: $supervisor'),
          _buildInfo(Icons.verified_user_outlined, 'Aprobó: $jefe'),
          _buildInfo(Icons.calendar_today_outlined, 'Inicio: $fechaInicio'),
          _buildInfo(Icons.event_available_outlined, 'Fin: $fechaFin'),
          _buildInfo(
            Icons.check_circle_outline,
            'Aprobación: $fechaAprobacion',
          ),
          _buildInfo(
            Icons.assignment_turned_in_outlined,
            'PT obtenido: $ptObtenido · PT vigente: $ptVigente',
          ),
          const SizedBox(height: 10),
          const Text(
            'Observaciones generales:',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            observaciones,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Comentario del jefe:',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comentario,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade500,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
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
      case 'APROBADA':
        color = AppColors.success;
        bg = AppColors.success.withOpacity(0.12);
        break;
      case 'RECHAZADA':
        color = AppColors.danger;
        bg = AppColors.danger.withOpacity(0.12);
        break;
      case 'EN_REVISION':
        color = AppColors.info;
        bg = AppColors.info.withOpacity(0.12);
        break;
      case 'CERRADA':
        color = AppColors.warning;
        bg = AppColors.warning.withOpacity(0.12);
        break;
      case 'BORRADOR':
        color = AppColors.orange;
        bg = AppColors.orange.withOpacity(0.12);
        break;
      default:
        color = Colors.grey.shade700;
        bg = Colors.grey.withOpacity(0.12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _traducirEstado(estado),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
