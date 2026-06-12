import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'dashboard_tab.dart';
import 'map_tab.dart';
import 'profile_tab.dart';

class HomeLayout extends StatefulWidget {
  final Usuario usuario;

  const HomeLayout({super.key, required this.usuario});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      DashboardTab(usuario: widget.usuario),
      MapTab(usuario: widget.usuario),
      ProfileTab(usuario: widget.usuario),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1ECB71);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: primaryGreen,
        unselectedItemColor: const Color(0xFFADB5BD),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: "Mapa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
