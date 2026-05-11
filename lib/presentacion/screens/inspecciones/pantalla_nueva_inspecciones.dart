import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';

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
  final _folioController = TextEditingController();
  final _instalacionController = TextEditingController();
  final _tipoController = TextEditingController();
  final _areaController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();

  bool _ptExiste = false;
  bool _ptVigente = false;

  // Registro de personas observadas
  final _nombrePersonaController = TextEditingController();
  final _observacionPersonaController = TextEditingController();
  bool _tipoInterna = false;
  bool _tipoExterna = false;
  bool _claseSegura = false;
  bool _claseInsegura = false;
  final List<Map<String, dynamic>> _personasAgregadas = [];

  // Registro de actos inseguros
  final Map<String, bool> _tiposActo = {
    'Acciones y reacciones': false,
    'EPP': false,
    'Herramientas': false,
    'Orden y limpieza': false,
    'Posiciones': false,
    'Procedimientos': false,
  };
  final _opcionActoController = TextEditingController();
  String? _severidad; // 'Bajo', 'Medio', 'Alto'
  final _cantidadPersonasController = TextEditingController();

  @override
  void dispose() {
    _folioController.dispose();
    _instalacionController.dispose();
    _tipoController.dispose();
    _areaController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _nombrePersonaController.dispose();
    _observacionPersonaController.dispose();
    _opcionActoController.dispose();
    _cantidadPersonasController.dispose();
    super.dispose();
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
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
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.navy,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'AUDITORÍA',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  letterSpacing: 3,
                  color: AppColors.navy,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
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
          // Título sección
          const Text(
            'Comenzar auditoría',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // Folio
          _buildCampo(label: 'Folio:', controller: _folioController),
          const SizedBox(height: 14),

          // Instalación
          _buildCampo(
              label: 'Instalación:', controller: _instalacionController),
          const SizedBox(height: 14),

          // Tipo de Instalación
          _buildCampo(
              label: 'Tipo de Instalación:', controller: _tipoController),
          const SizedBox(height: 14),

          // Área
          _buildCampo(label: 'Área:', controller: _areaController),
          const SizedBox(height: 14),

          // Fecha y Hora en la misma fila
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

          // Permiso de Trabajo
          const Text(
            'Permiso de Trabajo (PT):',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Sección Registro de personas observadas ───────────────

  Widget _buildSeccionPersonas() {
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
          // Título dentro de la tarjeta
          const Text(
            'Registro de personas observadas',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          // Nombre
          _buildCampo(
            label: 'Nombre:',
            controller: _nombrePersonaController,
          ),
          const SizedBox(height: 16),

          // Tipo y Clasificación en dos columnas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo:',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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

              // Clasificación
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clasificación',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
          const SizedBox(height: 16),

          // Observación
          _buildCampo(
            label: 'Observación:',
            controller: _observacionPersonaController,
          ),
          const SizedBox(height: 20),

          // Botón Agregar persona
          Center(
            child: ElevatedButton(
              onPressed: _agregarPersona,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Agregar persona',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Lista de personas agregadas
          if (_personasAgregadas.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ..._personasAgregadas.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            p['nombre'] ?? '',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${p['tipo'] ?? ''} · ${p['clasificacion'] ?? ''}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                          if ((p['observacion'] ?? '').isNotEmpty)
                            Text(
                              p['observacion'],
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
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
      ),
    );
  }

  // ── Sección Registro de actos inseguros ──────────────────

  Widget _buildSeccionActosInseguros() {
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
          // Título
          const Text(
            'Registro de actos inseguros',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Tipo de acto
          const Text(
            'Tipo de acto:',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ..._tiposActo.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildCheckbox(
                  label: entry.key,
                  valor: entry.value,
                  onChanged: (v) =>
                      setState(() => _tiposActo[entry.key] = v ?? false),
                ),
              )),
          const SizedBox(height: 14),

          // Opción
          _buildCampo(
            label: 'Opción:',
            controller: _opcionActoController,
          ),
          const SizedBox(height: 14),

          // Severidad
          const Text(
            'Severidad:',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildRadioSeveridad(
            prefijo: '⅓',
            label: 'Bajo',
            color: Colors.black87,
          ),
          const SizedBox(height: 4),
          _buildRadioSeveridad(
            prefijo: '1',
            label: 'Medio',
            color: Colors.black87,
          ),
          const SizedBox(height: 4),
          _buildRadioSeveridad(
            prefijo: '3',
            label: 'Alto',
            color: Colors.red,
          ),
          const SizedBox(height: 14),

          // Cantidad de personas
          _buildCampo(
            label: 'Cantidad de personas:',
            controller: _cantidadPersonasController,
            hint: '0',
          ),
        ],
      ),
    );
  }

  Widget _buildRadioSeveridad({
    required String prefijo,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _severidad = label),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Radio<String>(
              value: label,
              groupValue: _severidad,
              onChanged: (v) => setState(() => _severidad = v),
              activeColor: AppColors.navy,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            prefijo,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _agregarPersona() {
    final nombre = _nombrePersonaController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre de la persona')),
      );
      return;
    }
    setState(() {
      _personasAgregadas.add({
        'nombre': nombre,
        'tipo': _tipoInterna
            ? 'Interna'
            : _tipoExterna
                ? 'Externa'
                : 'Sin tipo',
        'clasificacion': _claseSegura
            ? 'Segura'
            : _claseInsegura
                ? 'Insegura'
                : 'Sin clasificación',
        'observacion': _observacionPersonaController.text.trim(),
      });
      // Limpiar campos
      _nombrePersonaController.clear();
      _observacionPersonaController.clear();
      _tipoInterna = false;
      _tipoExterna = false;
      _claseSegura = false;
      _claseInsegura = false;
    });
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
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(color: Colors.grey.shade400, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
