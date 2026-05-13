// lib/features/inspecciones/widgets/evidencia_item.dart
//
// Widget reutilizable que representa UN bloque de evidencia.
// Se instancia una vez por cada evidencia que el usuario quiera agregar.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────
// Modelo de datos de una evidencia
// ─────────────────────────────────────────────────────────────
class EvidenciaData {
  File? archivo;
  String? tipo; // valor del dropdown
  String descripcion;
  bool asociarAuditoria;
  bool asociarActoInseguro;

  EvidenciaData({
    this.archivo,
    this.tipo,
    this.descripcion = '',
    this.asociarAuditoria = false,
    this.asociarActoInseguro = false,
  });
}

// ─────────────────────────────────────────────────────────────
// Opciones del dropdown "Tipo"
// ─────────────────────────────────────────────────────────────
const List<String> kTiposEvidencia = [
  'Fotografía',
  'Video',
  'Documento',
  'Otro',
];

// ─────────────────────────────────────────────────────────────
// Widget principal
// ─────────────────────────────────────────────────────────────
class EvidenciaItem extends StatefulWidget {
  /// Datos que este widget gestiona; el padre puede leerlos directamente.
  final EvidenciaData data;

  /// Callback para que el padre refresque su propio setState si lo necesita.
  final VoidCallback? onChanged;

  const EvidenciaItem({
    super.key,
    required this.data,
    this.onChanged,
  });

  @override
  State<EvidenciaItem> createState() => _EvidenciaItemState();
}

class _EvidenciaItemState extends State<EvidenciaItem> {
  final ImagePicker _picker = ImagePicker();
  final _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descripcionController.text = widget.data.descripcion;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  // ── Abre el bottom-sheet con las opciones Galería / Cámara ──
  void _mostrarSelectorArchivo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Seleccionar archivo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar una foto'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          widget.data.archivo = File(picked.path);
        });
        widget.onChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Subir archivo ──────────────────────────────────────
        Row(
          children: [
            const Text(
              'Subir archivo',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _mostrarSelectorArchivo,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF3B5FA0), // azul oscuro similar al diseño
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),

        // Vista previa de la imagen seleccionada
        if (widget.data.archivo != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              widget.data.archivo!,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],

        const SizedBox(height: 14),

        // ── Tipo (dropdown) ────────────────────────────────────
        Row(
          children: [
            const SizedBox(
              width: 70,
              child: Text(
                'Tipo:',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.data.tipo,
                    hint: const Text(''),
                    isExpanded: true,
                    isDense: true,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                    items: kTiposEvidencia
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => widget.data.tipo = val);
                      widget.onChanged?.call();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── Descripción ────────────────────────────────────────
        const Text(
          'Descripción:',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: _descripcionController,
            maxLines: 3,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(10),
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            onChanged: (val) {
              widget.data.descripcion = val;
              widget.onChanged?.call();
            },
          ),
        ),

        const SizedBox(height: 14),

        // ── Asociar a ──────────────────────────────────────────
        const Text(
          'Asociar a:',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildCheckbox(
          label: 'Auditoría',
          valor: widget.data.asociarAuditoria,
          onChanged: (v) {
            setState(() => widget.data.asociarAuditoria = v ?? false);
            widget.onChanged?.call();
          },
        ),
        const SizedBox(height: 6),
        _buildCheckbox(
          label: 'Acto inseguro',
          valor: widget.data.asociarActoInseguro,
          onChanged: (v) {
            setState(() => widget.data.asociarActoInseguro = v ?? false);
            widget.onChanged?.call();
          },
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool valor,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: valor,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B5FA0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(color: Colors.grey.shade500, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.black87, fontSize: 13),
        ),
      ],
    );
  }
}
