import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/datos/datasourses/auditoria_completa_servicio.dart';

class PantallaGeneracionReporte extends StatefulWidget {
  final int idAuditoria;
  final String folio;
  final Map<String, dynamic> usuario;

  const PantallaGeneracionReporte({
    super.key,
    required this.idAuditoria,
    required this.folio,
    required this.usuario,
  });

  @override
  State<PantallaGeneracionReporte> createState() =>
      _PantallaGeneracionReporteState();
}

class _PantallaGeneracionReporteState extends State<PantallaGeneracionReporte> {
  final _svc = AuditoriaCompletaServicio();

  bool _cargando = true;
  bool _confirmando = false;
  Map<String, dynamic>? _detalle;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    try {
      final d = await _svc.obtenerDetalle(widget.idAuditoria);

      if (!mounted) return;

      setState(() {
        _detalle = d;
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

  Future<bool> _mostrarAdvertenciaSalida() async {
    if (_confirmando) return false;

    final salir = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Auditoría en proceso',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Al salir la información se quedará en pendientes hasta que vuelvas a terminarla y la envíes.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.navy),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Salir',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    return salir ?? false;
  }

  Future<void> _intentarSalir() async {
    final salir = await _mostrarAdvertenciaSalida();

    if (!mounted) return;

    if (salir) {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmar() async {
    setState(() => _confirmando = true);

    try {
      await _svc.confirmarAuditoria(widget.idAuditoria);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auditoría enviada al jefe para revisión'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
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
        setState(() => _confirmando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _mostrarAdvertenciaSalida,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
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
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader() {
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
            onTap: _intentarSalir,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.navy,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'GENERACIÓN DE REPORTE',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 2,
                    color: AppColors.navy,
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

  // ── Contenido ─────────────────────────────────────────────

  Widget _buildContenido() {
    final cab = _detalle!['cabecera'] as Map<String, dynamic>;
    final resumenPersonas =
        Map<String, dynamic>.from(_detalle!['resumen_personas'] ?? {});
    final totalPersonas = _valorEntero(
      resumenPersonas['total_personas_observadas'] ??
          cab['total_personas_observadas'],
    );
    final personas =
        (_detalle!['personas'] as List).cast<Map<String, dynamic>>();
    final totalPersonasMostrado =
        totalPersonas > 0 ? totalPersonas : personas.length;
    final actos = (_detalle!['actos'] as List).cast<Map<String, dynamic>>();
    final evidencias =
        (_detalle!['evidencias'] as List).cast<Map<String, dynamic>>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Aviso ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Revisa el resumen antes de enviar al jefe. '
                    'Una vez confirmado no podrás editarlo.',
                    style: TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Cabecera ───────────────────────────────────────
          _seccion('Auditoría', [
            _fila('Instalación', cab['instalacion']?.toString() ?? '—'),
            _fila('Tipo', cab['tipo_instalacion']?.toString() ?? '—'),
            _fila('Área', cab['area']?.toString() ?? '—'),
            _fila('Supervisor', cab['supervisor']?.toString() ?? '—'),
            _fila('Fecha inicio', _formatFecha(cab['fecha_hora_inicio'])),
            _fila(
              'PT Obtenido',
              (cab['pt_obtenido'] == true || cab['pt_obtenido'] == 1)
                  ? 'Sí'
                  : 'No',
            ),
            _fila(
              'PT Vigente',
              (cab['pt_vigente'] == true || cab['pt_vigente'] == 1)
                  ? 'Sí'
                  : 'No',
            ),
            if ((cab['observaciones_generales'] ?? '').toString().isNotEmpty)
              _fila('Observaciones', cab['observaciones_generales'].toString()),
          ]),
          const SizedBox(height: 16),

          // ── Personas ───────────────────────────────────────
          _seccion(
            'Resumen generado',
            _buildResumenGenerado(resumenPersonas, cab, actos),
          ),
          const SizedBox(height: 16),

          _seccion(
            'Personas observadas ($totalPersonasMostrado)',
            personas.isEmpty
                ? [
                    Text(
                      totalPersonas > 0
                          ? 'Registro por conteo, sin nombres individuales.'
                          : 'Sin personas observadas registradas',
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 13),
                    )
                  ]
                : personas.map((p) => _chipPersona(p)).toList(),
          ),
          const SizedBox(height: 16),

          // ── Actos inseguros ────────────────────────────────
          _seccion(
            'Actos inseguros (${actos.length})',
            actos.isEmpty
                ? [
                    const Text(
                      'No se registraron actos inseguros en esta auditorÃ­a',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    )
                  ]
                : actos.map((a) => _chipActo(a)).toList(),
          ),
          const SizedBox(height: 16),

          // ── Evidencias ─────────────────────────────────────
          _seccion(
            'Evidencias (${evidencias.length})',
            evidencias.isEmpty
                ? [
                    const Text(
                      'Sin evidencias',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    )
                  ]
                : evidencias.map((e) => _chipEvidencia(e)).toList(),
          ),
          const SizedBox(height: 28),

          // ── Botones ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _confirmando ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.navy),
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _confirmando ? null : _confirmar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _confirmando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'CONFIRMAR Y ENVIAR AL JEFE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Widgets de resumen ────────────────────────────────────

  Widget _seccion(String titulo, List<Widget> hijos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...hijos,
        ],
      ),
    );
  }

  Widget _fila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResumenGenerado(
    Map<String, dynamic> resumen,
    Map<String, dynamic> cabecera,
    List<Map<String, dynamic>> actos,
  ) {
    final total = _valorEntero(
      resumen['total_personas_observadas'] ??
          cabecera['total_personas_observadas'],
    );
    final internas = _valorEntero(
      resumen['personas_internas_total'] ?? cabecera['personas_internas_total'],
    );
    final externas = _valorEntero(
      resumen['personas_externas_total'] ?? cabecera['personas_externas_total'],
    );
    final segurasInternas = _valorEntero(
      resumen['personas_seguras_internas'] ??
          cabecera['personas_seguras_internas'],
    );
    final segurasExternas = _valorEntero(
      resumen['personas_seguras_externas'] ??
          cabecera['personas_seguras_externas'],
    );
    final insegurasInternas = _valorEntero(
      resumen['personas_inseguras_internas'] ??
          cabecera['personas_inseguras_internas'],
    );
    final insegurasExternas = _valorEntero(
      resumen['personas_inseguras_externas'] ??
          cabecera['personas_inseguras_externas'],
    );
    final totalSeguras = _valorEntero(resumen['total_personas_seguras']) +
        (resumen['total_personas_seguras'] == null
            ? segurasInternas + segurasExternas
            : 0);
    final totalInseguras = _valorEntero(resumen['total_personas_inseguras']) +
        (resumen['total_personas_inseguras'] == null
            ? insegurasInternas + insegurasExternas
            : 0);
    final iai = _valorDecimal(
      resumen['iai'] ??
          cabecera['indice_actos_inseguros'] ??
          _calcularIai(total, actos),
    );
    final ias = _valorDecimal(
      resumen['ias'] ?? cabecera['indice_actos_seguros'] ?? (100 - iai),
    );

    return [
      _fila('Observadas', total.toString()),
      _fila('Internas', internas.toString()),
      _fila('Externas', externas.toString()),
      _fila('Seguras internas', segurasInternas.toString()),
      _fila('Seguras externas', segurasExternas.toString()),
      _fila('Inseguras internas', insegurasInternas.toString()),
      _fila('Inseguras externas', insegurasExternas.toString()),
      const Divider(height: 18),
      _fila('Total seguras', totalSeguras.toString()),
      _fila('Total inseguras', totalInseguras.toString()),
      _fila('IAI', iai.toStringAsFixed(4)),
      _fila('IAS', ias.toStringAsFixed(4)),
    ];
  }

  Widget _chipPersona(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${p['nombre']} ${p['apellidos']}',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _badge(p['tipo_persona']?.toString() ?? '', AppColors.navy),
              const SizedBox(width: 6),
              _badge(
                p['clasificacion_persona']?.toString() ?? '',
                p['clasificacion_persona'] == 'SEGURA'
                    ? AppColors.success
                    : AppColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipActo(Map<String, dynamic> a) {
    final sev = a['nivel_severidad']?.toString() ?? '';
    Color sevColor = sev == 'ALTO'
        ? AppColors.danger
        : sev == 'MEDIO'
            ? AppColors.warning
            : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            a['opcion_acto']?.toString() ?? '—',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            a['tipo_acto']?.toString() ?? '',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _badge(sev, sevColor),
              const SizedBox(width: 6),
              Text(
                '${a['cantidad_personas']} persona(s)',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
              if (a['corregido_en_el_acto'] == true ||
                  a['corregido_en_el_acto'] == 1) ...[
                const SizedBox(width: 6),
                _badge('Corregido', AppColors.success),
              ],
            ],
          ),
          if ((a['causa'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Causa: ${a['causa']}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
          if ((a['nombre_persona_actor'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Persona: ${a['nombre_persona_actor']} (${a['tipo_persona_actor'] ?? '—'})',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chipEvidencia(Map<String, dynamic> e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file, color: Colors.grey.shade500, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e['tipo_archivo']?.toString() ?? 'Archivo',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if ((e['descripcion'] ?? '').toString().isNotEmpty)
                  Text(
                    e['descripcion'].toString(),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String texto, Color color) {
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
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarDetalle,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFecha(dynamic fecha) {
    if (fecha == null) return '—';
    final s = fecha.toString();
    return s.length >= 16 ? s.substring(0, 16).replaceAll('T', ' ') : s;
  }

  int _valorEntero(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }

  double _valorDecimal(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString() ?? '') ?? 0;
  }

  double _calcularIai(int totalPersonas, List<Map<String, dynamic>> actos) {
    if (totalPersonas <= 0) return 0;
    final totalPonderado = actos.fold<double>(0, (total, acto) {
      final cantidad = _valorDecimal(acto['cantidad_personas']);
      final factor = _valorDecimal(acto['factor_severidad']);
      return total + (cantidad * factor);
    });
    return (totalPonderado / totalPersonas) * 100;
  }
}
