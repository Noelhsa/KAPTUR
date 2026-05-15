// lib/presentacion/screens/inspecciones/pantalla_nueva_inspecciones.dart
//
// CAMBIOS RESPECTO A LA VERSIÓN ANTERIOR:
//   • Instalación, Tipo de instalación → dropdowns que cargan del API al abrir.
//   • Tipo de acto y Opción de acto    → dropdowns con IDs reales del catálogo.
//   • Causa del acto                   → dropdown con IDs reales del catálogo.
//   • El payload enviado al backend ahora usa los IDs correctos.
//   • id_supervisor tomado del objeto usuario (id_usuario = 2).

import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/datos/datasourses/auditoria_completa_servicio.dart';
import '../../../presentacion/widgets/evidencia_item.dart';
import 'pantalla_generacion_reporte.dart';

class PantallaNuevaInspeccion extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const PantallaNuevaInspeccion({
    super.key,
    required this.usuario,
  });

  @override
  State<PantallaNuevaInspeccion> createState() =>
      _PantallaNuevaInspeccionState();
}

class _PantallaNuevaInspeccionState extends State<PantallaNuevaInspeccion> {
  final _svc = AuditoriaCompletaServicio();

  // ── Estado de carga / guardado ─────────────────────────────
  bool _cargandoCatalogos = true;
  bool _guardando = false;

  // ── Catálogos del API ──────────────────────────────────────
  List<Map<String, dynamic>> _instalaciones = [];
  List<Map<String, dynamic>> _tiposInstalacion = [];
  List<Map<String, dynamic>> _tiposActo = [];
  List<Map<String, dynamic>> _opcionesActo = [];
  List<Map<String, dynamic>> _causas = [];

  // ── Valores seleccionados en dropdowns ─────────────────────
  int? _idInstalacionSel;
  int? _idTipoInstalacionSel;
  int? _idTipoActoSel;
  int? _idOpcionActoSel;
  int? _idCausaSel;

  // ── Formulario general ─────────────────────────────────────
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  bool _ptExiste = false;
  bool _ptVigente = false;

  // ── Registro de personas observadas ───────────────────────
  final _nombrePersonaController = TextEditingController();
  final _apellidosPersonaController = TextEditingController();
  final _observacionPersonaController = TextEditingController();
  bool _tipoInterna = true;
  bool _tipoExterna = false;
  bool _claseSegura = true;
  bool _claseInsegura = false;
  final List<Map<String, dynamic>> _personasAgregadas = [];

  // ── Acto inseguro ──────────────────────────────────────────
  String? _severidad = 'BAJO';
  final _cantidadPersonasController = TextEditingController(text: '1');
  final _descripcionActoController = TextEditingController();
  bool _corregidoEnElMomento = false;

  // ── Evidencias ─────────────────────────────────────────────
  final List<EvidenciaData> _evidencias = [EvidenciaData()];

  // ── Resumen ────────────────────────────────────────────────
  final _observacionesResumenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    _nombrePersonaController.dispose();
    _apellidosPersonaController.dispose();
    _observacionPersonaController.dispose();
    _cantidadPersonasController.dispose();
    _descripcionActoController.dispose();
    _observacionesResumenController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════
  //  CARGA DE CATÁLOGOS
  // ══════════════════════════════════════════════════════════
  Future<void> _cargarCatalogos() async {
    try {
      final results = await Future.wait([
        _svc.obtenerInstalaciones(),
        _svc.obtenerTiposInstalacion(),
        _svc.obtenerTiposActo(),
        _svc.obtenerCausas(),
      ]);

      setState(() {
        _instalaciones = results[0];
        _tiposInstalacion = results[1];
        _tiposActo = results[2];
        _causas = results[3];

        // Preseleccionar el primero si solo hay uno
        if (_instalaciones.length == 1) {
          _idInstalacionSel = _instalaciones[0]['id_instalacion'] as int?;
        }
        if (_tiposInstalacion.length == 1) {
          _idTipoInstalacionSel =
              _tiposInstalacion[0]['id_tipo_instalacion'] as int?;
        }

        _cargandoCatalogos = false;
      });
    } catch (e) {
      setState(() => _cargandoCatalogos = false);
      _snack('Error al cargar catálogos: $e', error: true);
    }
  }

  // Cuando cambia el tipo de acto, carga sus opciones
  Future<void> _onTipoActoCambiado(int? idTipo) async {
    setState(() {
      _idTipoActoSel = idTipo;
      _idOpcionActoSel = null;
      _opcionesActo = [];
    });
    if (idTipo == null) return;
    try {
      final opts = await _svc.obtenerOpcionesActo(idTipo);
      setState(() => _opcionesActo = opts);
    } catch (e) {
      _snack('Error al cargar opciones: $e', error: true);
    }
  }

