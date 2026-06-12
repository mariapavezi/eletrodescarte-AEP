class Cidade {
  final int idCidade;
  final String nome;
  final String uf;

  Cidade({
    required this.idCidade,
    required this.nome,
    required this.uf,
  });

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      idCidade: json['idCidade'] ?? json['id_cidade'] ?? 0,
      nome: json['nome'] ?? '',
      uf: json['uf'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCidade': idCidade,
      'nome': nome,
      'uf': uf,
    };
  }
}
