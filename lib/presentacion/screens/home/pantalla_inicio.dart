import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/datos/datasourses/api_servicios.dart';

class PantallaInicio extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onUserTap;

  const PantallaInicio({
    super.key,
    required this.usuario,
    required this.onUserTap,
  });

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final ApiService _api = ApiService();

  bool _cargando = true;
  String? _error;

  int _totalAuditorias = 0;
  int _esteMes = 0;
  int _pendientes = 0;
  int _enRevision = 0;
  int _aprobadas = 0;
  int _rechazadas = 0;

  String get _nombreUsuario {
    final nombre = widget.usuario['nombre']?.toString().trim() ?? '';
    if (nombre.isEmpty) return 'Supervisor';
    return nombre;
  }

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final idSupervisorRaw =
          widget.usuario['id_usuario'] ?? widget.usuario['id'];

      if (idSupervisorRaw == null) {
        throw Exception('No se encontró el ID del supervisor');
      }

      final idSupervisor = int.parse(idSupervisorRaw.toString());

      final respuesta = await _api.obtenerInicioSupervisor(idSupervisor);
      final resumen = Map<String, dynamic>.from(respuesta['resumen'] ?? {});

      if (!mounted) return;

      setState(() {
        _totalAuditorias =
            int.tryParse(resumen['total_auditorias'].toString()) ?? 0;
        _esteMes = int.tryParse(resumen['este_mes'].toString()) ?? 0;
        _pendientes = int.tryParse(resumen['pendientes'].toString()) ?? 0;
        _enRevision = int.tryParse(resumen['en_revision'].toString()) ?? 0;
        _aprobadas = int.tryParse(resumen['aprobadas'].toString()) ?? 0;
        _rechazadas = int.tryParse(resumen['rechazadas'].toString()) ?? 0;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _cargando = false;
      });
    }
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
              child: RefreshIndicator(
                onRefresh: _cargarResumen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBienvenida(context),
                      const SizedBox(height: 18),
                      if (_cargando) _buildCargando(),
                      if (!_cargando && _error != null) _buildError(),
                      if (!_cargando && _error == null) ...[
                        _buildResumenRapido(context),
                        const SizedBox(height: 22),
                        _buildEstadoAuditorias(context),
                        const SizedBox(height: 22),
                        _buildAccesoRapido(context),
                      ],
                    ],
                  ),
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
            onTap: widget.onUserTap,
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

  Widget _buildCargando() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.danger.withOpacity(0.18),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.danger,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            _error ?? 'Error al cargar información',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _cargarResumen,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
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
              valor: _esteMes.toString(),
              descripcion: 'Auditorías registradas',
              icono: Icons.calendar_month_outlined,
              color: AppColors.navy,
            ),
            _buildResumenCard(
              titulo: 'Pendientes',
              valor: _pendientes.toString(),
              descripcion: 'Sin enviar o en borrador',
              icono: Icons.pending_actions_outlined,
              color: AppColors.orange,
            ),
            _buildResumenCard(
              titulo: 'En revisión',
              valor: _enRevision.toString(),
              descripcion: 'Esperando al jefe',
              icono: Icons.rate_review_outlined,
              color: AppColors.info,
            ),
            _buildResumenCard(
              titulo: 'Aprobadas',
              valor: _aprobadas.toString(),
              descripcion: 'Aceptadas por el jefe',
              icono: Icons.check_circle_outline,
              color: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildResumenHorizontal(
          titulo: 'Rechazadas',
          valor: _rechazadas.toString(),
          descripcion:
              'Auditorías devueltas con observaciones para revisión del supervisor.',
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
    final total = _totalAuditorias == 0
        ? (_pendientes + _enRevision + _aprobadas + _rechazadas)
        : _totalAuditorias;

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
                valor: _aprobadas,
                total: total,
                color: AppColors.success,
              ),
              const SizedBox(height: 14),
              _buildBarraEstado(
                titulo: 'En revisión',
                valor: _enRevision,
                total: total,
                color: AppColors.info,
              ),
              const SizedBox(height: 14),
              _buildBarraEstado(
                titulo: 'Pendientes',
                valor: _pendientes,
                total: total,
                color: AppColors.orange,
              ),
              const SizedBox(height: 14),
              _buildBarraEstado(
                titulo: 'Rechazadas',
                valor: _rechazadas,
                total: total,
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
    String mensaje;

    if (_pendientes > 0) {
      mensaje =
          'Tienes $_pendientes auditoría(s) pendiente(s). Revisa cuáles faltan por completar o enviar.';
    } else if (_enRevision > 0) {
      mensaje =
          'Tienes $_enRevision auditoría(s) en revisión. Espera la respuesta del jefe de seguridad.';
    } else {
      mensaje =
          'No tienes auditorías pendientes por ahora. Puedes iniciar una nueva auditoría desde el botón +.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSeccion(
          titulo: 'Acción recomendada',
          subtitulo: 'Sugerencia según el estado de tus auditorías',
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
                      'Revisa tu avance',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      mensaje,
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
