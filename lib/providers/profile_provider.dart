import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

// Provider que gestiona todos los datos del perfil del usuario
// (edad, peso, altura, objetivos de macros, etc.)
class ProfileProvider with ChangeNotifier {
  // Perfil actual del usuario
  UserProfile _profile = UserProfile();
  // Objetivos nutricionales del usuario
  UserGoals _goals = UserGoals();
  // Metabolismo basal (calorías que quema el cuerpo en reposo)
  double _bmr = 0;
  // Gasto energético total (calorías que quema el cuerpo con actividad)
  double _tdee = 0;
  
  // Flag para indicar si los datos han sido cargados
  bool _isInitialized = false;

  // Constructor: al crear el provider, cargamos los datos guardados
  ProfileProvider() {
    _loadProfileAndGoals();
  }

  // Getters para acceder a los datos desde otros widgets
  UserProfile get profile => _profile;
  UserGoals get goals => _goals;
  double get bmr => _bmr;
  double get tdee => _tdee;
  // Calorías finales objetivo (TDEE - déficit)
  double get finalCalories => _tdee - _profile.deficit;
  
  // Getter para verificar si los datos están inicializados
  bool get isInitialized => _isInitialized;

  // Calcula los gramos de cada macronutriente basado en las calorías objetivo
  Map<String, double> get macroGrams {
    if (finalCalories <= 0) return {'protein': 0, 'carbs': 0, 'fat': 0};
    
    // Calculamos gramos de proteína (4 calorías por gramo)
    final proteinGrams = (finalCalories * (_profile.macroDistribution['protein']! / 100)) / 4;
    // Calculamos gramos de carbohidratos (4 calorías por gramo)
    final carbsGrams = (finalCalories * (_profile.macroDistribution['carbs']! / 100)) / 4;
    // Calculamos gramos de grasa (9 calorías por gramo)
    final fatGrams = (finalCalories * (_profile.macroDistribution['fat']! / 100)) / 9;
    
    return {'protein': proteinGrams, 'carbs': carbsGrams, 'fat': fatGrams};
  }

  // Función para actualizar cualquier campo del perfil
  void updateProfileField(String field, dynamic value) {
    switch (field) {
      case 'sex': _profile.sex = value; break;
      case 'age': _profile.age = int.tryParse(value); break;
      case 'weight': _profile.weight = double.tryParse(value); break;
      case 'height': _profile.height = double.tryParse(value); break;
      case 'activity': _profile.activityFactor = value; break;
      case 'deficit': _profile.deficit = double.tryParse(value) ?? 0; break;
      case 'protein': _profile.macroDistribution['protein'] = double.tryParse(value) ?? 0; break;
      case 'carbs': _profile.macroDistribution['carbs'] = double.tryParse(value) ?? 0; break;
      case 'fat': _profile.macroDistribution['fat'] = double.tryParse(value) ?? 0; break;
    }
    // Recalculamos BMR y TDEE cuando cambian los datos
    _calculateBmrAndTdee();
    // Guardamos automáticamente los cambios
    _saveProfile();
    // Notificamos a todos los widgets que escuchan este provider
    notifyListeners();
  }

  // Establece una distribución predefinida de macros
  void setMacroPreset(String preset) {
    switch (preset) {
      case 'balanced':
        _profile.macroDistribution = {'protein': 30, 'carbs': 40, 'fat': 30};
        break;
      case 'high-protein':
        _profile.macroDistribution = {'protein': 40, 'carbs': 30, 'fat': 30};
        break;
      case 'low-carb':
        _profile.macroDistribution = {'protein': 40, 'carbs': 20, 'fat': 40};
        break;
      case 'custom':
      default:
        // Para 'custom' no hacemos nada, mantenemos los valores actuales
        break;
    }
    _calculateBmrAndTdee();
    _saveProfile();
    notifyListeners();
  }

  // Calcula el metabolismo basal (BMR) usando la fórmula de Mifflin-St Jeor
  void _calculateBmrAndTdee() {
    if (_profile.age == null || _profile.weight == null || _profile.height == null) {
      _bmr = 0;
      _tdee = 0;
      return;
    }

    // Fórmula de Mifflin-St Jeor para calcular BMR
    if (_profile.sex == 'male') {
      _bmr = (10 * _profile.weight!) + (6.25 * _profile.height!) - (5 * _profile.age!) + 5;
    } else {
      _bmr = (10 * _profile.weight!) + (6.25 * _profile.height!) - (5 * _profile.age!) - 161;
    }

    // Calculamos TDEE multiplicando BMR por el factor de actividad
    _tdee = _bmr * _profile.activityFactor;
    
    // Actualizamos los objetivos basados en los nuevos cálculos
    // Creamos una nueva instancia porque los campos son final
    _goals = UserGoals(
      calories: finalCalories,
      protein: macroGrams['protein']!,
      carbs: macroGrams['carbs']!,
      fat: macroGrams['fat']!,
    );
  }

  // Guarda el perfil y objetivos en el almacenamiento local del dispositivo
  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardamos el perfil como JSON
      await prefs.setString('userProfile', json.encode(_profile.toJson()));
      // Guardamos los objetivos como JSON
      await prefs.setString('userGoals', json.encode(_goals.toJson()));
      
      print('Datos guardados exitosamente');
    } catch (e) {
      // Si hay un error al guardar, lo registramos pero no interrumpimos la app
      print('Error guardando datos: $e');
    }
  }

  // Carga el perfil y objetivos desde el almacenamiento local
  Future<void> _loadProfileAndGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargamos el perfil guardado
      final profileJson = prefs.getString('userProfile');
      if (profileJson != null) {
        try {
          _profile = UserProfile.fromJson(json.decode(profileJson));
        } catch (e) {
          // Si hay error al cargar el perfil, usamos el perfil por defecto
          print('Error cargando perfil: $e');
        }
      }
      
      // Cargamos los objetivos guardados
      final goalsJson = prefs.getString('userGoals');
      if (goalsJson != null) {
        try {
          _goals = UserGoals.fromJson(json.decode(goalsJson));
        } catch (e) {
          // Si hay error al cargar los objetivos, los calculamos desde el perfil
          print('Error cargando objetivos: $e');
        }
      }
      
            // Calculamos BMR y TDEE con los datos cargados
      _calculateBmrAndTdee();
      
      _isInitialized = true;
      // Notificamos a los widgets que los datos han sido cargados
      notifyListeners();
    } catch (e) {
      // Si hay un error general, usamos los valores por defecto
      print('Error general cargando datos: $e');
      _calculateBmrAndTdee();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Guarda los objetivos actuales (función pública para el botón "Guardar")
  Future<void> saveGoals() async {
    await _saveProfile();
  }

  // Método para limpiar todos los datos guardados (útil para debugging)
  Future<void> clearSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userProfile');
      await prefs.remove('userGoals');
      print('Datos guardados eliminados');
    } catch (e) {
      print('Error eliminando datos: $e');
    }
  }

  // Método para verificar si hay datos guardados
  Future<bool> hasSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasProfile = prefs.containsKey('userProfile');
      final hasGoals = prefs.containsKey('userGoals');
      return hasProfile || hasGoals;
    } catch (e) {
      print('Error verificando datos guardados: $e');
      return false;
    }
  }
}