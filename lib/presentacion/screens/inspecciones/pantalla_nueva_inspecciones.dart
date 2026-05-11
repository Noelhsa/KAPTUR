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

  @override
  void dispose() {
    _folioController.dispose();
    _instalacionController.dispose();
    _tipoController.dispose();
    _areaController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
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
                child: _buildFormulario(),
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

          const SizedBox(height: 24),

          // Botón guardar
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
        ],
      ),
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
