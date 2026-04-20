import 'package:flutter/material.dart';
import '../../../config/themes/tema_app.dart';

class PantallaHallazgos extends StatefulWidget {
  const PantallaHallazgos({super.key});

  @override
  State<PantallaHallazgos> createState() => _PantallaHallazgosState();
}

class _PantallaHallazgosState extends State<PantallaHallazgos> {
  String? _origen;
  String? _sitio;
  String? _ubicacion;
  String? _tipo;
  String? _severidad;
  String? _evidencia;

  final List<String> _opcionesOrigen    = ['Interno', 'Externo', 'Auditoría'];
  final List<String> _opcionesSitio     = ['Área 1A', 'Área 2B', 'Área 3A', 'Bodega'];
  final List<String> _opcionesUbicacion = ['Norte', 'Sur', 'Este', 'Oeste'];
  final List<String> _opcionesTipo      = ['Seguridad', 'Calidad', 'Ambiental'];
  final List<String> _opcionesSeveridad = ['Baja', 'Media', 'Alta', 'Crítica'];
  final List<String> _opcionesEvidencia = ['Foto', 'Video', 'Documento'];

  final _descripcionController    = TextEditingController();
  final _recomendacionController  = TextEditingController();

  @override
  void dispose() {
    _descripcionController.dispose();
    _recomendacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildFormulario(context),
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
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'HALLAZGOS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hallazgos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          _buildDropdown('Origen:', _origen, _opcionesOrigen,
                  (v) => setState(() => _origen = v)),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildDropdown('Sitio/Área:', _sitio, _opcionesSitio,
                        (v) => setState(() => _sitio = v)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdown('Ubicación:', _ubicacion,
                    _opcionesUbicacion,
                        (v) => setState(() => _ubicacion = v)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _buildDropdown('Tipo:', _tipo, _opcionesTipo,
                  (v) => setState(() => _tipo = v)),
          const SizedBox(height: 10),

          _buildDropdown('Severidad:', _severidad, _opcionesSeveridad,
                  (v) => setState(() => _severidad = v)),
          const SizedBox(height: 10),

          _buildCampoTexto('Descripción:', _descripcionController),
          const SizedBox(height: 10),

          _buildDropdown('Evidencia:', _evidencia, _opcionesEvidencia,
                  (v) => setState(() => _evidencia = v)),
          const SizedBox(height: 10),

          _buildCampoTexto('Recomendación:', _recomendacionController),
          const SizedBox(height: 16),

          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hallazgo guardado')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'GUARDAR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'CREAR ACCIÓN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String etiqueta,
      String? valor,
      List<String> opciones,
      ValueChanged<String?> onChanged,
      ) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            etiqueta,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:         valor,
                isExpanded:    true,
                dropdownColor: AppColors.surface,
                hint: const Text(''),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textHint,
                  size: 16,
                ),
                items: opciones.map((op) {
                  return DropdownMenuItem(value: op, child: Text(op));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampoTexto(
      String etiqueta, TextEditingController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              etiqueta,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
          ),
        ),
      ],
    );
  }
}