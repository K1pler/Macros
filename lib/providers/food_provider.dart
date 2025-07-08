import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider que gestiona la lista de alimentos disponibles en la aplicación
class FoodProvider with ChangeNotifier {
  // Lista de todos los alimentos disponibles
  // ignore: prefer_final_fields
  List<FoodItem> _foods = [];
  
  // Flag para indicar si los datos han sido cargados
  bool _isInitialized = false;

  // Getter para acceder a la lista de alimentos desde otros widgets
  List<FoodItem> get foods => _foods;
  
  // Getter para verificar si los datos están inicializados
  bool get isInitialized => _isInitialized;

  // Función para añadir alimentos desde un JSON
  // Esta función permite importar alimentos en formato JSON
  String addFoodsFromJson(String jsonString) {
    // Verificamos que el JSON no esté vacío
    if (jsonString.isEmpty) return "Error: El JSON no puede estar vacío.";
    
    try {
      // Convertimos el string JSON a una lista de objetos
      final List<dynamic> data = json.decode(jsonString);
      int successCount = 0;
      
      // Recorremos cada elemento del JSON
      for (var item in data) {
        // Verificamos que el elemento sea un mapa (objeto JSON)
        if (item is Map<String, dynamic>) {
          // Creamos un FoodItem desde el JSON y lo añadimos a la lista
          _foods.add(FoodItem.fromJson(item));
          successCount++;
        }
      }
      
      // Notificamos a todos los widgets que escuchan este provider
      notifyListeners();
      saveFoods(); // Guardar después de añadir
      return "$successCount alimento(s) añadido(s) con éxito.";
    } catch (e) {
      // Si hay un error al procesar el JSON, devolvemos un mensaje de error
      return "Error: JSON inválido o formato incorrecto.";
    }
  }

  // Función para eliminar un alimento de la lista
  void deleteFood(String foodId) {
    // Removemos el alimento que tenga el ID especificado
    _foods.removeWhere((food) => food.id == foodId);
    // Notificamos a todos los widgets que escuchan este provider
    notifyListeners();
    saveFoods(); // Guardar después de eliminar
  }

  // Guarda la lista de alimentos en SharedPreferences
  Future<void> saveFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final foodsJson = json.encode(_foods.map((f) => f.toJson()).toList());
      await prefs.setString('foods', foodsJson);
      print('Alimentos guardados exitosamente: ${_foods.length} alimentos');
    } catch (e) {
      print('Error guardando alimentos: $e');
    }
  }

  // Carga la lista de alimentos desde SharedPreferences
  Future<void> loadFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final foodsJson = prefs.getString('foods');
      if (foodsJson != null) {
        final List<dynamic> data = json.decode(foodsJson);
        _foods = data.map((item) => FoodItem.fromJson(item)).toList();
        print('Alimentos cargados exitosamente: ${_foods.length} alimentos');
      } else {
        print('No se encontraron alimentos guardados');
        // Cargamos alimentos de ejemplo si no hay datos
        _loadSampleFoods();
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error cargando alimentos: $e');
      // Cargamos alimentos de ejemplo en caso de error
      _loadSampleFoods();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Carga alimentos de ejemplo para que la aplicación tenga datos iniciales
  void _loadSampleFoods() {
    _foods = [
      FoodItem(
        id: '1',
        nombre: 'Pollo (pechuga)',
        tipo: 'Proteínas',
        categoria: 'Almuerzo',
        cantidadReferencia: 100,
        kcal: 165,
        proteinas: 31,
        carbohidratos: 0,
        grasas: 3.6,
      ),
      FoodItem(
        id: '2',
        nombre: 'Arroz blanco',
        tipo: 'Carbohidratos',
        categoria: 'Almuerzo',
        cantidadReferencia: 100,
        kcal: 130,
        proteinas: 2.7,
        carbohidratos: 28,
        grasas: 0.3,
      ),
      FoodItem(
        id: '3',
        nombre: 'Aguacate',
        tipo: 'Grasas',
        categoria: 'Desayuno',
        cantidadReferencia: 100,
        kcal: 160,
        proteinas: 2,
        carbohidratos: 9,
        grasas: 15,
      ),
      FoodItem(
        id: '4',
        nombre: 'Huevo entero',
        tipo: 'Proteínas',
        categoria: 'Desayuno',
        cantidadReferencia: 100,
        kcal: 155,
        proteinas: 13,
        carbohidratos: 1.1,
        grasas: 11,
      ),
      FoodItem(
        id: '5',
        nombre: 'Plátano',
        tipo: 'Carbohidratos',
        categoria: 'Snacks',
        cantidadReferencia: 100,
        kcal: 89,
        proteinas: 1.1,
        carbohidratos: 23,
        grasas: 0.3,
      ),
      FoodItem(
        id: '6',
        nombre: 'Avena',
        tipo: 'Carbohidratos',
        categoria: 'Desayuno',
        cantidadReferencia: 100,
        kcal: 389,
        proteinas: 17,
        carbohidratos: 66,
        grasas: 7,
      ),
      FoodItem(
        id: '7',
        nombre: 'Salmón',
        tipo: 'Proteínas',
        categoria: 'Cena',
        cantidadReferencia: 100,
        kcal: 208,
        proteinas: 25,
        carbohidratos: 0,
        grasas: 12,
      ),
      FoodItem(
        id: '8',
        nombre: 'Brócoli',
        tipo: 'Carbohidratos',
        categoria: 'Almuerzo',
        cantidadReferencia: 100,
        kcal: 34,
        proteinas: 2.8,
        carbohidratos: 7,
        grasas: 0.4,
      ),
      FoodItem(
        id: '9',
        nombre: 'Almendras',
        tipo: 'Grasas',
        categoria: 'Snacks',
        cantidadReferencia: 100,
        kcal: 579,
        proteinas: 21,
        carbohidratos: 22,
        grasas: 50,
      ),
      FoodItem(
        id: '10',
        nombre: 'Yogur griego',
        tipo: 'Proteínas',
        categoria: 'Snacks',
        cantidadReferencia: 100,
        kcal: 59,
        proteinas: 10,
        carbohidratos: 3.6,
        grasas: 0.4,
      ),
    ];
    print('Alimentos de ejemplo cargados: ${_foods.length} alimentos');
    saveFoods(); // Guardamos los alimentos de ejemplo
  }

  // Método para inicializar el provider (llamado desde el constructor)
  Future<void> initialize() async {
    await loadFoods();
  }

  FoodProvider() {
    initialize();
  }

  // Método para limpiar todos los datos guardados (útil para debugging)
  Future<void> clearSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('foods');
      print('Datos de alimentos eliminados');
    } catch (e) {
      print('Error eliminando datos de alimentos: $e');
    }
  }

  // Método para recargar alimentos de ejemplo
  Future<void> reloadSampleFoods() async {
    _loadSampleFoods();
    notifyListeners();
  }
}