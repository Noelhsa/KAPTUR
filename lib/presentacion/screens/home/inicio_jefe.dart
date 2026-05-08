// inicio_jefe.dart
import 'package:flutter/material.dart';

class InicioJefe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menú Jefe")),
      body: Column(
        children: [
          // Mostrar las auditorías pendientes o estadísticas de seguridad
          ElevatedButton(
            onPressed: () {
              // Acción para mostrar auditorías pendientes
              Navigator.pushNamed(context, '/auditorias_jefe');
            },
            child: Text("Revisar Auditorías Pendientes"),
          ),
          // Excluir Capacitación y el botón "+"
        ],
      ),
    );
  }
}
