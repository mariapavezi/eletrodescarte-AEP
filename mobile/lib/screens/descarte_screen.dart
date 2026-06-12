import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import '../models/usuario.dart';
import '../services/descarte_service.dart';
import './widgets/points_card.dart';

class DescarteScreen extends StatefulWidget {
  const DescarteScreen({super.key});

  @override
  State<DescarteScreen> createState() => _DescarteScreenState();
}

class _DescarteScreenState extends State<DescarteScreen> {
  final _service = DescarteService();
  TipoEletronico _tipoSelecionado = TipoEletronico.bateriaCelular;
  final _pesoController = TextEditingController();
  bool _loading = false;
  final int _usuarioId = 1; // Mocked ID para demonstração
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  void _carregarUsuario() async {
    try {
      final user = await _service.buscarUsuario(_usuarioId);
      setState(() => _usuario = user);
    } catch (e) {
      debugPrint('Erro ao carregar usuário: $e');
    }
  }

  void _enviarAgendamento() async {
    final peso = double.tryParse(_pesoController.text);
    if (peso == null || peso <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um peso válido')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final agendamento = Agendamento(
        usuarioId: _usuarioId, 
        pontoColetaId: 1,
        itens: [
          ItemDescarte(tipoEletronico: _tipoSelecionado, pesoKg: peso),
        ],
      );

      debugPrint('Enviando agendamento: ${jsonEncode(agendamento.toJson())}');
      await _service.criarAgendamento(agendamento);
      debugPrint('Agendamento criado com sucesso');
      
      debugPrint('Buscando dados atualizados do usuário...');
      final updatedUser = await _service.buscarUsuario(_usuarioId);
      debugPrint('Usuário atualizado: ${updatedUser.totalPoints} pontos');

      if (mounted) {
        setState(() => _usuario = updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agendamento realizado! Saldo: ${_usuario?.totalPoints} pts')),
        );
        _pesoController.clear();
      }
    } catch (e, stack) {
      debugPrint('ERRO NO REGISTRO: $e');
      debugPrint('STACKTRACE: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _getTipoLabel(TipoEletronico tipo) {
    switch (tipo) {
      case TipoEletronico.bateriaCelular:
        return 'Bateria / Celular';
      case TipoEletronico.tiInformatica:
        return 'TI / Informática';
      case TipoEletronico.linhaBranca:
        return 'Linha Branca';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EletroDescarte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_usuario != null) PointsCard(points: _usuario!.totalPoints),
            const SizedBox(height: 24),
            const Text(
              'Novo Agendamento',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButton<TipoEletronico>(
              value: _tipoSelecionado,
              isExpanded: true,
              items: TipoEletronico.values.map((TipoEletronico tipo) {
                return DropdownMenuItem<TipoEletronico>(
                  value: tipo,
                  child: Text(_getTipoLabel(tipo)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _tipoSelecionado = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pesoController,
              decoration: const InputDecoration(
                labelText: 'Peso (KG)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _enviarAgendamento,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Enviar Agendamento'),
                  ),
          ],
        ),
      ),
    );
  }
}
