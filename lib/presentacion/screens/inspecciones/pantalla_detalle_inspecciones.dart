import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/datos/datasourses/auditoria_completa_servicio.dart';

class PantallaDetalleInspeccion extends StatefulWidget {
  final int idAuditoria;
  final String folio;
  final Map<String, dynamic> usuario;

  const PantallaDetalleInspeccion({
    super.key,
    required this.idAuditoria,
    required this.folio,
    required this.usuario,
  });

  @override
  State<PantallaDetalleInspeccion> createState() =>
      _PantallaDetalleInspeccionState();
}

class _PantallaDetalleInspeccionState extends State<PantallaDetalleInspeccion> {
  final AuditoriaCompletaServicio _svc = AuditoriaCompletaServicio();

  bool _cargando = true;
  String? _error;
  Map<String, dynamic>? _detalle;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final detalle = await _svc.obtenerDetalle(widget.idAuditoria);

      if (!mounted) return;

      setState(() {
        _detalle = detalle;
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

  String _urlEvidencia(String ruta) {
    if (ruta.startsWith('http')) {
      return ruta;
    }

    if (ruta.startsWith('/')) {
      return 'https://api.kaptur.online$ruta';
    }

    return 'https://api.kaptur.online/$ruta';
  }

  bool _esImagen(String ruta) {
    final r = ruta.toLowerCase();

    return r.endsWith('.jpg') ||
        r.endsWith('.jpeg') ||
        r.endsWith('.png') ||
        r.endsWith('.webp');
  }

  void _abrirEvidencia(Map<String, dynamic> evidencia) {
    final ruta = evidencia['ruta_archivo']?.toString() ?? '';

    if (ruta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta evidencia no tiene archivo asociado'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (!_esImagen(ruta)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por ahora solo se pueden visualizar imágenes'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final url = _urlEvidencia(ruta);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PantallaVistaEvidencia(
          url: url,
          titulo: evidencia['tipo_archivo']?.toString() ?? 'Evidencia',
          descripcion: evidencia['descripcion']?.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : _buildContenido(),
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.navy,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'DETALLE DE AUDITORÍA',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.navy,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.navy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Folio #${widget.folio}',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenido() {
    final cabecera = Map<String, dynamic>.from(_detalle?['cabecera'] ?? {});

    final personas =
        (_detalle?['personas'] as List? ?? []).cast<Map<String, dynamic>>();

    final actos =
        (_detalle?['actos'] as List? ?? []).cast<Map<String, dynamic>>();

    final evidencias =
        (_detalle?['evidencias'] as List? ?? []).cast<Map<String, dynamic>>();

    final aprobacionRaw = _detalle?['aprobacion'];
    final Map<String, dynamic>? aprobacion =
        aprobacionRaw == null ? null : Map<String, dynamic>.from(aprobacionRaw);

    final estado = cabecera['estado']?.toString() ?? '';

    return RefreshIndicator(
      onRefresh: _cargarDetalle,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEstadoPrincipal(estado, aprobacion),
            const SizedBox(height: 16),
            _buildSeccionAuditoria(cabecera),
            const SizedBox(height: 16),
            _buildSeccionPersonas(personas),
            const SizedBox(height: 16),
            _buildSeccionActos(actos),
            const SizedBox(height: 16),
            _buildSeccionEvidencias(evidencias),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoPrincipal(
    String estado,
    Map<String, dynamic>? aprobacion,
  ) {
    final estadoTexto = _traducirEstado(estado);
    final color = _colorEstado(estado);

    String titulo;
    String descripcion;
    IconData icono;

    if (estado == 'RECHAZADA') {
      titulo = 'Auditoría rechazada';
      descripcion =
          'El jefe revisó esta auditoría y dejó un comentario para su seguimiento.';
      icono = Icons.cancel_outlined;
    } else if (estado == 'APROBADA') {
      titulo = 'Auditoría aprobada';
      descripcion =
          'Esta auditoría fue revisada y aprobada por el jefe de seguridad.';
      icono = Icons.check_circle_outline;
    } else if (estado == 'EN_REVISION') {
      titulo = 'Auditoría en revisión';
      descripcion =
          'La auditoría fue enviada al jefe y está esperando una respuesta.';
      icono = Icons.rate_review_outlined;
    } else if (estado == 'BORRADOR') {
      titulo = 'Auditoría pendiente';
      descripcion =
          'Esta auditoría todavía no ha sido enviada al jefe de seguridad.';
      icono = Icons.pending_actions_outlined;
    } else {
      titulo = 'Auditoría';
      descripcion = 'Información general de la auditoría seleccionada.';
      icono = Icons.fact_check_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.22)),
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
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icono,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _buildEstadoPill(estadoTexto, color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            descripcion,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          if (aprobacion != null) ...[
            const SizedBox(height: 14),
            Divider(color: color.withOpacity(0.22)),
            const SizedBox(height: 8),
            _buildInfoLinea(
              Icons.verified_user_outlined,
              'Jefe: ${aprobacion['jefe']?.toString() ?? '—'}',
            ),
            const SizedBox(height: 5),
            _buildInfoLinea(
              Icons.event_available_outlined,
              'Fecha de revisión: ${_formatFecha(aprobacion['fecha_hora_aprobacion'])}',
            ),
            if ((aprobacion['comentario'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Comentario del jefe:',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                aprobacion['comentario'].toString(),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSeccionAuditoria(Map<String, dynamic> cabecera) {
    return _buildTarjeta(
      titulo: 'Auditoría',
      children: [
        _buildFila('Instalación', cabecera['instalacion']?.toString() ?? '—'),
        _buildFila('Tipo', cabecera['tipo_instalacion']?.toString() ?? '—'),
        _buildFila('Área', cabecera['area']?.toString() ?? '—'),
        _buildFila('Supervisor', cabecera['supervisor']?.toString() ?? '—'),
        _buildFila('Fecha inicio', _formatFecha(cabecera['fecha_hora_inicio'])),
        _buildFila('Fecha fin', _formatFecha(cabecera['fecha_hora_fin'])),
        _buildFila(
          'PT obtenido',
          _valorSiNo(cabecera['pt_obtenido']),
        ),
        _buildFila(
          'PT vigente',
          _valorSiNo(cabecera['pt_vigente']),
        ),
        if ((cabecera['observaciones_generales'] ?? '').toString().isNotEmpty)
          _buildFila(
            'Observaciones',
            cabecera['observaciones_generales'].toString(),
          ),
      ],
    );
  }

  Widget _buildSeccionPersonas(List<Map<String, dynamic>> personas) {
    return _buildTarjeta(
      titulo: 'Personas observadas (${personas.length})',
      children: personas.isEmpty
          ? [
              Text(
                'Sin personas registradas',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ]
          : personas.map((persona) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${persona['nombre'] ?? ''} ${persona['apellidos'] ?? ''}'
                          .trim(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildBadge(
                          persona['tipo_persona']?.toString() ?? '—',
                          AppColors.navy,
                        ),
                        _buildBadge(
                          persona['clasificacion_persona']?.toString() ?? '—',
                          persona['clasificacion_persona'] == 'SEGURA'
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ],
                    ),
                    if ((persona['observaciones'] ?? '')
                        .toString()
                        .isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        persona['observaciones'].toString(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
    );
  }

  Widget _buildSeccionActos(List<Map<String, dynamic>> actos) {
    return _buildTarjeta(
      titulo: 'Actos inseguros (${actos.length})',
      children: actos.isEmpty
          ? [
              Text(
                'Sin actos registrados',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ]
          : actos.map((acto) {
              final severidad = acto['nivel_severidad']?.toString() ?? '—';
              final severidadColor = _colorSeveridad(severidad);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      acto['opcion_acto']?.toString() ?? '—',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      acto['tipo_acto']?.toString() ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildBadge(severidad, severidadColor),
                        _buildBadge(
                          '${acto['cantidad_personas'] ?? 0} persona(s)',
                          AppColors.navy,
                        ),
                        if (acto['corregido_en_el_acto'] == true ||
                            acto['corregido_en_el_acto'] == 1)
                          _buildBadge('Corregido', AppColors.success),
                      ],
                    ),
                    if ((acto['causa'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        'Causa: ${acto['causa']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if ((acto['descripcion_adicional'] ?? '')
                        .toString()
                        .isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        acto['descripcion_adicional'].toString(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
    );
  }

  Widget _buildSeccionEvidencias(List<Map<String, dynamic>> evidencias) {
    return _buildTarjeta(
      titulo: 'Evidencias (${evidencias.length})',
      children: evidencias.isEmpty
          ? [
              Text(
                'Sin evidencias',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ]
          : evidencias.map((evidencia) {
              final ruta = evidencia['ruta_archivo']?.toString() ?? '';
              final descripcion = evidencia['descripcion']?.toString() ?? '';
              final tipo = evidencia['tipo_archivo']?.toString() ?? 'Archivo';
              final esImagen = _esImagen(ruta);

              return GestureDetector(
                onTap: () => _abrirEvidencia(evidencia),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        esImagen
                            ? Icons.image_outlined
                            : Icons.attach_file_outlined,
                        color: AppColors.navy,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tipo,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (descripcion.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                descripcion,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            if (ruta.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                ruta,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                            if (esImagen) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Toca para ver imagen',
                                style: TextStyle(
                                  color: AppColors.navy.withOpacity(0.75),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade500,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
    );
  }

  Widget _buildTarjeta({
    required String titulo,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLinea(IconData icon, String texto) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey.shade600,
          size: 15,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoPill(String estado, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBadge(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
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
              _error ?? 'Error al cargar detalle de auditoría',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarDetalle,
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

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'BORRADOR':
        return AppColors.orange;
      case 'EN_REVISION':
        return AppColors.info;
      case 'APROBADA':
        return AppColors.success;
      case 'RECHAZADA':
        return AppColors.danger;
      case 'CERRADA':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _colorSeveridad(String severidad) {
    switch (severidad) {
      case 'ALTO':
        return AppColors.danger;
      case 'MEDIO':
        return AppColors.warning;
      case 'BAJO':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  String _valorSiNo(dynamic valor) {
    if (valor == true || valor == 1 || valor.toString() == '1') {
      return 'Sí';
    }
    return 'No';
  }

  String _formatFecha(dynamic fecha) {
    if (fecha == null) return '—';

    final texto = fecha.toString();

    if (texto.length >= 16) {
      return texto.substring(0, 16).replaceAll('T', ' ');
    }

    if (texto.length >= 10) {
      return texto.substring(0, 10);
    }

    return texto;
  }
}

class _PantallaVistaEvidencia extends StatelessWidget {
  final String url;
  final String titulo;
  final String? descripcion;

  const _PantallaVistaEvidencia({
    required this.url,
    required this.titulo,
    this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (descripcion != null && descripcion!.trim().isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: Colors.black,
                child: Text(
                  descripcion!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white70,
                              size: 54,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No se pudo cargar la imagen',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              url,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
