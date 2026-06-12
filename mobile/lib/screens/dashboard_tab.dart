import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/indicadores.dart';
import '../models/descarte.dart';
import '../services/api_service.dart';
import '../utils/brasil_time.dart';
import 'new_discard_screen.dart';

class DashboardTab extends StatefulWidget {
  final Usuario usuario;

  const DashboardTab({super.key, required this.usuario});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Indicadores? _indicadores;
  List<Descarte> _descartes = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    try {
      final id = widget.usuario.idUsuario;
      final indicadores = await _apiService.buscarIndicadores(id);
      final descartes = await _apiService.buscarDescartesUsuario(id);

      descartes.sort((a, b) {
        final dateA = DateTime.tryParse(a.descartadoEm ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = DateTime.tryParse(b.descartadoEm ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      if (!mounted) return;
      setState(() {
        _indicadores = indicadores;
        _descartes = descartes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao carregar dados: ${e.toString().replaceAll('Exception: ', '')}"),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _openNewDiscardScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewDiscardScreen(
          usuario: widget.usuario,
          onDiscardCreated: _refreshData,
        ),
      ),
    );
    await _refreshData(showLoading: false);
  }

  List<Descarte> get _ultimosDescartes => _descartes.take(2).toList();

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "Sem data";
    try {
      final parsed = DateTime.parse(dateStr);
      final agora = BrasilTime.agora();
      
      if (parsed.year == agora.year && parsed.month == agora.month && parsed.day == agora.day) {
        return "Hoje, ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
      }
      
      final ontem = agora.subtract(const Duration(days: 1));
      if (parsed.year == ontem.year && parsed.month == ontem.month && parsed.day == ontem.day) {
        return "Ontem, ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
      }

      final meses = ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"];
      return "${parsed.day} ${meses[parsed.month - 1]}, ${parsed.year}";
    } catch (e) {
      // If date comes back as something else, clean it up or display as is
      return dateStr.replaceAll('T', ' ').substring(0, 16);
    }
  }

  double _calcularCo2Descarte(Descarte d) {
    // Estimativa simples para exibição local no histórico
    double total = 0.0;
    for (var item in d.itens) {
      // Pilhas: ~4.5kg CO2 por kg, Notebooks: ~12.0kg CO2 por un/kg
      final fator = item.material.nome.toLowerCase().contains("pilha") ? 4.5 : 12.0;
      total += item.quantidadeKg * fator;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const primaryGreen = Color(0xFF1ECB71);
    final countDescartes = _descartes.length;
    const metaDescartes = 4;
    final progressoMeta = (countDescartes / metaDescartes).clamp(0.0, 1.0);
    final faltamMeta = metaDescartes - countDescartes;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.bolt,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryGreen,
        child: _isLoading && _indicadores == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Olá, ${widget.usuario.nomeCompleto}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212529),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Seu impacto é fundamental hoje.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6C757D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: primaryGreen.withOpacity(0.15),
                              child: Text(
                                _getInitials(widget.usuario.nomeCompleto),
                                style: const TextStyle(
                                  color: primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent[700],
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Meu Impacto Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Meu Impacto",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212529),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Mês Atual",
                            style: TextStyle(
                              color: primaryGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Grid Impact Cards
                    Row(
                      children: [
                        // Card 1: CO2
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F9F0), // Light green background
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: primaryGreen.withOpacity(0.2), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.eco_outlined, color: Colors.green[700], size: 20),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  "${_indicadores?.totalCo2Evitado.toStringAsFixed(1) ?? '0.0'}kg",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF212529),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "de CO2 evitados",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Card 2: Water
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F3FF), // Light blue background
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.water_drop_outlined, color: Colors.blue, size: 20),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  "${_indicadores?.totalAguaEconomizada.toStringAsFixed(0) ?? '0'}L",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF212529),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "de água economizados",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Goal Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Meta de Descarte Mensal",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212529),
                                ),
                              ),
                              Text(
                                "${(progressoMeta * 100).toInt()}%",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Linear progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressoMeta,
                              backgroundColor: const Color(0xFFF1F3F5),
                              valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            faltamMeta > 0
                                ? "Faltam apenas $faltamMeta descarte${faltamMeta > 1 ? 's' : ''} para sua meta!"
                                : "Parabéns! Você atingiu sua meta de descarte deste mês!",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Últimos Descartes Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Últimos Descartes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212529),
                          ),
                        ),
                        if (_descartes.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              // Just show all in a dialog or scroll
                              _showAllDescartesDialog();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryGreen,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Ver tudo >",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Descartes list
                    if (_descartes.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.recycling, size: 40, color: Color(0xFFCED4DA)),
                            SizedBox(height: 10),
                            Text(
                              "Nenhum descarte registrado ainda.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: _ultimosDescartes.map((descarte) {
                          final label = descarte.itens.map((i) => i.material.nome).join(', ');
                          final co2 = _calcularCo2Descarte(descarte);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE9ECEF)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: primaryGreen.withOpacity(0.08),
                                  child: const Icon(Icons.bolt, color: primaryGreen, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label.isEmpty ? "Descarte de Eletrônicos" : label,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF212529),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatDate(descarte.descartadoEm),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6C757D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: primaryGreen.withOpacity(0.4)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "+${co2.toStringAsFixed(1)}kg CO2",
                                    style: const TextStyle(
                                      color: primaryGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 28),

                    // Button Registrar Novo Descarte
                    ElevatedButton(
                      onPressed: _openNewDiscardScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Registrar Novo Descarte",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Footer Tip
                    const Text(
                      "Ao descartar eletrônicos corretamente, você evita a contaminação do solo por metais pesados.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFADB5BD),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  void _showAllDescartesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Todos os Descartes", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _descartes.length,
              itemBuilder: (context, index) {
                final d = _descartes[index];
                final label = d.itens.map((i) => "${i.quantidadeKg}kg de ${i.material.nome}").join(', ');
                return ListTile(
                  leading: const Icon(Icons.bolt, color: Colors.green),
                  title: Text(label.isEmpty ? "Descarte" : label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text(_formatDate(d.descartadoEm), style: const TextStyle(fontSize: 11)),
                  trailing: Text("+${_calcularCo2Descarte(d).toStringAsFixed(1)} kg CO2", style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
