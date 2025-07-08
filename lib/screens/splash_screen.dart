// Importamos las librerías necesarias
import 'package:flutter/material.dart';
// Librería para animaciones de carga
import 'package:flutter_spinkit/flutter_spinkit.dart';
// Provider para acceder a los providers
import 'package:provider/provider.dart';
// Importamos los providers
import '../providers/food_provider.dart';
import '../providers/log_provider.dart';
import '../providers/profile_provider.dart';
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
    // Esperamos a que todos los providers se inicialicen
    await _waitForProvidersInitialization();
    
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

  // Función para esperar a que todos los providers se inicialicen
  Future<void> _waitForProvidersInitialization() async {
    // Esperamos un mínimo de 2 segundos para mostrar la pantalla de carga
    await Future.delayed(const Duration(seconds: 2));
    
    // Esperamos a que todos los providers estén inicializados
    while (mounted) {
      final foodProvider = context.read<FoodProvider>();
      final logProvider = context.read<LogProvider>();
      final profileProvider = context.read<ProfileProvider>();
      
      // Verificamos si todos los providers están inicializados
      if (foodProvider.isInitialized && logProvider.isInitialized && profileProvider.isInitialized) {
        print('Todos los providers inicializados correctamente');
        break;
      }
      
      // Esperamos un poco más antes de verificar nuevamente
      await Future.delayed(const Duration(milliseconds: 100));
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
            // Espacio adicional
            const SizedBox(height: 24),
            // Texto de estado de carga
            Consumer3<FoodProvider, LogProvider, ProfileProvider>(
              builder: (context, foodProvider, logProvider, profileProvider, child) {
                if (foodProvider.isInitialized && logProvider.isInitialized && profileProvider.isInitialized) {
                  return const Text(
                    '¡Listo!',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  );
                } else {
                  return const Text(
                    'Cargando datos...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 