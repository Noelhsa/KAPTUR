// lib/presentacion/screens/inspecciones/pantalla_reporte_auditoria.dart

import 'package:flutter/material.dart';
import 'package:proyecto_kaptur/config/themes/tema_app.dart';

class PantallaReporteAuditoria extends StatefulWidget {
  final Map<String, dynamic> datosAuditoria;

  const PantallaReporteAuditoria({
    super.key,
    required this.datosAuditoria,
  });

  @override
  State<PantallaReporteAuditoria> createState() =>
      _PantallaReporteAuditoriaState();
}

class _PantallaReporteAuditoriaState extends State<PantallaReporteAuditoria> {
  // Aquí podrías integrar un paquete de firma digital como `signature`
  // Por ahora es un placeholder visual fiel al diseño
  bool _firmado = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.datosAuditoria;

    final String folio = d['folio'] ?? '---';
    final String instalacion = d['instalacion'] ?? '---';
    final String area = d['area'] ?? '---';
    final String fecha = d['fecha'] ?? '--/--/--';
    final String personasObservadas = d['totalPersonas'] ?? '---';
    final String seguras = d['personasSeguras'] ?? '---';
    final String inseguras = d['personasInseguras'] ?? '---';
    final String iai = d['totalActos'] ?? '---';
    final String ias = d['actosCorregidos'] ?? '---';
    final String observaciones = d['observaciones'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildTarjetaReporte(
                  folio: folio,
                  instalacion: instalacion,
                  area: area,
                  fecha: fecha,
                  personasObservadas: personasObservadas,
                  seguras: seguras,
                  inseguras: inseguras,
                  iai: iai,
                  ias: ias,
                  observaciones: observaciones,
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
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.12)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.navy,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'REPORTE',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  letterSpacing: 3,
                  color: AppColors.navy,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaReporte({
    required String folio,
    required String instalacion,
    required String area,
    required String fecha,
    required String personasObservadas,
    required String seguras,
    required String inseguras,
    required String iai,
    required String ias,
    required String observaciones,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Título ─────────────────────────────────────────
          const Text(
            'Generación de reporte',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ── Datos generales ─────────────────────────────────
          _buildFila('Folio:', folio),
          const SizedBox(height: 10),
          _buildFila('Instalación:', instalacion),
          const SizedBox(height: 10),
          _buildFila('Área:', area),
          const SizedBox(height: 10),
          _buildFila('Fecha:', fecha),
          const SizedBox(height: 20),

          // ── Personas observadas ──────────────────────────────
          _buildFila('Personas observadas:', personasObservadas),
          const SizedBox(height: 10),

          // Seguras e Inseguras en la misma fila (como en la imagen)
          Row(
            children: [
              Expanded(child: _buildFila('Seguras:', seguras)),
              Expanded(child: _buildFila('Inseguras:', inseguras)),
            ],
          ),
          const SizedBox(height: 10),

          _buildFila('IAI:', iai),
          const SizedBox(height: 10),
          _buildFila('IAS:', ias),
          const SizedBox(height: 20),

          // ── Observaciones ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 110,
                child: Text(
                  'Observaciones:',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    observaciones.isNotEmpty ? observaciones : '---',
                    style: TextStyle(
                      color: observaciones.isNotEmpty
                          ? Colors.black87
                          : Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Firma del supervisor ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Firma del supervisor:',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  // TODO: integrar paquete `signature` para firma real
                  setState(() => _firmado = !_firmado);
                },
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        _firmado ? Colors.green.shade50 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                    border: _firmado
                        ? Border.all(color: Colors.green.shade300)
                        : null,
                  ),
                  child: Center(
                    child: _firmado
                        ? Icon(Icons.check_circle_outline,
                            color: Colors.green.shade600, size: 20)
                        : Text(
                            'Firmar',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Botones Confirmar / Regresar ──────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _confirmar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Regresar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  Widget _buildFila(String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          valor,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _confirmar() {
    // TODO: Aquí va la lógica de guardado final (llamada al API con dio)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auditoría guardada correctamente'),
        backgroundColor: Color(0xFF2ECC71),
      ),
    );
    // Navegar al inicio o a la lista de auditorías
    // Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
