import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';

class PantallaDetalleInspeccion extends StatefulWidget {
  final Map<String, String> inspeccion;
  const PantallaDetalleInspeccion({super.key, required this.inspeccion});

  @override
  State<PantallaDetalleInspeccion> createState() =>
      _PantallaDetalleInspeccionState();
}

class _PantallaDetalleInspeccionState extends State<PantallaDetalleInspeccion> {
  bool _permisoExiste = false;
  bool _permisoVigente = false;

  final _folioController = TextEditingController();
  final _instalacionController = TextEditingController();
  final _tipoController = TextEditingController();
  final _areaController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _notasController = TextEditingController();

  @override
  void dispose() {
    _folioController.dispose();
    _instalacionController.dispose();
    _tipoController.dispose();
    _areaController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _notasController.dispose();
    super.dispose();
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFormulario(context),
                    const SizedBox(height: 12),
                    _buildAreaNotas(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.navy,
              size: 18,
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.navy,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ── Formulario ────────────────────────────────────────────
  Widget _buildFormulario(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comenzar auditoría',
            style: TextStyle(
              color: AppColors.dark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Folio
          _buildFilaCampo('Folio:', _folioController),
          const SizedBox(height: 10),

          // Instalación
          _buildFilaCampo('Instalación:', _instalacionController),
          const SizedBox(height: 10),

          // Tipo de instalación
          _buildFilaCampo('Tipo de Instalación:', _tipoController,
              anchoEtiqueta: 130),
          const SizedBox(height: 10),

          // Área
          _buildFilaCampo('Área:', _areaController),
          const SizedBox(height: 10),

          // Fecha y Hora en la misma fila
          Row(
            children: [
              Expanded(
                child: _buildFilaCampo('Fecha:', _fechaController),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilaCampo('Hora:', _horaController),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Permiso de Trabajo
          const Text(
            'Permiso de Trabajo (PT):',
            style: TextStyle(
              color: AppColors.dark,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildCheckItem('Existe', _permisoExiste, (v) {
            setState(() => _permisoExiste = v ?? false);
          }),
          const SizedBox(height: 4),
          _buildCheckItem('Vigente', _permisoVigente, (v) {
            setState(() => _permisoVigente = v ?? false);
          }),
        ],
      ),
    );
  }

  Widget _buildFilaCampo(
    String etiqueta,
    TextEditingController controller, {
    double anchoEtiqueta = 90,
  }) {
    return Row(
      children: [
        SizedBox(
          width: anchoEtiqueta,
          child: Text(
            etiqueta,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: AppColors.dark,
                fontSize: 12,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(
    String label,
    bool valor,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: valor,
            activeColor: AppColors.navy,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ── Área de notas ─────────────────────────────────────────
  Widget _buildAreaNotas() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _notasController,
        maxLines: null,
        expands: true,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          hintText: 'Notas adicionales...',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
