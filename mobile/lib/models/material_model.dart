class MaterialModel {
  final int idMaterial;
  final String nome;
  final String unidade;

  MaterialModel({
    required this.idMaterial,
    required this.nome,
    required this.unidade,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      idMaterial: json['idMaterial'] ?? json['id_material'] ?? 0,
      nome: json['nome'] ?? '',
      unidade: json['unidade'] ?? 'kg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMaterial': idMaterial,
      'nome': nome,
      'unidade': unidade,
    };
  }
}
