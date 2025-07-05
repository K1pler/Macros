import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/profile_provider.dart';
import 'providers/food_provider.dart';
import 'providers/log_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    // MultiProvider envuelve la app para que todos los widgets hijos
    // puedan acceder a los datos de los providers.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => LogProvider()),
      ],
      child: const MacroApp(),
    ),
  );
}

class MacroApp extends StatelessWidget {
  const MacroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MacroApp',
      // Definimos un tema oscuro para toda la aplicación
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF111827),
        cardColor: const Color(0xFF1f2937),
        hintColor: Colors.grey[400],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1f2937),
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white),
        ),
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
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1f2937),
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}