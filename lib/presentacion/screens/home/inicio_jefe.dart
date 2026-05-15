import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/datos/datasourses/api_servicios.dart';

class InicioJefe extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback? onUserTap;

  const InicioJefe({
    super.key,
    required this.usuario,
    this.onUserTap,
  });

  @override
  State<InicioJefe> createState() => _InicioJefeState();
}

class _InicioJefeState extends State<InicioJefe> {
  final ApiService _api = ApiService();

  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _auditorias = [];

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
      final auditorias = await _api.obtenerAuditoriasJefe();

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

  Future<void> _confirmarDecision({
    required Map<String, dynamic> auditoria,
    required bool aprobado,
  }) async {
    final comentarioController = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            aprobado ? 'Aprobar auditoría' : 'Rechazar auditoría',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                aprobado
                    ? '¿Seguro que deseas aprobar esta auditoría?'
                    : '¿Seguro que deseas rechazar esta auditoría?',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: comentarioController,
                maxLines: 3,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Comentario opcional',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.navy),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    aprobado ? AppColors.success : AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(aprobado ? 'Aprobar' : 'Rechazar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    await _enviarDecision(
      auditoria: auditoria,
      aprobado: aprobado,
      comentario: comentarioController.text.trim().isEmpty
          ? null
          : comentarioController.text.trim(),
    );
  }

  Future<void> _enviarDecision({
    required Map<String, dynamic> auditoria,
    required bool aprobado,
    String? comentario,
  }) async {
    final idAuditoria = auditoria['id_auditoria'];
    final idJefe = widget.usuario['id_usuario'];

    if (idAuditoria == null || idJefe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el ID de auditoría o del jefe'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    try {
      await _api.aprobarAuditoria(
        idAuditoria: int.parse(idAuditoria.toString()),
        idJefe: int.parse(idJefe.toString()),
        aprobado: aprobado,
        comentario: comentario,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: aprobado ? AppColors.success : AppColors.danger,
          content: Text(
            aprobado
                ? 'Auditoría aprobada correctamente'
                : 'Auditoría rechazada correctamente',
          ),
        ),
      );

      await _cargarAuditorias();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ),
      );
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

    if (_auditorias.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargarAuditorias,
        child: ListView(
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
                'No hay auditorías disponibles',
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
      onRefresh: _cargarAuditorias,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _auditorias.length,
        itemBuilder: (context, index) {
          return _buildTarjetaAuditoria(_auditorias[index]);
        },
      ),
    );
  }

  Widget _buildTarjetaAuditoria(Map<String, dynamic> auditoria) {
    final id = auditoria['id_auditoria']?.toString() ?? '';
    final instalacion =
        auditoria['instalacion']?.toString() ?? 'Sin instalación';
    final tipoInstalacion =
        auditoria['tipo_instalacion']?.toString() ?? 'Sin tipo';
    final parteInstalacion =
        auditoria['parte_instalacion']?.toString() ?? 'Sin parte';
    final supervisor = auditoria['supervisor']?.toString() ?? 'Sin supervisor';
    final estado = auditoria['estado']?.toString() ?? '';
    final fecha = _formatearFecha(auditoria['fecha_hora_inicio']);
    final observaciones =
        auditoria['observaciones_generales']?.toString() ?? 'Sin observaciones';

    final puedeDecidir = estado != 'APROBADA' && estado != 'RECHAZADA';

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
                  Icons.fact_check_outlined,
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
          _buildInfo(Icons.person_outline, supervisor),
          _buildInfo(Icons.calendar_today_outlined, fecha),
          const SizedBox(height: 8),
          Text(
            observaciones,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          if (puedeDecidir) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmarDecision(
                      auditoria: auditoria,
                      aprobado: false,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(0, 42),
                    ),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmarDecision(
                      auditoria: auditoria,
                      aprobado: true,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(0, 42),
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Aprobar'),
                  ),
                ),
              ],
            ),
          ],
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
