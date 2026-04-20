import 'package:flutter/material.dart';
import '../../../config/themes/tema_app.dart';

class PantallaNuevaInspeccion extends StatefulWidget {
  const PantallaNuevaInspeccion({super.key});

  @override
  State<PantallaNuevaInspeccion> createState() =>
      _PantallaNuevaInspeccionState();
}

class _PantallaNuevaInspeccionState extends State<PantallaNuevaInspeccion> {
  bool _rechazado = false;

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
                    if (_rechazado) ...[
                      const SizedBox(height: 12),
                      _buildSeccionRechazo(context),
                    ],
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
            'MI VERIFICACIÓN',
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
          // Folio
          _buildEtiqueta('Folio'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildCampoVacio()),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sitio/Área y Actividad
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEtiqueta('Sitio / Área'),
                    const SizedBox(height: 6),
                    _buildCampoVacio(),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEtiqueta('Actividad'),
                    const SizedBox(height: 6),
                    _buildCampoVacio(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vigente y Autorizado
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEtiqueta('Vigente'),
                    const SizedBox(height: 6),
                    _buildCampoVacio(altura: 32),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEtiqueta('Autorizado'),
                    const SizedBox(height: 6),
                    _buildCampoVacio(altura: 32),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botones Aprobar / Rechazar
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _rechazado = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inspección aprobada')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'APROBAR',
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
                  onPressed: () => setState(() => _rechazado = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'RECHAZAR',
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

  Widget _buildSeccionRechazo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEtiqueta('Motivo de rechazo', color: AppColors.danger),
          const SizedBox(height: 6),
          _buildCampoVacio(altura: 60),
          const SizedBox(height: 12),
          _buildEtiqueta('Fecha y hora', color: AppColors.danger),
          const SizedBox(height: 6),
          _buildCampoVacio(altura: 32),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: const Center(
              child: Text(
                'Firma del usuario',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtiqueta(String texto,
      {Color color = AppColors.textSecondary}) {
    return Text(
      texto,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCampoVacio({double altura = 36}) {
    return Container(
      width: double.infinity,
      height: altura,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
    );
  }
}