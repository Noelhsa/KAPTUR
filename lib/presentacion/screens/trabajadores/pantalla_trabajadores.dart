import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/datos/datasourses/api_servicios.dart';

class PantallaTrabajadores extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onUserTap;

  const PantallaTrabajadores({
    super.key,
    required this.usuario,
    required this.onUserTap,
  });

  @override
  State<PantallaTrabajadores> createState() => _PantallaTrabajadoresState();
}

class _PantallaTrabajadoresState extends State<PantallaTrabajadores> {
  final ApiService _api = ApiService();
  final TextEditingController _buscarController = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  String? _error;
  String _busqueda = '';

  List<Map<String, dynamic>> _trabajadores = [];

  @override
  void initState() {
    super.initState();
    _cargarTrabajadores();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  int? get _idUsuarioActual {
    final idRaw = widget.usuario['id_usuario'] ?? widget.usuario['id'];

    if (idRaw == null) return null;

    return int.tryParse(idRaw.toString());
  }

  Future<void> _cargarTrabajadores() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final trabajadores = await _api.obtenerTrabajadores();

      if (!mounted) return;

      setState(() {
        _trabajadores = trabajadores;
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

  List<Map<String, dynamic>> get _trabajadoresFiltrados {
    if (_busqueda.trim().isEmpty) return _trabajadores;

    final texto = _busqueda.toLowerCase();

    return _trabajadores.where((t) {
      final nombreCompleto =
          '${t['nombre'] ?? ''} ${t['apellidos'] ?? ''}'.toLowerCase();
      final usuario = (t['usuario'] ?? '').toString().toLowerCase();
      final rol = (t['rol'] ?? '').toString().toLowerCase();
      final correo = (t['correo'] ?? '').toString().toLowerCase();

      return nombreCompleto.contains(texto) ||
          usuario.contains(texto) ||
          rol.contains(texto) ||
          correo.contains(texto);
    }).toList();
  }

  int get _total => _trabajadores.length;

  int get _jefes =>
      _trabajadores.where((t) => t['rol']?.toString() == 'Jefe').length;

  int get _supervisores =>
      _trabajadores.where((t) => t['rol']?.toString() == 'Supervisor').length;

  int get _activos =>
      _trabajadores.where((t) => _estaActivo(t['activo'])).length;

  bool _estaActivo(dynamic valor) {
    return valor == true || valor == 1 || valor.toString() == '1';
  }

  Future<void> _mostrarFormularioTrabajador({
    Map<String, dynamic>? trabajador,
  }) async {
    FocusScope.of(context).unfocus();

    final resultado = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (_) {
        return _FormularioTrabajadorSheet(
          trabajador: trabajador,
          idUsuarioActual: _idUsuarioActual,
        );
      },
    );

    // Si el usuario cierra tocando afuera o deslizando, no se guarda nada.
    if (resultado == null) return;

    final bool editando = trabajador != null;

    if (editando) {
      final idUsuario = int.tryParse(trabajador['id_usuario'].toString());

      if (idUsuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró el ID del trabajador'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      await _editarTrabajador(
        idUsuario: idUsuario,
        idRol: resultado['idRol'] as int,
        usuario: resultado['usuario'] as String,
        contrasena: resultado['contrasena'] as String,
        nombre: resultado['nombre'] as String,
        apellidos: resultado['apellidos'] as String,
        correo: resultado['correo'] as String,
        telefono: resultado['telefono'] as String,
        activo: resultado['activo'] as bool,
      );
    } else {
      await _crearTrabajador(
        idRol: resultado['idRol'] as int,
        usuario: resultado['usuario'] as String,
        contrasena: resultado['contrasena'] as String,
        nombre: resultado['nombre'] as String,
        apellidos: resultado['apellidos'] as String,
        correo: resultado['correo'] as String,
        telefono: resultado['telefono'] as String,
        activo: resultado['activo'] as bool,
      );
    }
  }

  Future<bool> _crearTrabajador({
    required int idRol,
    required String usuario,
    required String contrasena,
    required String nombre,
    required String apellidos,
    required String correo,
    required String telefono,
    required bool activo,
  }) async {
    setState(() => _guardando = true);

    try {
      await _api.crearTrabajador(
        idRol: idRol,
        usuario: usuario,
        contrasena: contrasena,
        nombre: nombre,
        apellidos: apellidos,
        correo: correo.isEmpty ? null : correo,
        telefono: telefono.isEmpty ? null : telefono,
        activo: activo,
      );

      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trabajador creado correctamente'),
          backgroundColor: AppColors.success,
        ),
      );

      await _cargarTrabajadores();
      return true;
    } catch (e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );

      return false;
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Future<bool> _editarTrabajador({
    required int idUsuario,
    required int idRol,
    required String usuario,
    required String contrasena,
    required String nombre,
    required String apellidos,
    required String correo,
    required String telefono,
    required bool activo,
  }) async {
    setState(() => _guardando = true);

    try {
      await _api.editarTrabajador(
        idUsuario: idUsuario,
        idRol: idRol,
        usuario: usuario,
        contrasena: contrasena.isEmpty ? null : contrasena,
        nombre: nombre,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
      );

      await _api.actualizarEstadoTrabajador(
        idUsuario: idUsuario,
        activo: activo,
        idUsuarioActual: _idUsuarioActual,
      );

      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trabajador actualizado correctamente'),
          backgroundColor: AppColors.success,
        ),
      );

      await _cargarTrabajadores();
      return true;
    } catch (e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );

