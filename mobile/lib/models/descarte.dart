import 'usuario.dart';
import 'ponto_coleta.dart';
import 'material_model.dart';

class DescarteItem {
  final int? idItem;
  final double quantidadeKg;
  final MaterialModel material;

  DescarteItem({
    this.idItem,
    required this.quantidadeKg,
    required this.material,
  });

  factory DescarteItem.fromJson(Map<String, dynamic> json) {
    return DescarteItem(
      idItem: json['idItem'] ?? json['id_item'],
      quantidadeKg: (json['quantidadeKg'] ?? json['quantidade_kg'] ?? 0.0) as double,
      material: MaterialModel.fromJson(json['material']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idItem != null) 'idItem': idItem,
      'quantidadeKg': quantidadeKg,
      'material': {
        'idMaterial': material.idMaterial,
      },
    };
  }
}

class Descarte {
  final int? idDescarte;
  final String? descartadoEm;
  final String? observacoes;
  final Usuario usuario;
  final PontoColeta pontoColeta;
  final List<DescarteItem> itens;

  Descarte({
    this.idDescarte,
    this.descartadoEm,
    this.observacoes,
    required this.usuario,
    required this.pontoColeta,
    required this.itens,
  });

  factory Descarte.fromJson(Map<String, dynamic> json) {
    var listItens = json['itens'] as List? ?? [];
    List<DescarteItem> itensList = listItens
        .map((i) => DescarteItem.fromJson(i))
        .toList();

    return Descarte(
      idDescarte: json['idDescarte'] ?? json['id_descarte'],
      descartadoEm: json['descartadoEm'] ?? json['descartado_em'],
      observacoes: json['observacoes'],
      usuario: Usuario.fromJson(json['usuario']),
      pontoColeta: PontoColeta.fromJson(json['pontoColeta']),
      itens: itensList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idDescarte != null) 'idDescarte': idDescarte,
      if (descartadoEm != null) 'descartadoEm': descartadoEm,
      'observacoes': observacoes ?? '',
      'usuario': {
        'idUsuario': usuario.idUsuario,
      },
      'pontoColeta': {
        'idPonto': pontoColeta.idPonto,
      },
      'itens': itens.map((i) => i.toJson()).toList(),
    };
  }
}
