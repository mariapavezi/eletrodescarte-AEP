import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'login_screen.dart';

class ProfileTab extends StatelessWidget {
  final Usuario usuario;

  const ProfileTab({super.key, required this.usuario});

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
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
          "Meu Perfil",
          style: TextStyle(
            color: Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Profile Header / Avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: primaryGreen.withOpacity(0.1),
                    child: Text(
                      _getInitials(usuario.nomeCompleto),
                      style: const TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    usuario.nomeCompleto,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212529),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C757D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Profile info cards
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined, color: primaryGreen),
                    title: const Text("Papel do Usuário", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    subtitle: Text(
                      usuario.papel == "ADMIN" 
                          ? "Administrador" 
                          : usuario.papel == "MODERADOR" 
                              ? "Moderador" 
                              : "Cidadão", 
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212529))
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: primaryGreen),
                    title: const Text("Cidade / Região", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    subtitle: Text(
                      usuario.cidade != null 
                          ? "${usuario.cidade!.nome} - ${usuario.cidade!.uf}" 
                          : "Cidade não especificada", 
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212529))
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Logout Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red[700],
                side: BorderSide(color: Colors.red[100]!, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Sair da Conta",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
