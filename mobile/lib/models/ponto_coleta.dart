import 'material_model.dart';
import 'cidade.dart';
import '../utils/brasil_time.dart';

class HorarioFuncionamento {
  final int idHorario;
  final int diaSemana;
  final String abreAs;
  final String fechaAs;

  HorarioFuncionamento({
    required this.idHorario,
    required this.diaSemana,
    required this.abreAs,
    required this.fechaAs,
  });

  factory HorarioFuncionamento.fromJson(Map<String, dynamic> json) {
    return HorarioFuncionamento(
      idHorario: json['idHorario'] ?? json['id_horario'] ?? 0,
      diaSemana: json['diaSemana'] ?? json['dia_semana'] ?? 1,
      abreAs: _parseTime(json['abreAs'] ?? json['abre_as'] ?? '08:00:00'),
      fechaAs: _parseTime(json['fechaAs'] ?? json['fecha_as'] ?? '18:00:00'),
    );
  }

  static String _parseTime(dynamic value) {
    if (value is String) return value;
    if (value is List && value.length >= 2) {
      final hour = value[0].toString().padLeft(2, '0');
      final minute = value[1].toString().padLeft(2, '0');
      return '$hour:$minute:00';
    }
    if (value is Map) {
      final hour = (value['hour'] ?? 0).toString().padLeft(2, '0');
      final minute = (value['minute'] ?? 0).toString().padLeft(2, '0');
      return '$hour:$minute:00';
    }
    return '08:00:00';
  }

  static String formatTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return time;
  }

  static int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  bool get isOpenNow {
    final agora = BrasilTime.agora();
    if (agora.weekday != diaSemana) return false;
    final agoraMinutos = agora.hour * 60 + agora.minute;
    final abreMinutos = _toMinutes(abreAs);
    final fechaMinutos = _toMinutes(fechaAs);
    return agoraMinutos >= abreMinutos && agoraMinutos <= fechaMinutos;
  }

  String get diaFormatado {
    const dias = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];
    if (diaSemana >= 1 && diaSemana <= 7) {
      return dias[diaSemana - 1];
    }
    return 'Dia Útil';
  }
}

class PontoColeta {
  final int idPonto;
  final String nome;
  final String endereco;
  final double? latitude;
  final double? longitude;
  final String? telefone;
  final String? email;
  final bool ativo;
  final Cidade? cidade;
  final List<HorarioFuncionamento> horarios;
  final List<MaterialModel> materiaisAceitos;

  PontoColeta({
    required this.idPonto,
    required this.nome,
    required this.endereco,
    this.latitude,
    this.longitude,
    this.telefone,
    this.email,
    required this.ativo,
    this.cidade,
    required this.horarios,
    required this.materiaisAceitos,
  });

  factory PontoColeta.fromJson(Map<String, dynamic> json) {
    var listHorarios = json['horarios'] as List? ?? [];
    List<HorarioFuncionamento> horariosList = listHorarios
        .map((h) => HorarioFuncionamento.fromJson(h))
        .toList();

    var listMateriais = json['materiaisAceitos'] as List? ?? [];
    List<MaterialModel> materiaisList = listMateriais
        .map((m) => MaterialModel.fromJson(m))
        .toList();

    return PontoColeta(
      idPonto: json['idPonto'] ?? json['id_ponto'] ?? 0,
      nome: json['nome'] ?? '',
      endereco: json['endereco'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      telefone: json['telefone'],
      email: json['email'],
      ativo: json['ativo'] ?? true,
      cidade: json['cidade'] != null ? Cidade.fromJson(json['cidade']) : null,
      horarios: horariosList,
      materiaisAceitos: materiaisList,
    );
  }

  HorarioFuncionamento? get horarioDeHoje {
    if (horarios.isEmpty) return null;
    final diaAtual = BrasilTime.agora().weekday;
    for (final horario in horarios) {
      if (horario.diaSemana == diaAtual) {
        return horario;
      }
    }
    return null;
  }

  bool get estaAbertoAgora {
    if (!ativo) return false;
    if (horarios.isEmpty) return true;
    final horario = horarioDeHoje;
    if (horario == null) return false;
    return horario.isOpenNow;
  }

  String get horarioFormatado {
    final horario = horarioDeHoje;
    if (horario != null) {
      return '${HorarioFuncionamento.formatTime(horario.abreAs)} - ${HorarioFuncionamento.formatTime(horario.fechaAs)}';
    }
    if (horarios.isEmpty) {
      return 'Horário não informado';
    }
    return 'Sem atendimento hoje';
  }
}
