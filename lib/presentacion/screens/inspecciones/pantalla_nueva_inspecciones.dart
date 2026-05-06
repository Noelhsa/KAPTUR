import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';
import 'package:proyecto_kaptur/datos/datasourses/auditoria_servicio.dart';
import 'package:proyecto_kaptur/datos/models/auditoria_modelo.dart';

class PantallaNuevaInspeccion extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const PantallaNuevaInspeccion({
    super.key,
    required this.usuario,
  });

  @override
  State<PantallaNuevaInspeccion> createState() =>
      _PantallaNuevaInspeccionState();
}

class _PantallaNuevaInspeccionState extends State<PantallaNuevaInspeccion> {
  final AuditoriaServicio _auditoriaServicio = AuditoriaServicio();
  final TextEditingController _observacionesController =
      TextEditingController();

  bool _cargandoCatalogos = true;
  bool _guardando = false;

  bool _ptObtenido = true;
  bool _ptVigente = true;

  List<Map<String, dynamic>> _instalaciones = [];
  List<Map<String, dynamic>> _tiposInstalacion = [];
  List<Map<String, dynamic>> _partesInstalacion = [];

  Map<String, dynamic>? _instalacionSeleccionada;
  Map<String, dynamic>? _tipoSeleccionado;
  Map<String, dynamic>? _parteSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogos() async {
    try {
      final instalaciones = await _auditoriaServicio.obtenerInstalaciones();
      final tipos = await _auditoriaServicio.obtenerTiposInstalacion();

      setState(() {
        _instalaciones = instalaciones;
        _tiposInstalacion = tipos;

        if (_instalaciones.isNotEmpty) {
          _instalacionSeleccionada = _instalaciones.first;
        }

        if (_tiposInstalacion.isNotEmpty) {
          _tipoSeleccionado = _tiposInstalacion.first;
        }
      });

      if (_instalacionSeleccionada != null) {
        await _cargarPartesInstalacion(
          _instalacionSeleccionada!['id_instalacion'],
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando catálogos: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _cargandoCatalogos = false);
      }
    }
  }

  Future<void> _cargarPartesInstalacion(int idInstalacion) async {
    try {
      final partes =
          await _auditoriaServicio.obtenerPartesInstalacion(idInstalacion);

      setState(() {
        _partesInstalacion = partes;
        _parteSeleccionada = partes.isNotEmpty ? partes.first : null;
      });
    } catch (e) {
      setState(() {
        _partesInstalacion = [];
        _parteSeleccionada = null;
      });
    }
  }

  Future<void> _guardarAuditoria() async {
    if (_instalacionSeleccionada == null || _tipoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona instalación y tipo de instalación'),
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final auditoria = AuditoriaModelo(
        idInstalacion: _instalacionSeleccionada!['id_instalacion'],
        idTipoInstalacion: _tipoSeleccionado!['id_tipo_instalacion'],
        idParteInstalacion: _parteSeleccionada?['id_parte_instalacion'],
        idSupervisor: widget.usuario['id_usuario'],
        ptObtenido: _ptObtenido,
        ptVigente: _ptVigente,
        observacionesGenerales: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
      );

      final respuesta = await _auditoriaServicio.crearAuditoria(auditoria);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            respuesta['mensaje'] ?? 'Auditoría creada correctamente',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _cargandoCatalogos
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
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
          _buildEtiqueta('Instalación'),
          const SizedBox(height: 6),
          _buildDropdown(
            value: _instalacionSeleccionada,
            items: _instalaciones,
            idKey: 'id_instalacion',
            nombreKey: 'nombre',
            onChanged: (value) async {
              setState(() => _instalacionSeleccionada = value);

              if (value != null) {
                await _cargarPartesInstalacion(value['id_instalacion']);
              }
            },
          ),
          const SizedBox(height: 12),
          _buildEtiqueta('Tipo de instalación'),
          const SizedBox(height: 6),
          _buildDropdown(
            value: _tipoSeleccionado,
            items: _tiposInstalacion,
            idKey: 'id_tipo_instalacion',
            nombreKey: 'nombre',
            onChanged: (value) {
              setState(() => _tipoSeleccionado = value);
            },
          ),
          const SizedBox(height: 12),
          _buildEtiqueta('Parte de instalación'),
          const SizedBox(height: 6),
          _buildDropdown(
            value: _parteSeleccionada,
            items: _partesInstalacion,
            idKey: 'id_parte_instalacion',
            nombreKey: 'nombre',
            onChanged: (value) {
              setState(() => _parteSeleccionada = value);
            },
          ),
          const SizedBox(height: 16),
          _buildSwitch(
            titulo: 'Permiso de trabajo obtenido',
            valor: _ptObtenido,
            onChanged: (value) => setState(() => _ptObtenido = value),
          ),
          _buildSwitch(
            titulo: 'Permiso de trabajo vigente',
            valor: _ptVigente,
            onChanged: (value) => setState(() => _ptVigente = value),
          ),
          const SizedBox(height: 16),
          _buildEtiqueta('Observaciones generales'),
          const SizedBox(height: 6),
          TextField(
            controller: _observacionesController,
            maxLines: 4,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Escribe observaciones de la verificación',
              hintStyle: const TextStyle(color: AppColors.textHint),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _guardando ? null : _guardarAuditoria,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _guardando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'GUARDAR VERIFICACIÓN',
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
    );
  }

  Widget _buildDropdown({
    required Map<String, dynamic>? value,
    required List<Map<String, dynamic>> items,
    required String idKey,
    required String nombreKey,
    required ValueChanged<Map<String, dynamic>?> onChanged,
  }) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: value,
      dropdownColor: AppColors.surface,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      iconEnabledColor: AppColors.textSecondary,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
      ),
      items: items.map((item) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: item,
          child: Text(item[nombreKey].toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSwitch({
    required String titulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: valor,
      activeColor: AppColors.success,
      contentPadding: EdgeInsets.zero,
      title: Text(
        titulo,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildEtiqueta(
    String texto, {
    Color color = AppColors.textSecondary,
  }) {
    return Text(
      texto,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
