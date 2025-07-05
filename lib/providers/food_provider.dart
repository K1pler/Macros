import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/food_item.dart';

class FoodProvider with ChangeNotifier {
  List<FoodItem> _foods = [];

  List<FoodItem> get foods => _foods;

  String addFoodsFromJson(String jsonString) {
    if (jsonString.isEmpty) return "Error: El JSON no puede estar vacío.";
    try {
      final List<dynamic> data = json.decode(jsonString);
      int successCount = 0;
      for (var item in data) {
        if (item is Map<String, dynamic>) {
          _foods.add(FoodItem.fromJson(item));
          successCount++;
        }
      }
      notifyListeners();
      return "$successCount alimento(s) añadido(s) con éxito.";
    } catch (e) {
      return "Error: JSON inválido o formato incorrecto.";
    }
  }

  void deleteFood(String foodId) {
    _foods.removeWhere((food) => food.id == foodId);
    notifyListeners();
  }
}