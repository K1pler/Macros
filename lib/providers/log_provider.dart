import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_entry.dart';
import '../models/food_item.dart';

// Provider que gestiona el registro diario de alimentos consumidos
class LogProvider with ChangeNotifier {
  // Mapa que almacena los registros por fecha
  // La clave es la fecha en formato 'yyyy-MM-dd' y el valor es la lista de entradas
  final Map<String, List<LogEntry>> _dailyLogs = {};

  // Obtiene todas las entradas del registro para una fecha específica
  List<LogEntry> getLogForDate(DateTime date) {
    // Convertimos la fecha a string en formato 'yyyy-MM-dd'
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    // Devolvemos la lista de entradas para esa fecha, o una lista vacía si no hay
    return _dailyLogs[dateKey] ?? [];
  }

  // Añade un alimento al registro diario
  void addFoodToLog(DateTime date, String foodId, double quantity) {
    // Convertimos la fecha a string en formato 'yyyy-MM-dd'
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    
    // Si no existe una lista para esa fecha, la creamos
    if (_dailyLogs[dateKey] == null) {
      _dailyLogs[dateKey] = [];
    }
    
    // Creamos una nueva entrada en el registro
    _dailyLogs[dateKey]!.add(LogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID único basado en timestamp
        foodId: foodId, // ID del alimento consumido
        quantity: quantity)); // Cantidad consumida en gramos
    
    // Notificamos a todos los widgets que escuchan este provider
    notifyListeners();
  }
  
  // Elimina una entrada específica del registro
  void deleteLogEntry(DateTime date, String entryId) {
    // Convertimos la fecha a string en formato 'yyyy-MM-dd'
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    
    // Si existe una lista para esa fecha, eliminamos la entrada
    if (_dailyLogs[dateKey] != null) {
      _dailyLogs[dateKey]!.removeWhere((entry) => entry.id == entryId);
      // Notificamos a todos los widgets que escuchan este provider
      notifyListeners();
    }
  }
  
  // Calcula los totales de macronutrientes para una fecha específica
  Map<String, double> getTotalsForDate(DateTime date, List<FoodItem> allFoods) {
    // Obtenemos todas las entradas para esa fecha
    final entries = getLogForDate(date);
    // Inicializamos los totales en 0
    Map<String, double> totals = {'kcal': 0, 'proteinas': 0, 'carbohidratos': 0, 'grasas': 0};
    
    // Recorremos cada entrada del registro
    for (var entry in entries) {
      try {
        // Buscamos el alimento correspondiente en la lista de alimentos
        final food = allFoods.firstWhere((f) => f.id == entry.foodId);
        
        // Calculamos el multiplicador basado en la cantidad consumida
        // dividida por la cantidad de referencia del alimento
        final multiplier = entry.quantity / food.cantidadReferencia;
        
        // Sumamos los macronutrientes multiplicados por el factor
        totals['kcal'] = (totals['kcal'] ?? 0) + food.kcal * multiplier;
        totals['proteinas'] = (totals['proteinas'] ?? 0) + food.proteinas * multiplier;
        totals['carbohidratos'] = (totals['carbohidratos'] ?? 0) + food.carbohidratos * multiplier;
        totals['grasas'] = (totals['grasas'] ?? 0) + food.grasas * multiplier;
      } catch (e) {
        // Si no encontramos el alimento (puede haber sido eliminado), lo ignoramos
        // Ignora si un alimento del log ya no existe en la BD principal
      }
    }
    return totals;
  }
}