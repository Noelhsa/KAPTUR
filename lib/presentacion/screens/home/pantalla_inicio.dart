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

  String get _nombreUsuario {
    final nombre = usuario['nombre']?.toString().trim() ?? '';
    if (nombre.isEmpty) return 'Supervisor';
    return nombre;
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
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBienvenida(context),
                    const SizedBox(height: 18),
                    _buildResumenRapido(context),
                    const SizedBox(height: 22),
                    _buildEstadoAuditorias(context),
                    const SizedBox(height: 22),
                    _buildAccesoRapido(context),
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.12),
          ),
        ),
      ),
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
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBienvenida(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.navy,
            Color(0xFF244D86),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $_nombreUsuario!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Aquí tienes el resumen general de tus auditorías de seguridad.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRapido(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSeccion(
          titulo: 'Resumen rápido',
          subtitulo: 'Vista general del trabajo del supervisor',
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.12,
          children: [
            _buildResumenCard(
              titulo: 'Este mes',
              valor: '12',
              descripcion: 'Auditorías registradas',
              icono: Icons.calendar_month_outlined,
              color: AppColors.navy,
            ),
            _buildResumenCard(
              titulo: 'Pendientes',
              valor: '3',
              descripcion: 'Sin enviar o en borrador',
              icono: Icons.pending_actions_outlined,
              color: AppColors.orange,
            ),
            _buildResumenCard(
              titulo: 'En revisión',
              valor: '2',
              descripcion: 'Esperando al jefe',
              icono: Icons.rate_review_outlined,
              color: AppColors.info,
            ),
            _buildResumenCard(
              titulo: 'Aprobadas',
              valor: '6',
              descripcion: 'Aceptadas por el jefe',
              icono: Icons.check_circle_outline,
              color: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildResumenHorizontal(
          titulo: 'Rechazadas',
          valor: '1',
          descripcion:
              'Auditoría devuelta con observaciones para revisión del supervisor.',
          icono: Icons.cancel_outlined,
          color: AppColors.danger,
        ),
      ],
    );
  }

  Widget _buildResumenCard({
    required String titulo,
    required String valor,
    required String descripcion,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: color,
              size: 21,
            ),
          ),
          const Spacer(),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10.5,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenHorizontal({
    required String titulo,
    required String valor,
    required String descripcion,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icono,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  descripcion,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoAuditorias(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSeccion(
          titulo: 'Estado de auditorías',
          subtitulo: 'Distribución visual de tus auditorías',
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildBarraEstado(
                titulo: 'Aprobadas',
                valor: 6,
                total: 12,
                color: AppColors.success,
              ),
              const SizedBox(height: 14),
              _buildBarraEstado(
                titulo: 'En revisión',
                valor: 2,
                total: 12,
                color: AppColors.info,
              ),
              const SizedBox(height: 14),
              _buildBarraEstado(
                titulo: 'Pendientes',
                valor: 3,
                total: 12,
                color: AppColors.orange,
              ),
              const SizedBox(height: 14),
              _buildBarraEstado(
                titulo: 'Rechazadas',
                valor: 1,
                total: 12,
                color: AppColors.danger,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarraEstado({
    required String titulo,
    required int valor,
    required int total,
    required Color color,
  }) {
    final double progreso = total == 0 ? 0 : valor / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$valor de $total',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progreso,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildAccesoRapido(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSeccion(
          titulo: 'Acción recomendada',
          subtitulo: 'Información de ejemplo para esta primera versión',
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.orange.withOpacity(0.18),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.tips_and_updates_outlined,
                  color: AppColors.orange,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revisa tus auditorías pendientes',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Tienes 3 auditorías pendientes. Más adelante esta tarjeta se conectará con la base de datos para mostrar información real.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTituloSeccion({
    required String titulo,
    required String subtitulo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitulo,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}
