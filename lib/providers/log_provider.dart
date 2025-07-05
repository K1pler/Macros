import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_entry.dart';
import '../models/food_item.dart';

class LogProvider with ChangeNotifier {
  final Map<String, List<LogEntry>> _dailyLogs = {};

  List<LogEntry> getLogForDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return _dailyLogs[dateKey] ?? [];
  }

  void addFoodToLog(DateTime date, String foodId, double quantity) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    if (_dailyLogs[dateKey] == null) {
      _dailyLogs[dateKey] = [];
    }
    _dailyLogs[dateKey]!.add(LogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        foodId: foodId,
        quantity: quantity));
    notifyListeners();
  }
  
  void deleteLogEntry(DateTime date, String entryId) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    if (_dailyLogs[dateKey] != null) {
      _dailyLogs[dateKey]!.removeWhere((entry) => entry.id == entryId);
      notifyListeners();
    }
  }
  
  Map<String, double> getTotalsForDate(DateTime date, List<FoodItem> allFoods) {
    final entries = getLogForDate(date);
    Map<String, double> totals = {'kcal': 0, 'proteinas': 0, 'carbohidratos': 0, 'grasas': 0};
    
    for (var entry in entries) {
      try {
        final food = allFoods.firstWhere((f) => f.id == entry.foodId);
        final multiplier = entry.quantity / food.cantidadReferencia;
        totals['kcal'] = (totals['kcal'] ?? 0) + food.kcal * multiplier;
        totals['proteinas'] = (totals['proteinas'] ?? 0) + food.proteinas * multiplier;
        totals['carbohidratos'] = (totals['carbohidratos'] ?? 0) + food.carbohidratos * multiplier;
        totals['grasas'] = (totals['grasas'] ?? 0) + food.grasas * multiplier;
      } catch (e) {
        // Ignora si un alimento del log ya no existe en la BD principal
      }
    }
    return totals;
  }
}