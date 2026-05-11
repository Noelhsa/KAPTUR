import 'package:flutter/material.dart';
import '../../../config/themes/tema_app.dart';

class PantallaCapacitacion extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onUserTap;

  const PantallaCapacitacion({
    super.key,
    required this.usuario,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CAPACITACIÓN',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          letterSpacing: 4,
                        ),
                  ),
                  GestureDetector(
                    onTap: onUserTap,
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.navy,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Próximamente',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