  // ══════════════════════════════════════════════════════════
  //  GUARDAR AUDITORÍA → backend
  // ══════════════════════════════════════════════════════════
  Future<void> _guardarAuditoria() async {
    // ── Validaciones ───────────────────────────────────────
    if (_idInstalacionSel == null) {
      _snack('Selecciona una instalación', error: true);
      return;
    }
    if (_idTipoInstalacionSel == null) {
      _snack('Selecciona el tipo de instalación', error: true);
      return;
    }

    setState(() => _guardando = true);

    try {
      // ── Subir evidencias ───────────────────────────────────
      final List<Map<String, dynamic>> evidenciasPayload = [];
      for (final ev in _evidencias) {
        String? rutaArchivo;
        if (ev.archivo != null) {
          try {
            rutaArchivo = await _svc.subirEvidencia(ev.archivo!);
          } catch (_) {}
        }
        if (rutaArchivo != null ||
            ev.descripcion.isNotEmpty ||
            ev.tipo != null) {
          evidenciasPayload.add({
            'tipo_archivo': ev.tipo ?? 'Otro',
            'descripcion': ev.descripcion,
            'ruta_archivo': rutaArchivo ?? '',
            'asociar_auditoria': ev.asociarAuditoria,
            'asociar_acto_index': null,
          });
        }
      }

      // ── Payload personas ───────────────────────────────────
      final List<Map<String, dynamic>> personasPayload = _personasAgregadas
          .map((p) => {
                'nombre': p['nombre'] ?? '',
                'apellidos': p['apellidos'] ?? '',
                'tipo_persona': p['tipo'] ?? 'INTERNA',
                'clasificacion': p['clasificacion'] ?? 'SEGURA',
                'observaciones': p['observacion'] ?? '',
              })
          .toList();

      // ── Payload actos ──────────────────────────────────────
      final List<Map<String, dynamic>> actosPayload = [];
      if (_idTipoActoSel != null && _idOpcionActoSel != null) {
        actosPayload.add({
          'id_tipo_acto': _idTipoActoSel!,
          'id_opcion_acto': _idOpcionActoSel!,
          'id_causa': _idCausaSel,
          'nivel_severidad': _severidad ?? 'BAJO',
          'cantidad_personas':
              int.tryParse(_cantidadPersonasController.text.trim()) ?? 1,
          'descripcion_adicional': _descripcionActoController.text.trim(),
          'corregido_en_el_acto': _corregidoEnElMomento,
        });
      }

      // ── id_supervisor desde el objeto usuario ──────────────
      final int idSupervisor = widget.usuario['id_usuario'] as int? ??
          widget.usuario['id'] as int? ??
          2; // fallback: id 2 = Supervisor en tu BD

      // ── Llamada al endpoint ────────────────────────────────
      final resultado = await _svc.guardarAuditoriaCompleta(
        idInstalacion: _idInstalacionSel!,
        idTipoInstalacion: _idTipoInstalacionSel!,
        idParteInstalacion: null,
        idSupervisor: idSupervisor,
        ptObtenido: _ptExiste,
        ptVigente: _ptVigente,
        observacionesGenerales: _observacionesResumenController.text.trim(),
        personas: personasPayload,
        actos: actosPayload,
        evidencias: evidenciasPayload,
      );

      final int idAuditoria =
          resultado['id_auditoria'] as int? ?? resultado['id'] as int? ?? 0;
      final String folio =
          resultado['folio']?.toString() ?? idAuditoria.toString();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaGeneracionReporte(
            idAuditoria: idAuditoria,
            folio: folio,
            usuario: widget.usuario,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceAll('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.danger : AppColors.success,
    ));
  }

  // ══════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_cargandoCatalogos) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormulario(),
                    const SizedBox(height: 20),
                    _buildSeccionPersonas(),
                    const SizedBox(height: 20),
                    _buildSeccionActosInseguros(),
                    const SizedBox(height: 20),
                    _buildSeccionEvidencias(),
                    const SizedBox(height: 20),
                    _buildSeccionResumen(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardando ? null : _guardarAuditoria,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _guardando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'GUARDAR AUDITORÍA',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  FORMULARIO GENERAL
  // ══════════════════════════════════════════════════════════
  Widget _buildFormulario() {
    return _tarjeta(
      titulo: 'Comenzar auditoría',
      children: [
        // Instalación (dropdown)
        _buildLabelDropdown(
          label: 'Instalación:',
          value: _idInstalacionSel,
          items: _instalaciones
              .map((i) => DropdownMenuItem<int>(
                    value: i['id_instalacion'] as int,
                    child: Text(i['nombre']?.toString() ?? ''),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _idInstalacionSel = v),
        ),
        const SizedBox(height: 14),

        // Tipo de instalación (dropdown)
        _buildLabelDropdown(
          label: 'Tipo instalación:',
          value: _idTipoInstalacionSel,
          items: _tiposInstalacion
              .map((t) => DropdownMenuItem<int>(
                    value: t['id_tipo_instalacion'] as int,
                    child: Text(t['nombre']?.toString() ?? ''),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _idTipoInstalacionSel = v),
        ),
        const SizedBox(height: 14),

        // Fecha y Hora
        Row(
          children: [
            Expanded(
              child: _buildCampo(
                label: 'Fecha:',
                controller: _fechaController,
                hint: 'dd/mm/aaaa',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCampo(
                label: 'Hora:',
                controller: _horaController,
                hint: 'hh:mm',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Permiso de trabajo
        const Text(
          'Permiso de Trabajo (PT):',
          style: TextStyle(
              color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        _buildCheckbox(
          label: 'Existe',
          valor: _ptExiste,
          onChanged: (v) => setState(() => _ptExiste = v ?? false),
        ),
        const SizedBox(height: 6),
        _buildCheckbox(
          label: 'Vigente',
          valor: _ptVigente,
          onChanged: (v) => setState(() => _ptVigente = v ?? false),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  //  SECCIÓN PERSONAS
  // ══════════════════════════════════════════════════════════
  Widget _buildSeccionPersonas() {
    return _tarjeta(
      titulo: 'Registro de personas observadas',
      children: [
        _buildCampo(label: 'Nombre:', controller: _nombrePersonaController),
        const SizedBox(height: 14),
        _buildCampo(
            label: 'Apellidos:', controller: _apellidosPersonaController),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tipo:',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildCheckbox(
                    label: 'Interna',
                    valor: _tipoInterna,
                    onChanged: (v) => setState(() {
                      _tipoInterna = v ?? false;
                      if (_tipoInterna) _tipoExterna = false;
                    }),
                  ),
                  const SizedBox(height: 6),
                  _buildCheckbox(
                    label: 'Externa',
                    valor: _tipoExterna,
                    onChanged: (v) => setState(() {
                      _tipoExterna = v ?? false;
                      if (_tipoExterna) _tipoInterna = false;
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Clasificación:',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildCheckbox(
                    label: 'Segura',
                    valor: _claseSegura,
                    onChanged: (v) => setState(() {
                      _claseSegura = v ?? false;
                      if (_claseSegura) _claseInsegura = false;
                    }),
                  ),
                  const SizedBox(height: 6),
                  _buildCheckbox(
                    label: 'Insegura',
                    valor: _claseInsegura,
                    onChanged: (v) => setState(() {
                      _claseInsegura = v ?? false;
                      if (_claseInsegura) _claseSegura = false;
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildCampo(
            label: 'Observación:', controller: _observacionPersonaController),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _agregarPersona,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Agregar persona',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ),
        if (_personasAgregadas.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ..._personasAgregadas.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p['nombre']} ${p['apellidos']}'.trim(),
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p['tipo']} · ${p['clasificacion']}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 11),
                        ),
                        if ((p['observacion'] ?? '').isNotEmpty)
                          Text(p['observacion'],
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 16, color: Colors.redAccent),
                    onPressed: () =>
                        setState(() => _personasAgregadas.removeAt(i)),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  //  SECCIÓN ACTOS INSEGUROS
  // ══════════════════════════════════════════════════════════
  Widget _buildSeccionActosInseguros() {
    return _tarjeta(
      titulo: 'Registro de actos inseguros',
      children: [
        // Tipo de acto (dropdown → carga opciones)
        _buildLabelDropdown(
          label: 'Tipo de acto:',
          value: _idTipoActoSel,
          items: _tiposActo
              .map((t) => DropdownMenuItem<int>(
                    value: t['id_tipo_acto'] as int,
                    child: Text(t['nombre']?.toString() ?? ''),
                  ))
              .toList(),
          onChanged: (v) => _onTipoActoCambiado(v),
        ),
        const SizedBox(height: 14),

        // Opción de acto (dropdown — depende del tipo)
        _buildLabelDropdown(
          label: 'Opción:',
          value: _idOpcionActoSel,
          items: _opcionesActo
              .map((o) => DropdownMenuItem<int>(
                    value: o['id_opcion_acto'] as int,
                    child: Text(o['nombre']?.toString() ?? ''),
                  ))
              .toList(),
          onChanged: _idTipoActoSel == null
              ? null
              : (v) => setState(() => _idOpcionActoSel = v),
          hint: _idTipoActoSel == null
              ? 'Selecciona tipo primero'
              : 'Selecciona opción',
        ),
        const SizedBox(height: 14),

        // Severidad
        const Text('Severidad:',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildCheckboxExclusivo(
            prefijo: '⅓', label: 'BAJO', color: Colors.black87),
        const SizedBox(height: 4),
        _buildCheckboxExclusivo(
            prefijo: '1', label: 'MEDIO', color: Colors.black87),
        const SizedBox(height: 4),
        _buildCheckboxExclusivo(prefijo: '3', label: 'ALTO', color: Colors.red),
        const SizedBox(height: 14),

        _buildCampo(
          label: 'Cant. personas:',
          controller: _cantidadPersonasController,
          hint: '1',
        ),
        const SizedBox(height: 14),

        // Causa (dropdown)
        _buildLabelDropdown(
          label: 'Causa:',
          value: _idCausaSel,
          items: _causas
              .map((c) => DropdownMenuItem<int>(
                    value: c['id_causa'] as int,
                    child: Text(
                      '${c['clave'] ?? ''} - ${c['descripcion'] ?? ''}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _idCausaSel = v),
          hint: 'Selecciona causa (opcional)',
        ),
        const SizedBox(height: 14),

        // Descripción adicional
        const Text('Descripción adicional:',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: _descripcionActoController,
            maxLines: 3,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(10),
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 14),

        _buildCheckbox(
          label: 'Corregido en el momento',
          valor: _corregidoEnElMomento,
          onChanged: (v) => setState(() => _corregidoEnElMomento = v ?? false),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  //  SECCIÓN EVIDENCIAS
  // ══════════════════════════════════════════════════════════
  Widget _buildSeccionEvidencias() {
    return _tarjeta(
      titulo: 'Evidencias',
      children: [
        ...List.generate(
            _evidencias.length,
            (index) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index > 0) const Divider(height: 32),
                    EvidenciaItem(
                      key: ValueKey(index),
                      data: _evidencias[index],
                      onChanged: () => setState(() {}),
                    ),
                  ],
                )),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () => setState(() => _evidencias.add(EvidenciaData())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5FA0),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Añadir otra evidencia',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  //  SECCIÓN RESUMEN
  // ══════════════════════════════════════════════════════════
  Widget _buildSeccionResumen() {
    return _tarjeta(
      titulo: 'Resumen de la auditoría',
      children: [
        const Text('Observaciones generales:',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: _observacionesResumenController,
            maxLines: 4,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(10),
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  //  WIDGETS AUXILIARES
  // ══════════════════════════════════════════════════════════

  /// Tarjeta blanca reutilizable
  Widget _tarjeta({required String titulo, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  /// Fila: "Label:" + Dropdown
  Widget _buildLabelDropdown({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?>? onChanged,
    String? hint,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                isDense: true,
                hint: Text(hint ?? 'Selecciona...',
                    style:
                        TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                style: const TextStyle(color: Colors.black87, fontSize: 13),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampo({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Container(
            height: 34,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool valor,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: valor,
            onChanged: onChanged,
            activeColor: AppColors.navy,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: BorderSide(color: Colors.grey.shade400, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(color: Colors.black87, fontSize: 13)),
      ],
    );
  }

  Widget _buildCheckboxExclusivo({
    required String prefijo,
    required String label,
    required Color color,
  }) {
    final seleccionado = _severidad == label;
    return GestureDetector(
      onTap: () => setState(() => _severidad = seleccionado ? null : label),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: seleccionado,
              onChanged: (_) =>
                  setState(() => _severidad = seleccionado ? null : label),
              activeColor: AppColors.navy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: BorderSide(color: Colors.grey.shade400, width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 6),
          Text(prefijo,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.black87, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.12))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.navy, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            'AUDITORÍA',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(letterSpacing: 3, color: AppColors.navy),
          ),
        ],
      ),
    );
  }

  void _agregarPersona() {
    final nombre = _nombrePersonaController.text.trim();
    if (nombre.isEmpty) {
      _snack('Escribe el nombre de la persona', error: true);
      return;
    }
    setState(() {
      _personasAgregadas.add({
        'nombre': nombre,
        'apellidos': _apellidosPersonaController.text.trim(),
        'tipo': _tipoInterna ? 'INTERNA' : 'EXTERNA',
        'clasificacion': _claseSegura ? 'SEGURA' : 'INSEGURA',
        'observacion': _observacionPersonaController.text.trim(),
      });
      _nombrePersonaController.clear();
      _apellidosPersonaController.clear();
      _observacionPersonaController.clear();
      _tipoInterna = true;
      _tipoExterna = false;
      _claseSegura = true;
      _claseInsegura = false;
    });
  }
}
