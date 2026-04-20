import 'package:flutter/material.dart';
import '../../../config/themes/tema_app.dart';

class PantallaEvaluacion extends StatefulWidget {
  const PantallaEvaluacion({super.key});

  @override
  State<PantallaEvaluacion> createState() => _PantallaEvaluacionState();
}

class _PantallaEvaluacionState extends State<PantallaEvaluacion> {
  final List<String> _epps = ['Casco', 'Lentes', 'Guantes', 'Botas', 'Ropa FR'];

  final List<Map<String, dynamic>> _trabajadores = [
    {'nombre': 'Ana',  'checks': [true,  true,  true,  false, true]},
    {'nombre': 'Juan', 'checks': [false, false, false, false, false]},
  ];

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormulario(context),
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
            'EVALUACIÓN',
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
          // Actividad
          Row(
            children: [
              const Text(
                'Actividad:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _buildCampoVacio(altura: 28)),
            ],
          ),
          const SizedBox(height: 14),

          // EPPs requeridos
          const Text(
            'Requerido:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _epps.map((epp) => _buildEppChip(epp)).toList(),
          ),
          const SizedBox(height: 16),

          // Tabla de trabajadores
          _buildTabla(),
          const SizedBox(height: 16),

          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Evaluación guardada')),
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

  Widget _buildEppChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTabla() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          // Encabezado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 70,
                  child: Text(
                    'Trabajador',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ..._epps.map(
                      (epp) => Expanded(
                    child: Text(
                      epp,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filas
          ..._trabajadores.asMap().entries.map((entry) {
            final index = entry.key;
            final trabajador = entry.value;
            final checks = trabajador['checks'] as List<bool>;
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      trabajador['nombre'],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  ...checks.asMap().entries.map((e) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            (_trabajadores[index]['checks']
                            as List<bool>)[e.key] = !e.value;
                          });
                        },
                        child: Center(
                          child: Icon(
                            e.value
                                ? Icons.check_rounded
                                : Icons.remove_rounded,
                            color: e.value
                                ? AppColors.success
                                : AppColors.textHint,
                            size: 16,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCampoVacio({double altura = 36}) {
    return Container(
      height: altura,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
    );
  }
}