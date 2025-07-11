import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'daily_log_screen.dart';
import 'food_registry_screen.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

// Pantalla principal que contiene la navegación entre las diferentes secciones
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Estado de la pantalla principal
class _MainScreenState extends State<MainScreen> {
  // Índice de la pantalla actualmente seleccionada (0 = primera pantalla)
  int _selectedIndex = 0;
  
  // Lista de todas las pantallas disponibles en la aplicación
  final List<Widget> _screens = [
    const DailyLogScreen(),    // Pantalla 0: Registro diario
    const FoodRegistryScreen(), // Pantalla 1: Registro de alimentos
    const ProfileScreen(),     // Pantalla 2: Perfil del usuario
  ];
  
  // Títulos que se muestran en la barra superior para cada pantalla
  final List<String> _titles = ["Registro Diario", "Alimentos", "Mi Perfil"];

  // Función que se ejecuta cuando el usuario toca un elemento del menú inferior
  void _onItemTapped(int index) {
    setState(() {
      // Cambiamos la pantalla seleccionada
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con el título de la pantalla actual
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          FutureBuilder<bool>(
            future: Provider.of<ProfileProvider>(context, listen: false).hasSavedData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              final isActive = snapshot.data ?? false;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  Icons.verified_user,
                  color: isActive ? Colors.green : Colors.grey,
                  semanticLabel: isActive ? 'Usuario activo' : 'Sin usuario activo',
                ),
              );
            },
          ),
        ],
      ),
      // Cuerpo de la aplicación que muestra la pantalla seleccionada
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // Barra de navegación inferior con los iconos del menú
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // Primer elemento: Registro diario
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Registro',
          ),
          // Segundo elemento: Alimentos
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Alimentos',
          ),
          // Tercer elemento: Perfil
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        // Índice de la pantalla actualmente seleccionada
        currentIndex: _selectedIndex,
        // Función que se ejecuta cuando se toca un elemento del menú
        onTap: _onItemTapped,
      ),
    );
  }
}