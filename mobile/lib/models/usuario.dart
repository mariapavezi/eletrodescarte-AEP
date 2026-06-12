import 'cidade.dart';

class Usuario {
  final int idUsuario;
  final String nomeCompleto;
  final String email;
  final String papel;
  final Cidade? cidade;

  Usuario({
    required this.idUsuario,
    required this.nomeCompleto,
    required this.email,
    required this.papel,
    this.cidade,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'] ?? json['id_usuario'] ?? 0,
      nomeCompleto: json['nomeCompleto'] ?? json['nome_completo'] ?? '',
      email: json['email'] ?? '',
      papel: json['papel'] ?? 'CIDADAO',
      cidade: json['cidade'] != null ? Cidade.fromJson(json['cidade']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nomeCompleto': nomeCompleto,
      'email': email,
      'papel': papel,
      if (cidade != null) 'cidade': cidade!.toJson(),
    };
  }
}
