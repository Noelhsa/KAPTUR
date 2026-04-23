import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'pantalla_detalle_inspecciones.dart';

class PantallaInspecciones extends StatefulWidget {
  const PantallaInspecciones({super.key});

  @override
  State<PantallaInspecciones> createState() => _PantallaInspeccionesState();
}

class _PantallaInspeccionesState extends State<PantallaInspecciones> {
  String _filtroActivo = 'Todos';

  final List<String> _filtros = [
    'Todos',
    'Pendiente',
    'Completado',
    'En progreso',
    'Por confirmar',
  ];

  final List<Map<String, String>> _inspecciones = [
    {
      'id': '001',
      'titulo': 'Verificación mensual de mantenimiento',
      'area': 'Área 3A',
      'fecha': '19/04/2025',
      'estado': 'Pendiente',
    },
    {
      'id': '002',
      'titulo': 'Revisión de suministros eléctricos',
      'area': 'Área 1B',
      'fecha': '18/04/2025',
      'estado': 'Completado',
    },
    {
      'id': '003',
      'titulo': 'Inspección de equipo de soldadura',
      'area': 'Área 2C',
      'fecha': '17/04/2025',
      'estado': 'En progreso',
    },
    {
      'id': '004',
      'titulo': 'Control de inventario de herramientas',
      'area': 'Bodega',
      'fecha': '16/04/2025',
      'estado': 'Por confirmar',
    },
    {
      'id': '005',
      'titulo': 'Revisión de sistemas de seguridad',
      'area': 'Área 3A',
      'fecha': '15/04/2025',
      'estado': 'Completado',
    },
  ];

  List<Map<String, String>> get _inspeccionesFiltradas {
    if (_filtroActivo == 'Todos') return _inspecciones;
    return _inspecciones
        .where((i) => i['estado'] == _filtroActivo)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFiltros(),
            Expanded(
              child: _inspeccionesFiltradas.isEmpty
                  ? _buildVacio()
                  : _buildLista(),
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
            'INSPECCIONES',
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

  Widget _buildFiltros() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filtros.length,
        itemBuilder: (context, index) {
          final filtro = _filtros[index];
          final activo = filtro == _filtroActivo;
          return GestureDetector(
            onTap: () => setState(() => _filtroActivo = filtro),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: activo ? AppColors.orange : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: activo
                      ? AppColors.orange
                      : Colors.white.withOpacity(0.07),
                ),
              ),
              child: Text(
                filtro,
                style: TextStyle(
                  color: activo ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLista() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _inspeccionesFiltradas.length,
      itemBuilder: (context, index) {
        return _buildTarjeta(_inspeccionesFiltradas[index]);
      },
    );
  }

  Widget _buildTarjeta(Map<String, String> inspeccion) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PantallaDetalleInspeccion(inspeccion: inspeccion),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.checklist_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inspeccion['titulo'] ?? '',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.textHint,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        inspeccion['area'] ?? '',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textHint,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        inspeccion['fecha'] ?? '',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildEstadoPill(inspeccion['estado'] ?? ''),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.checklist_rounded,
            color: AppColors.textHint,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Sin inspecciones $_filtroActivo',
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
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