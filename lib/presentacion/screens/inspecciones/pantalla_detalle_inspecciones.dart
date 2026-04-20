import 'package:flutter/material.dart';
import '../../../config/themes/tema_app.dart';

class PantallaDetalleInspeccion extends StatelessWidget {
  final Map<String, String> inspeccion;
  const PantallaDetalleInspeccion({super.key, required this.inspeccion});

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
                    _buildSeccionInfo(context),
                    const SizedBox(height: 16),
                    _buildSeccionEstado(context),
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
            'DETALLE',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Folio #${inspeccion['id']}',
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            inspeccion['titulo'] ?? '',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildFila('Área', inspeccion['area'] ?? ''),
          const SizedBox(height: 10),
          _buildFila('Fecha', inspeccion['fecha'] ?? ''),
          const SizedBox(height: 10),
          _buildFila('Estado', inspeccion['estado'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildFila(String etiqueta, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            etiqueta,
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionEstado(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(0, 42),
                  ),
                  icon: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16),
                  label: const Text(
                    'APROBAR',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    minimumSize: const Size(0, 42),
                  ),
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 16),
                  label: const Text(
                    'RECHAZAR',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}