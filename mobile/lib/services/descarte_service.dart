import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/agendamento.dart';

class DescarteService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    } else {
      return 'http://localhost:8080/api';
    }
  }

  Future<Usuario> cadastrarUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario.toJson()),
    );

    if (response.statusCode == 201) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao cadastrar usuário: ${response.body}');
    }
  }

  Future<void> criarAgendamento(Agendamento agendamento) async {
    final response = await http.post(
      Uri.parse('$baseUrl/agendamentos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(agendamento.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao criar agendamento: ${response.body}');
    }
  }

  Future<void> concluirDescarte(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/agendamentos/$id/concluir'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao concluir descarte: ${response.body}');
    }
  }

  Future<Usuario> buscarUsuario(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/$id'),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao buscar usuário: ${response.body}');
    }
  }
}
