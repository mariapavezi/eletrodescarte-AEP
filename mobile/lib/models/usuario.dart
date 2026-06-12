import 'cidade.dart';

class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String cpfCnpj;
  final int totalPoints;
  final String? papel;
  final Cidade? cidade;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.cpfCnpj,
    this.totalPoints = 0,
    this.papel,
    this.cidade,
  });

  // Alias getters for legacy code compatibility
  int get idUsuario => id ?? 0;
  String get nomeCompleto => nome;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? json['idUsuario'] ?? json['id_usuario'],
      nome: json['nome'] ?? json['nomeCompleto'] ?? json['nome_completo'] ?? '',
      email: json['email'] ?? '',
      cpfCnpj: json['cpfCnpj'] ?? json['cpf_cnpj'] ?? '',
      totalPoints: json['totalPoints'] ?? json['total_points'] ?? 0,
      papel: json['papel'],
      cidade: json['cidade'] != null ? Cidade.fromJson(json['cidade']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUsuario': id,
      'nome': nome,
      'nomeCompleto': nome,
      'email': email,
      'cpfCnpj': cpfCnpj,
      'totalPoints': totalPoints,
      'papel': papel,
      if (cidade != null) 'cidade': cidade!.toJson(),
    };
  }
}
