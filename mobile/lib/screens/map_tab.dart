import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/usuario.dart';
import '../models/ponto_coleta.dart';
import '../services/api_service.dart';

class MapTab extends StatefulWidget {
  final Usuario usuario;

  const MapTab({super.key, required this.usuario});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();
  final MapController _mapController = MapController();

  static const _defaultCenter = LatLng(-23.5505, -46.6333);
  static const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  
  List<PontoColeta> _todosPontos = [];
  List<PontoColeta> _pontosFiltrados = [];
  bool _isLoading = true;
  String _filtroMaterial = "Todos";

  @override
  void initState() {
    super.initState();
    _loadPontos();
    _searchController.addListener(_filtrarPontos);
  }

  Future<void> _loadPontos() async {
    try {
      final pontos = await _apiService.buscarPontosColeta();
      setState(() {
        _todosPontos = pontos;
        _pontosFiltrados = _ordenarPontos(pontos);
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _ajustarMapa());
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao buscar pontos: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  void _filtrarPontos() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _pontosFiltrados = _ordenarPontos(_todosPontos.where((ponto) {
        final matchQuery = ponto.nome.toLowerCase().contains(query) ||
            ponto.endereco.toLowerCase().contains(query);
            
        final matchMaterial = _filtroMaterial == "Todos" ||
            ponto.materiaisAceitos.any((m) => m.nome == _filtroMaterial);

        return matchQuery && matchMaterial;
      }).toList());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _ajustarMapa());
  }

  List<PontoColeta> get _pontosComCoordenadas {
    return _pontosFiltrados
        .where((p) => p.latitude != null && p.longitude != null)
        .toList();
  }

  LatLng _centroInicial() {
    final pontos = _pontosComCoordenadas;
    if (pontos.isNotEmpty) {
      return LatLng(pontos.first.latitude!, pontos.first.longitude!);
    }

    final cidade = widget.usuario.cidade?.nome.toLowerCase() ?? '';
    if (cidade.contains('curitiba')) return const LatLng(-25.4284, -49.2733);
    if (cidade.contains('maringá') || cidade.contains('maringa')) {
      return const LatLng(-23.4210, -51.9331);
    }
    if (cidade.contains('são paulo') || cidade.contains('sao paulo')) {
      return const LatLng(-23.5505, -46.6333);
    }

    return _defaultCenter;
  }

  void _ajustarMapa() {
    final pontos = _pontosComCoordenadas;
    if (pontos.isEmpty) {
      _mapController.move(_centroInicial(), 11);
      return;
    }

    if (pontos.length == 1) {
      _mapController.move(
        LatLng(pontos.first.latitude!, pontos.first.longitude!),
        14,
      );
      return;
    }

    final bounds = LatLngBounds.fromPoints(
      pontos.map((p) => LatLng(p.latitude!, p.longitude!)).toList(),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  void _focarPonto(PontoColeta ponto) {
    if (ponto.latitude == null || ponto.longitude == null) return;
    _mapController.move(LatLng(ponto.latitude!, ponto.longitude!), 15);
  }

  List<PontoColeta> _ordenarPontos(List<PontoColeta> pontos) {
    final lista = List<PontoColeta>.from(pontos);
    final cidadeUsuario = widget.usuario.cidade?.nome.toLowerCase() ?? '';

    lista.sort((a, b) {
      final aMesmaCidade = _pertenceCidade(a, cidadeUsuario);
      final bMesmaCidade = _pertenceCidade(b, cidadeUsuario);
      if (aMesmaCidade != bMesmaCidade) {
        return aMesmaCidade ? -1 : 1;
      }
      return _getDistanciaKm(a).compareTo(_getDistanciaKm(b));
    });

    return lista;
  }

  bool _pertenceCidade(PontoColeta ponto, String cidadeUsuario) {
    if (cidadeUsuario.isEmpty) return false;
    final cidadePonto = ponto.cidade?.nome.toLowerCase() ?? '';
    if (cidadePonto.contains(cidadeUsuario) || cidadeUsuario.contains(cidadePonto)) {
      return true;
    }
    return ponto.endereco.toLowerCase().contains(cidadeUsuario);
  }

  (double, double) _coordenadasUsuario() {
    final cidade = widget.usuario.cidade?.nome.toLowerCase() ?? '';
    if (cidade.contains('curitiba')) return (-25.4284, -49.2733);
    if (cidade.contains('maringá') || cidade.contains('maringa')) {
      return (-23.4210, -51.9331);
    }
    if (cidade.contains('são paulo') || cidade.contains('sao paulo')) {
      return (-23.5505, -46.6333);
    }
    return (-23.4210, -51.9331);
  }

  double _getDistanciaKm(PontoColeta p) {
    if (p.latitude == null || p.longitude == null) return double.maxFinite;

    final (userLat, userLng) = _coordenadasUsuario();
    const earthRadiusKm = 6371.0;
    final dLat = _toRad(p.latitude! - userLat);
    final dLng = _toRad(p.longitude! - userLng);
    final lat1 = _toRad(userLat);
    final lat2 = _toRad(p.latitude!);

    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRad(double value) => value * 3.141592653589793 / 180;

  List<String> _getTodosMateriaisUnicos() {
    final lista = <String>["Todos"];
    for (var p in _todosPontos) {
      for (var m in p.materiaisAceitos) {
        if (!lista.contains(m.nome)) {
          lista.add(m.nome);
        }
      }
    }
    return lista;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1ECB71);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "Pontos de Coleta",
          style: TextStyle(
            color: Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Input Field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Buscar ponto de coleta...",
                        hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFADB5BD)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // Mapa OpenStreetMap
                Container(
                  height: 220,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDEE2E6)),
                  ),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _centroInicial(),
                          initialZoom: 11,
                          minZoom: 4,
                          maxZoom: 18,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: _tileUrl,
                            userAgentPackageName:
                                'br.com.eletrodescarte.eletrodescarte_mobile',
                          ),
                          MarkerLayer(
                            markers: _pontosComCoordenadas.map((ponto) {
                              final isOpen = ponto.estaAbertoAgora;
                              return Marker(
                                point: LatLng(ponto.latitude!, ponto.longitude!),
                                width: 40,
                                height: 40,
                                child: GestureDetector(
                                  onTap: () => _mostrarOpcoesPonto(ponto),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 36,
                                    color: isOpen ? primaryGreen : const Color(0xFFADB5BD),
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 4,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      if (_pontosComCoordenadas.isEmpty)
                        Container(
                          color: Colors.white.withOpacity(0.85),
                          alignment: Alignment.center,
                          child: const Text(
                            'Nenhum ponto com coordenadas para exibir',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6C757D),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Material(
                          color: Colors.white,
                          elevation: 2,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: _ajustarMapa,
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.my_location,
                                size: 20,
                                color: Color(0xFF1ECB71),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Locais Próximos Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Locais Próximos",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Encontrados ${_pontosFiltrados.length} pontos perto de você",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
                      // Filter Badge/Menu
                      PopupMenuButton<String>(
                        onSelected: (String material) {
                          setState(() {
                            _filtroMaterial = material;
                            _filtrarPontos();
                          });
                        },
                        itemBuilder: (context) {
                          return _getTodosMateriaisUnicos().map((String mat) {
                            return PopupMenuItem<String>(
                              value: mat,
                              child: Row(
                                children: [
                                  Icon(
                                    mat == "Todos" ? Icons.category : Icons.recycling, 
                                    size: 16, 
                                    color: _filtroMaterial == mat ? primaryGreen : Colors.grey
                                  ),
                                  const SizedBox(width: 8),
                                  Text(mat, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F9F0),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: primaryGreen.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _filtroMaterial == "Todos" ? "Filtrar" : _filtroMaterial,
                                style: const TextStyle(
                                  color: primaryGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.filter_list, color: primaryGreen, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Collection Points List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _pontosFiltrados.length,
                    itemBuilder: (context, index) {
                      final ponto = _pontosFiltrados[index];
                      final isOpen = ponto.estaAbertoAgora;
                      final distance = _getDistanciaKm(ponto);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Avatar representation
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFF1F3F5),
                              child: Icon(
                                Icons.storefront, 
                                color: isOpen ? primaryGreen : const Color(0xFFADB5BD), 
                                size: 20
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ponto.nome,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF212529),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Status Text/Badge
                                      if (isOpen)
                                        const Text(
                                          "Aberto",
                                          style: TextStyle(
                                            color: primaryGreen,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF0F1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            "Fechado",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ponto.endereco,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6C757D),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // Badges row
                                  Row(
                                    children: [
                                      // Distance
                                      Icon(Icons.location_on_outlined, color: Colors.green[700], size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${distance.toStringAsFixed(1)} km",
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D)),
                                      ),
                                      const SizedBox(width: 14),
                                      // Hours
                                      const Icon(Icons.access_time, color: Colors.blue, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        ponto.horarioFormatado,
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Action Button / Arrow
                            IconButton(
                              onPressed: () {
                                _focarPonto(ponto);
                                _mostrarOpcoesPonto(ponto);
                              },
                              icon: Icon(
                                Icons.near_me_outlined, 
                                color: isOpen ? primaryGreen : const Color(0xFFADB5BD)
                              ),
                              iconSize: 22,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Support Alert Box (Bottom)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F9F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryGreen.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryGreen.withOpacity(0.15),
                        child: const Icon(Icons.phone_in_talk, color: primaryGreen, size: 18),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Suporte ao Descarte",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF155724),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Tem dúvidas sobre o que pode ser descartado? Ligue para o ponto de coleta antes de ir.",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF212529),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _mostrarOpcoesPonto(PontoColeta p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                p.nome,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(p.endereco, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text("Materiais Aceitos:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: p.materiaisAceitos.map((m) {
                  return Chip(
                    label: Text(m.nome, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.green.withOpacity(0.08),
                    side: BorderSide(color: Colors.green.withOpacity(0.2)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Abrindo rota de navegação... (Mock)")),
                  );
                },
                icon: const Icon(Icons.navigation),
                label: const Text("Como Chegar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1ECB71),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              if (p.telefone != null && p.telefone!.isNotEmpty) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Ligando para ${p.telefone}... (Mock)")),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: Text("Ligar: ${p.telefone}"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1ECB71),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF1ECB71)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
