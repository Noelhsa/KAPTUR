import 'package:flutter/material.dart';
import '../../../config/themes/tema_app.dart';

class PantallaCapacitacion extends StatelessWidget {
  const PantallaCapacitacion({super.key});

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
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.navy,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
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