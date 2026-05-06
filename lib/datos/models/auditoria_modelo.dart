class AuditoriaModelo {
  final int idInstalacion;
  final int idTipoInstalacion;
  final int? idParteInstalacion;
  final int idSupervisor;
  final bool ptObtenido;
  final bool ptVigente;
  final String? observacionesGenerales;

  AuditoriaModelo({
    required this.idInstalacion,
    required this.idTipoInstalacion,
    this.idParteInstalacion,
    required this.idSupervisor,
    required this.ptObtenido,
    required this.ptVigente,
    this.observacionesGenerales,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_instalacion': idInstalacion,
      'id_tipo_instalacion': idTipoInstalacion,
      'id_parte_instalacion': idParteInstalacion,
      'id_supervisor': idSupervisor,
      'pt_obtenido': ptObtenido,
      'pt_vigente': ptVigente,
      'observaciones_generales': observacionesGenerales,
    };
  }
}
