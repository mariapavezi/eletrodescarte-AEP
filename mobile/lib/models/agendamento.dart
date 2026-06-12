enum TipoEletronico {
  bateriaCelular,
  tiInformatica,
  linhaBranca
}

class ItemDescarte {
  final TipoEletronico tipoEletronico;
  final double pesoKg;

  ItemDescarte({
    required this.tipoEletronico,
    required this.pesoKg,
  });

  Map<String, dynamic> toJson() {
    String tipoStr;
    switch (tipoEletronico) {
      case TipoEletronico.bateriaCelular:
        tipoStr = 'BATERIA_CELULAR';
        break;
      case TipoEletronico.tiInformatica:
        tipoStr = 'TI_INFORMATICA';
        break;
      case TipoEletronico.linhaBranca:
        tipoStr = 'LINHA_BRANCA';
        break;
    }
    return {
      'tipoEletronico': tipoStr,
      'pesoKg': pesoKg,
    };
  }
}

class Agendamento {
  final int? id;
  final int usuarioId;
  final int pontoColetaId;
  final List<ItemDescarte> itens;
  final String? status;

  Agendamento({
    this.id,
    required this.usuarioId,
    required this.pontoColetaId,
    required this.itens,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'pontoColetaId': pontoColetaId,
      'itens': itens.map((i) => i.toJson()).toList(),
    };
  }
}
