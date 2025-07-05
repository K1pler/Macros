import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/food_item.dart';

// Provider que gestiona la lista de alimentos disponibles en la aplicación
class FoodProvider with ChangeNotifier {
  // Lista de todos los alimentos disponibles
  // ignore: prefer_final_fields
  List<FoodItem> _foods = [];

  // Getter para acceder a la lista de alimentos desde otros widgets
  List<FoodItem> get foods => _foods;

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
  }
}