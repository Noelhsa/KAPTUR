// auditoria_jefe.dart
import 'package:flutter/material.dart';

class AuditoriaJefe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Auditorías Pendientes")),
      body: ListView.builder(
        itemCount:
            5, // Aquí debes ajustar la lógica para obtener las auditorías pendientes
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("Auditoría ${index + 1}"),
            subtitle: Text("Fecha: 2026-05-01"), // Ajusta según los datos
            trailing: IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                // Acción para aprobar la auditoría
                // Aquí puedes implementar la lógica para aprobarla desde la base de datos
              },
            ),
          );
        },
      ),
    );
  }
}
