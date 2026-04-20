import 'package:flutter/material.dart';
import '../../../config/themes/tema_app.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  static const List<Map<String, String>> _tareasHoy = [
    {
      'titulo': 'Inspecciones',
      'descripcion': 'Verificación manual de mantenimiento',
      'estado': 'Pendiente',
    },
    {
      'titulo': 'Acción',
      'descripcion': 'Reponer los suministros de la sala',
      'estado': 'Completado',
    },
  ];

  static const List<Map<String, String>> _avisos = [
    {
      'texto': 'Se capacitan nuevos elementos en el área de 3A',
      'estado': 'Por confirmar',
    },
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
                    _buildSeccion('¡Hoy!', _tareasHoy, context),
                    const SizedBox(height: 20),
                    _buildSeccionAvisos(context),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'INICIO',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              letterSpacing: 4,
            ),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.navy,
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion(
      String titulo,
      List<Map<String, String>> tareas,
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Column(
            children: tareas.asMap().entries.map((entry) {
              final index = entry.key;
              final tarea = entry.value;
              return Column(
                children: [
                  _buildTareaItem(tarea, context),
                  if (index < tareas.length - 1)
                    Divider(
                      color: Colors.white.withOpacity(0.05),
                      height: 1,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTareaItem(Map<String, String> tarea, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tarea['titulo'] ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tarea['descripcion'] ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          _buildEstadoPill(tarea['estado'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildSeccionAvisos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avisos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._avisos.map((aviso) => _buildAvisoCard(aviso, context)),
      ],
    );
  }

  Widget _buildAvisoCard(Map<String, String> aviso, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              gradient: LinearGradient(
                colors: [AppColors.navy, AppColors.dark],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.precision_manufacturing_outlined,
                color: Colors.white.withOpacity(0.3),
                size: 32,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aviso['texto'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildEstadoPill(aviso['estado'] ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoPill(String estado) {
    Color color;
    Color bg;
    switch (estado) {
      case 'Pendiente':
        color = AppColors.orange;
        bg    = AppColors.orange.withOpacity(0.12);
        break;
      case 'Completado':
        color = AppColors.success;
        bg    = AppColors.success.withOpacity(0.12);
        break;
      case 'En progreso':
        color = AppColors.info;
        bg    = AppColors.info.withOpacity(0.12);
        break;
      case 'Por confirmar':
        color = AppColors.warning;
        bg    = AppColors.warning.withOpacity(0.12);
        break;
      default:
        color = AppColors.textSecondary;
        bg    = AppColors.textSecondary.withOpacity(0.12);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}