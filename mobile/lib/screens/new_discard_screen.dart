import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/ponto_coleta.dart';
import '../models/material_model.dart';
import '../models/descarte.dart';
import '../services/api_service.dart';

class NewDiscardScreen extends StatefulWidget {
  final Usuario usuario;
  final Future<void> Function() onDiscardCreated;

  const NewDiscardScreen({
    super.key,
    required this.usuario,
    required this.onDiscardCreated,
  });

  @override
  State<NewDiscardScreen> createState() => _NewDiscardScreenState();
}

class _NewDiscardScreenState extends State<NewDiscardScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _obsController = TextEditingController();

  List<PontoColeta> _pontos = [];
  List<MaterialModel> _materiaisDisponiveis = [];
  
  PontoColeta? _selectedPonto;
  MaterialModel? _selectedMaterial;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final pontos = await _apiService.buscarPontosColeta();
      
      // Extrai todos os materiais únicos disponíveis em todos os pontos
      final materiaisMap = <int, MaterialModel>{};
      for (var p in pontos) {
        for (var m in p.materiaisAceitos) {
          materiaisMap[m.idMaterial] = m;
        }
      }

      setState(() {
        _pontos = pontos;
        _materiaisDisponiveis = materiaisMap.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao carregar dados: ${e.toString()}"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  void _onPontoChanged(PontoColeta? ponto) {
    setState(() {
      _selectedPonto = ponto;
      if (ponto != null) {
        // Filtra os materiais disponíveis para apenas os que o ponto aceita
        _materiaisDisponiveis = ponto.materiaisAceitos;
        // Se o material anteriormente selecionado não estiver na nova lista, reseta a seleção de material
        if (_selectedMaterial != null && 
            !ponto.materiaisAceitos.any((m) => m.idMaterial == _selectedMaterial!.idMaterial)) {
          _selectedMaterial = null;
        }
      } else {
        // Recarrega todos os materiais únicos
        final materiaisMap = <int, MaterialModel>{};
        for (var p in _pontos) {
          for (var m in p.materiaisAceitos) {
            materiaisMap[m.idMaterial] = m;
          }
        }
        _materiaisDisponiveis = materiaisMap.values.toList();
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPonto == null) {
      _showErrorSnackBar("Selecione um ponto de coleta");
      return;
    }
    if (_selectedMaterial == null) {
      _showErrorSnackBar("Selecione o tipo de resíduo");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final peso = double.parse(_pesoController.text.replaceAll(',', '.'));
      
      final item = DescarteItem(
        quantidadeKg: peso,
        material: _selectedMaterial!,
      );

      final descarte = Descarte(
        usuario: widget.usuario,
        pontoColeta: _selectedPonto!,
        observacoes: _obsController.text.trim().isEmpty ? null : _obsController.text.trim(),
        itens: [item],
      );

      await _apiService.enviarDescarte(descarte);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Descarte registrado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        await widget.onDiscardCreated();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      _showErrorSnackBar("Erro: ${e.toString().replaceAll('Exception: ', '')}");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _obsController.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF212529), size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          "Novo Descarte",
          style: TextStyle(
            color: Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Tip Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F9F0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryGreen.withOpacity(0.15)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.eco_outlined, color: Colors.green[700], size: 18),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Seu descarte faz a diferença",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[900],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Ao registrar este item, você ajuda a evitar que metais pesados contaminem o solo e a água.",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green[900]?.withOpacity(0.8),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Dropdown: Ponto de Coleta (Selected first so we filter residue type)
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 18, color: primaryGreen),
                          const SizedBox(width: 8),
                          const Text(
                            "Ponto de coleta",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<PontoColeta>(
                            value: _selectedPonto,
                            isExpanded: true,
                            hint: const Text("Onde você vai descartar?", style: TextStyle(fontSize: 13)),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: _pontos.map((PontoColeta ponto) {
                              return DropdownMenuItem<PontoColeta>(
                                value: ponto,
                                child: Text(ponto.nome, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: _onPontoChanged,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dropdown: Tipo de resíduo
                      Row(
                        children: [
                          Icon(Icons.phone_android_outlined, size: 18, color: primaryGreen),
                          const SizedBox(width: 8),
                          const Text(
                            "Tipo de resíduo",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<MaterialModel>(
                            value: _selectedMaterial,
                            isExpanded: true,
                            hint: const Text("Selecione o tipo...", style: TextStyle(fontSize: 13)),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: _materiaisDisponiveis.map((MaterialModel mat) {
                              return DropdownMenuItem<MaterialModel>(
                                value: mat,
                                child: Text(mat.nome, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (MaterialModel? newValue) {
                              setState(() {
                                _selectedMaterial = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Field: Peso aproximado (kg)
                      Row(
                        children: [
                          Icon(Icons.scale_outlined, size: 18, color: primaryGreen),
                          const SizedBox(width: 8),
                          const Text(
                            "Peso aproximado (kg)",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pesoController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Ex: 0.5",
                          hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 13),
                          suffixText: "kg",
                          suffixStyle: const TextStyle(color: Color(0xFF6C757D), fontWeight: FontWeight.bold, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryGreen, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Digite o peso aproximado";
                          }
                          final parsed = double.tryParse(value.replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) {
                            return "Digite um peso maior que zero";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "* Use uma estimativa se não tiver uma balança por perto.",
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFADB5BD),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input: Observações (Extra, optional)
                      const Row(
                        children: [
                          Icon(Icons.notes, size: 18, color: primaryGreen),
                          SizedBox(width: 8),
                          Text(
                            "Observações (Opcional)",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _obsController,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Ex: Notebook antigo sem bateria, pilhas gastas...",
                          hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryGreen, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Warning Alert Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[600], size: 18),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Certifique-se de remover todos os dados pessoais de dispositivos eletrônicos antes de realizar o descarte oficial.",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF6C757D),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isSaving ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Confirmar Descarte",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
