import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/cidade.dart';
import '../models/ponto_coleta.dart';
import '../models/descarte.dart';
import '../models/indicadores.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8080/api";
    }
    try {
      if (Platform.isAndroid) {
        return "http://10.0.2.2:8080/api";
      }
    } catch (_) {}
    return "http://localhost:8080/api";
  }

  Future<Usuario> fazerLogin(String email, String senha) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "senha": senha}),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception("Login inválido. Verifique seu e-mail e senha.");
    }
  }

  Future<Usuario> cadastrarUsuario({
    required String nomeCompleto,
    required String email,
    required String senha,
    required int idCidade,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/cadastrar"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "nomeCompleto": nomeCompleto,
        "email": email,
        "senha": senha,
        "idCidade": idCidade,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Usuario.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception("Falha ao cadastrar usuário.");
    }
  }

  Future<List<Cidade>> buscarCidades() async {
    final response = await http.get(Uri.parse("$baseUrl/cidades"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((c) => Cidade.fromJson(c)).toList();
    } else {
      throw Exception("Falha ao carregar cidades.");
    }
  }

  Future<List<PontoColeta>> buscarPontosColeta() async {
    final response = await http.get(Uri.parse("$baseUrl/pontos-coleta"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((p) => PontoColeta.fromJson(p)).toList();
    } else {
      throw Exception("Falha ao carregar pontos de coleta.");
    }
  }

  Future<Indicadores> buscarIndicadores(int usuarioId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/indicadores/usuario/$usuarioId"),
    );

    if (response.statusCode == 200) {
      return Indicadores.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception("Falha ao carregar indicadores ambientais.");
    }
  }

  Future<List<Descarte>> buscarDescartesUsuario(int usuarioId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/descartes/usuario/$usuarioId"),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((d) => Descarte.fromJson(d)).toList();
    } else {
      throw Exception("Falha ao carregar descartes.");
    }
  }

  Future<bool> enviarDescarte(Descarte descarte) async {
    final response = await http.post(
      Uri.parse("$baseUrl/descartes"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(descarte.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception(
      "Falha ao salvar descarte (HTTP ${response.statusCode}): ${utf8.decode(response.bodyBytes)}",
    );
  }
}
