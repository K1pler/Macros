// Importamos las librerías necesarias
import 'package:flutter/material.dart';
// Librería para animaciones de carga
import 'package:flutter_spinkit/flutter_spinkit.dart';
// Importamos la pantalla principal
import 'main_screen.dart';

// Pantalla de carga que se muestra al iniciar la aplicación
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Estado de la pantalla de carga
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Al inicializar la pantalla, comenzamos la navegación automática
    _navigateToMain();
  }

  // Función que maneja la navegación automática a la pantalla principal
  void _navigateToMain() async {
    // Esperamos 3 segundos antes de navegar
    await Future.delayed(const Duration(seconds: 3));
    // Verificamos que el widget aún esté montado (no se haya destruido)
    if (mounted) {
      // Navegamos a la pantalla principal y reemplazamos esta pantalla
      // (pushReplacement evita que el usuario pueda volver atrás)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Color de fondo que coincide con el tema de la aplicación
      backgroundColor: const Color(0xFF111827),
      body: Center(
        child: Column(
          // Centramos todos los elementos vertical y horizontalmente
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la aplicación (imagen desde assets)
            Image.asset(
              'assets/logo.png',
              width: 100,
              height: 100,
            ),
            // Espacio entre el logo y el texto
            const SizedBox(height: 24),
            // Nombre de la aplicación
            const Text(
              'MacroApp',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // Espacio entre el texto y la animación
            const SizedBox(height: 48),
            // Animación de carga (círculo que se desvanece)
            const SpinKitFadingCircle(
              color: Colors.red,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
} 