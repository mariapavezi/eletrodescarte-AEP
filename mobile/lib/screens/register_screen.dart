import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/cidade.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  List<Cidade> _cidades = [];
  Cidade? _selectedCidade;
  bool _isLoadingCidades = true;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _loadCidades();
  }

  Future<void> _loadCidades() async {
    try {
      final cidades = await _apiService.buscarCidades();
      setState(() {
        _cidades = cidades;
        _isLoadingCidades = false;
        if (cidades.isNotEmpty) {
          _selectedCidade = cidades.first;
        }
      });
    } catch (e) {
      setState(() => _isLoadingCidades = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao carregar cidades: ${e.toString()}"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate() || _selectedCidade == null) return;

    setState(() => _isRegistering = true);

    try {
      await _apiService.cadastrarUsuario(
        nomeCompleto: _nameController.text.trim(),
        email: _emailController.text.trim(),
        senha: _passwordController.text,
        idCidade: _selectedCidade!.idCidade,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cadastro realizado com sucesso! Faça seu login."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1ECB71);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212529)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Criar Conta",
          style: TextStyle(
            color: Color(0xFF212529),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Preencha os dados abaixo para fazer parte do Eletrodescarte.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(height: 32),

                // Name Field
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 18, color: primaryGreen),
                    const SizedBox(width: 8),
                    const Text(
                      "Nome Completo",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Seu nome completo",
                    hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
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
                      return "Por favor, digite seu nome completo";
                    }
                    if (value.trim().split(' ').length < 2) {
                      return "Por favor, insira nome e sobrenome";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email Field
                Row(
                  children: [
                    Icon(Icons.mail_outline, size: 18, color: primaryGreen),
                    const SizedBox(width: 8),
                    const Text(
                      "E-mail",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "exemplo@email.com",
                    hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
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
                      return "Por favor, digite seu e-mail";
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return "Digite um e-mail válido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                Row(
                  children: [
                    Icon(Icons.lock_outline, size: 18, color: primaryGreen),
                    const SizedBox(width: 8),
                    const Text(
                      "Senha",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Crie uma senha de acesso",
                    hintStyle: const TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
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
                      return "Por favor, digite sua senha";
                    }
                    if (value.length < 4) {
                      return "A senha deve ter pelo menos 4 caracteres";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // City Dropdown
                Row(
                  children: [
                    Icon(Icons.location_city_outlined, size: 18, color: primaryGreen),
                    const SizedBox(width: 8),
                    const Text(
                      "Cidade",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _isLoadingCidades
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Cidade>(
                            value: _selectedCidade,
                            isExpanded: true,
                            hint: const Text("Selecione sua cidade", style: TextStyle(fontSize: 14)),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: _cidades.map((Cidade cidade) {
                              return DropdownMenuItem<Cidade>(
                                value: cidade,
                                child: Text(
                                  "${cidade.nome} - ${cidade.uf}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (Cidade? newValue) {
                              setState(() {
                                _selectedCidade = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                const SizedBox(height: 36),

                // Register Button
                ElevatedButton(
                  onPressed: _isRegistering || _isLoadingCidades ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isRegistering
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Criar Conta",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