      return false;
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Future<void> _cambiarEstadoTrabajador(
    Map<String, dynamic> trabajador,
    bool nuevoEstado,
  ) async {
    final idUsuario = int.tryParse(trabajador['id_usuario'].toString());

    if (idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el ID del trabajador'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (idUsuario == _idUsuarioActual && nuevoEstado == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes desactivar tu propio usuario'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    try {
      await _api.actualizarEstadoTrabajador(
        idUsuario: idUsuario,
        activo: nuevoEstado,
        idUsuarioActual: _idUsuarioActual,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nuevoEstado
                ? 'Trabajador activado correctamente'
                : 'Trabajador desactivado correctamente',
          ),
          backgroundColor: nuevoEstado ? AppColors.success : AppColors.orange,
        ),
      );

      await _cargarTrabajadores();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      floatingActionButton: FloatingActionButton(
        onPressed: _guardando ? null : () => _mostrarFormularioTrabajador(),
        backgroundColor: AppColors.navy,
        child: _guardando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.white,
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildContenido(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    return RefreshIndicator(
      onRefresh: _cargarTrabajadores,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          _buildResumen(),
          const SizedBox(height: 16),
          _buildBuscador(),
          const SizedBox(height: 16),
          if (_trabajadores.isEmpty)
            _buildVacio()
          else if (_trabajadoresFiltrados.isEmpty)
            _buildSinResultados()
          else
            ..._trabajadoresFiltrados.map(
              (trabajador) => _buildTarjetaTrabajador(trabajador),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.12)),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'TRABAJADORES',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
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

  Widget _buildResumen() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildResumenCard(
                titulo: 'Total',
                valor: _total.toString(),
                icono: Icons.groups_2_outlined,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildResumenCard(
                titulo: 'Jefes',
                valor: _jefes.toString(),
                icono: Icons.admin_panel_settings_outlined,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildResumenCard(
                titulo: 'Supervisores',
                valor: _supervisores.toString(),
                icono: Icons.engineering_outlined,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildResumenCard(
                titulo: 'Activos',
                valor: _activos.toString(),
                icono: Icons.verified_user_outlined,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResumenCard({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icono,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuscador() {
    return TextField(
      controller: _buscarController,
      onChanged: (value) {
        setState(() {
          _busqueda = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, usuario, correo o rol',
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTarjetaTrabajador(Map<String, dynamic> trabajador) {
    final nombreCompleto =
        '${trabajador['nombre'] ?? ''} ${trabajador['apellidos'] ?? ''}'.trim();

    final usuario = trabajador['usuario']?.toString() ?? 'Sin usuario';
    final rol = trabajador['rol']?.toString() ?? 'Sin rol';
    final correo = trabajador['correo']?.toString();
    final telefono = trabajador['telefono']?.toString();
    final activo = _estaActivo(trabajador['activo']);
    final idUsuario = int.tryParse(trabajador['id_usuario'].toString());

    final esUsuarioActual = idUsuario != null && idUsuario == _idUsuarioActual;

    final colorRol = rol == 'Jefe' ? AppColors.orange : AppColors.info;

    return GestureDetector(
      onTap: () => _mostrarFormularioTrabajador(trabajador: trabajador),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorRol.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                rol == 'Jefe'
                    ? Icons.admin_panel_settings_outlined
                    : Icons.engineering_outlined,
                color: colorRol,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreCompleto.isEmpty
                        ? 'Trabajador sin nombre'
                        : nombreCompleto,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildInfoLinea(Icons.account_circle_outlined, usuario),
                  if (correo != null && correo != 'null' && correo.isNotEmpty)
                    _buildInfoLinea(Icons.email_outlined, correo),
                  if (telefono != null &&
                      telefono != 'null' &&
                      telefono.isNotEmpty)
                    _buildInfoLinea(Icons.phone_outlined, telefono),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge(rol, colorRol),
                      _buildBadge(
                        activo ? 'Activo' : 'Inactivo',
                        activo ? AppColors.success : AppColors.danger,
                      ),
                      if (esUsuarioActual)
                        _buildBadge(
                          'Tu usuario',
                          AppColors.navy,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: activo,
              activeColor: AppColors.success,
              onChanged: (value) {
                if (esUsuarioActual && value == false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No puedes desactivar tu propio usuario'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                  return;
                }

                _cambiarEstadoTrabajador(trabajador, value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLinea(IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildVacio() {
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: Column(
        children: [
          Icon(
            Icons.groups_rounded,
            color: AppColors.navy.withOpacity(0.25),
            size: 58,
          ),
          const SizedBox(height: 14),
          const Text(
            'No hay trabajadores registrados',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Agrega un jefe o supervisor para comenzar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinResultados() {
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: Center(
        child: Text(
          'No se encontraron trabajadores con esa búsqueda.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.danger,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Error al cargar trabajadores',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarTrabajadores,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormularioTrabajadorSheet extends StatefulWidget {
  final Map<String, dynamic>? trabajador;
  final int? idUsuarioActual;

  const _FormularioTrabajadorSheet({
    required this.trabajador,
    required this.idUsuarioActual,
  });

  @override
  State<_FormularioTrabajadorSheet> createState() =>
      _FormularioTrabajadorSheetState();
}

class _FormularioTrabajadorSheetState
    extends State<_FormularioTrabajadorSheet> {
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _usuarioController;
  late final TextEditingController _contrasenaController;
  late final TextEditingController _correoController;
  late final TextEditingController _telefonoController;

  late int _idRolSeleccionado;
  late bool _activo;
  bool _passwordVisible = false;

  bool get _editando => widget.trabajador != null;

  bool get _esUsuarioActual {
    if (widget.trabajador == null || widget.idUsuarioActual == null) {
      return false;
    }

    final idUsuario = int.tryParse(widget.trabajador!['id_usuario'].toString());

    return idUsuario != null && idUsuario == widget.idUsuarioActual;
  }

  @override
  void initState() {
    super.initState();

    final trabajador = widget.trabajador;

    _nombreController = TextEditingController(
      text: trabajador?['nombre']?.toString() ?? '',
    );

    _apellidosController = TextEditingController(
      text: trabajador?['apellidos']?.toString() ?? '',
    );

    _usuarioController = TextEditingController(
      text: trabajador?['usuario']?.toString() ?? '',
    );

    _contrasenaController = TextEditingController();

    _correoController = TextEditingController(
      text: _limpiarNull(trabajador?['correo']),
    );

    _telefonoController = TextEditingController(
      text: _limpiarNull(trabajador?['telefono']),
    );

    _idRolSeleccionado =
        int.tryParse(trabajador?['id_rol']?.toString() ?? '') ?? 2;

    _activo = trabajador == null ? true : _estaActivo(trabajador['activo']);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _usuarioController.dispose();
    _contrasenaController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  static String _limpiarNull(dynamic valor) {
    if (valor == null) return '';
    if (valor.toString() == 'null') return '';
    return valor.toString();
  }

  bool _estaActivo(dynamic valor) {
    return valor == true || valor == 1 || valor.toString() == '1';
  }

  void _guardar() {
    final nombre = _nombreController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final usuario = _usuarioController.text.trim();
    final contrasena = _contrasenaController.text.trim();
    final correo = _correoController.text.trim();
    final telefono = _telefonoController.text.trim();

    if (nombre.isEmpty || apellidos.isEmpty || usuario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa nombre, apellidos y usuario'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (!_editando && contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe una contraseña para el trabajador'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_esUsuarioActual && _activo == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes desactivar tu propio usuario'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'idRol': _idRolSeleccionado,
      'usuario': usuario,
      'contrasena': contrasena,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'activo': _activo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              _editando ? 'Editar trabajador' : 'Agregar trabajador',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _editando
                  ? 'Puedes actualizar nombre, correo, teléfono, rol o cambiar la contraseña.'
                  : 'Registra un jefe o supervisor para que pueda iniciar sesión en KAPTUR.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            if (_editando) ...[
              const SizedBox(height: 8),
              Text(
                'La contraseña actual no se muestra. Si dejas el campo vacío, no se cambia.',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 18),
            _buildCampoFormulario(
              controller: _nombreController,
              label: 'Nombre',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildCampoFormulario(
              controller: _apellidosController,
              label: 'Apellidos',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 12),
            _buildCampoFormulario(
              controller: _usuarioController,
              label: 'Usuario',
              icon: Icons.account_circle_outlined,
            ),
            const SizedBox(height: 12),
            _buildCampoFormulario(
              controller: _contrasenaController,
              label: _editando ? 'Nueva contraseña opcional' : 'Contraseña',
              icon: Icons.lock_outline,
              obscureText: !_passwordVisible,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildCampoFormulario(
              controller: _correoController,
              label: 'Correo opcional',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildCampoFormulario(
              controller: _telefonoController,
              label: 'Teléfono opcional',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _idRolSeleccionado,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: const [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Jefe'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Supervisor'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _idRolSeleccionado = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.toggle_on_outlined,
                    color: AppColors.navy,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Trabajador activo',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: _activo,
                    activeColor: AppColors.success,
                    onChanged: (value) {
                      if (_esUsuarioActual && value == false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('No puedes desactivar tu propio usuario'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _activo = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Icon(
                  _editando
                      ? Icons.save_outlined
                      : Icons.person_add_alt_1_rounded,
                ),
                label: Text(
                  _editando ? 'Guardar cambios' : 'Guardar trabajador',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoFormulario({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.navy,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
