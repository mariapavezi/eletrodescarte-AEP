class Indicadores {
  final double totalKgDescartado;
  final double totalCo2Evitado;
  final double totalAguaEconomizada;

  Indicadores({
    required this.totalKgDescartado,
    required this.totalCo2Evitado,
    required this.totalAguaEconomizada,
  });

  factory Indicadores.fromJson(Map<String, dynamic> json) {
    return Indicadores(
      totalKgDescartado: (json['totalKgDescartado'] ?? 0.0) as double,
      totalCo2Evitado: (json['totalCo2Evitado'] ?? 0.0) as double,
      totalAguaEconomizada: (json['totalAguaEconomizada'] ?? 0.0) as double,
    );
  }
}
