import 'package:flutter/material.dart';
import '../../../config/themes/tema_app.dart';

class PantallaChecklist extends StatefulWidget {
  const PantallaChecklist({super.key});

  @override
  State<PantallaChecklist> createState() => _PantallaChecklistState();
}

class _PantallaChecklistState extends State<PantallaChecklist> {
  final List<Map<String, dynamic>> _items = [
    {'label': 'Delimitación/Señalización:', 'valor': false},
    {'label': 'Extintor/Equipo de resp:',   'valor': false},
    {'label': 'Loto (Si aplica):',          'valor': false},
    {'label': 'Herramienta en buen estado', 'valor': false},
    {'label': 'Orden y limpieza',           'valor': false},
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
            'CHECKLIST',
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
          const Text(
            'Checklist de controles críticos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          // Actividad
          Row(
            children: [
              const Text(
                'Actividad:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _buildCampoVacio(altura: 28)),
            ],
          ),
          const SizedBox(height: 14),

          // Items del checklist
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item  = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['label'],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(
                          () => _items[index]['valor'] = !item['valor'],
                    ),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: item['valor']
                            ? AppColors.success.withOpacity(0.15)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: item['valor']
                              ? AppColors.success
                              : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: item['valor']
                          ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.success,
                        size: 16,
                      )
                          : null,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enviado a validación HSE'),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'ENVIAR A\nVALIDACIÓN HSE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'CREAR\nHALLAZGO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
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

  Widget _buildCampoVacio({double altura = 36}) {
    return Container(
      height: altura,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
    );
  }
}