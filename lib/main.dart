// Importamos las librerías necesarias de Flutter
import 'package:flutter/material.dart';
// Provider es una librería para gestionar el estado de la aplicación
import 'package:provider/provider.dart';
// Importamos nuestros providers personalizados
import 'providers/profile_provider.dart';
import 'providers/food_provider.dart';
import 'providers/log_provider.dart';
// Importamos la pantalla de carga inicial
import 'screens/splash_screen.dart';

// Función principal que se ejecuta al iniciar la aplicación
void main() {
  runApp(
    // MultiProvider envuelve toda la aplicación para que todos los widgets
    // puedan acceder a los datos de los providers (estado global)
    MultiProvider(
      providers: [
        // ProfileProvider: gestiona los datos del perfil del usuario (edad, peso, etc.)
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        // FoodProvider: gestiona la lista de alimentos disponibles
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        // LogProvider: gestiona el registro diario de alimentos consumidos
        ChangeNotifierProvider(create: (_) => LogProvider()),
      ],
      child: const MacroApp(),
    ),
  );
}

// Widget principal de la aplicación que define el tema y la pantalla inicial
class MacroApp extends StatelessWidget {
  const MacroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MacroApp',
      // Definimos un tema oscuro personalizado para toda la aplicación
      theme: ThemeData(
        // Tema oscuro
        brightness: Brightness.dark,
        // Color principal rojo
        primarySwatch: Colors.red,
        // Color de fondo principal
        scaffoldBackgroundColor: const Color(0xFF111827),
        // Color de las tarjetas
        cardColor: const Color(0xFF1f2937),
        // Color de texto secundario
        hintColor: Colors.grey[400],
        // Configuración de la barra superior (AppBar)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1f2937),
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Configuración de textos
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white),
        ),
        // Configuración de campos de texto
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF374151),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        // Configuración de botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        // Configuración de la barra de navegación inferior
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1f2937),
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
        ),
      ),
      // Ocultamos el banner de debug
      debugShowCheckedModeBanner: false,
      // La pantalla inicial es la pantalla de carga (SplashScreen)
      home: const SplashScreen(),
    );
  }
}