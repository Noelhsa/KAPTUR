import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';

class PantallaInicio extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onUserTap;

  const PantallaInicio({
    super.key,
    required this.usuario,
    required this.onUserTap,
  });

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
      'imagen': 'recursos/imagenes/aviso_industrial.png',
    },
  ];

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSeccionHoy(context),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'INICIO',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.navy,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w700,
                ),
          ),
          GestureDetector(
            onTap: onUserTap,
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.navy,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionHoy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hoy!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Container(
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
            children: _tareasHoy.asMap().entries.map((entry) {
              final index = entry.key;
              final tarea = entry.value;

              return Column(
                children: [
                  _buildTareaItem(tarea, context),
                  if (index < _tareasHoy.length - 1)
                    Divider(
                      color: Colors.grey.withOpacity(0.15),
                      height: 1,
                      indent: 16,
                      endIndent: 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tarea['titulo'] ?? '',
            style: const TextStyle(
              color: AppColors.dark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tarea['descripcion'] ?? '',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tarea['estado'] ?? '',
            style: TextStyle(
              color: _colorEstado(tarea['estado'] ?? ''),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionAvisos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avisos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        ..._avisos.map((aviso) => _buildAvisoCard(aviso, context)),
      ],
    );
  }

  Widget _buildAvisoCard(Map<String, String> aviso, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Image.asset(
              aviso['imagen'] ?? 'recursos/imagenes/aviso_industrial.png',
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 130,
                color: AppColors.navy.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    Icons.precision_manufacturing_outlined,
                    color: AppColors.navy.withOpacity(0.3),
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aviso['texto'] ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  aviso['estado'] ?? '',
                  style: TextStyle(
                    color: _colorEstado(aviso['estado'] ?? ''),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return AppColors.orange;
      case 'Completado':
        return AppColors.success;
      case 'En progreso':
        return AppColors.info;
      case 'Por confirmar':
        return AppColors.orange;
      default:
        return Colors.grey;
    }
  }
}
