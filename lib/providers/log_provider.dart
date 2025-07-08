import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_entry.dart';
import '../models/food_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Provider que gestiona el registro diario de alimentos consumidos
class LogProvider with ChangeNotifier {
  // Mapa que almacena los registros por fecha
  // La clave es la fecha en formato 'yyyy-MM-dd' y el valor es la lista de entradas
  final Map<String, List<LogEntry>> _dailyLogs = {};
  
  // Flag para indicar si los datos han sido cargados
  bool _isInitialized = false;

  // Getter para verificar si los datos están inicializados
  bool get isInitialized => _isInitialized;

  // Método para inicializar el provider (llamado desde el constructor)
  Future<void> initialize() async {
    await _loadLogs();
  }

  LogProvider() {
    initialize();
  }

  // Guarda los registros diarios en SharedPreferences
  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = json.encode(_dailyLogs.map((date, entries) => MapEntry(date, entries.map((e) => e.toJson()).toList())));
      await prefs.setString('dailyLogs', logsJson);
      print('Logs guardados exitosamente: ${_dailyLogs.length} días');
    } catch (e) {
      print('Error guardando logs: $e');
    }
  }

  // Carga los registros diarios desde SharedPreferences
  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString('dailyLogs');
      if (logsJson != null) {
        final Map<String, dynamic> data = json.decode(logsJson);
        _dailyLogs.clear();
        data.forEach((date, entries) {
          _dailyLogs[date] = (entries as List).map((e) => LogEntry.fromJson(e)).toList();
        });
        print('Logs cargados exitosamente: ${_dailyLogs.length} días');
      } else {
        print('No se encontraron logs guardados');
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error cargando logs: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Obtiene todas las entradas del registro para una fecha específica
  List<LogEntry> getLogForDate(DateTime date) {
    // Convertimos la fecha a string en formato 'yyyy-MM-dd'
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    // Devolvemos la lista de entradas para esa fecha, o una lista vacía si no hay
    return _dailyLogs[dateKey] ?? [];
  }

  // Añade un alimento al registro diario
  void addFoodToLog(DateTime date, String foodId, double quantity) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    if (_dailyLogs[dateKey] == null) {
      _dailyLogs[dateKey] = [];
    }
    _dailyLogs[dateKey]!.add(LogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        foodId: foodId,
        quantity: quantity));
    print('Alimento añadido al log: $foodId, cantidad: $quantity, fecha: $dateKey');
    notifyListeners();
    _saveLogs();
  }
  
  // Elimina una entrada específica del registro
  void deleteLogEntry(DateTime date, String entryId) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    if (_dailyLogs[dateKey] != null) {
      _dailyLogs[dateKey]!.removeWhere((entry) => entry.id == entryId);
      print('Entrada eliminada del log: $entryId, fecha: $dateKey');
      notifyListeners();
      _saveLogs();
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
        print('Alimento no encontrado en getTotalsForDate: ${entry.foodId}');
      }
    }
    return totals;
  }

  // Método para limpiar todos los datos guardados (útil para debugging)
  Future<void> clearSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('dailyLogs');
      _dailyLogs.clear();
      print('Datos de logs eliminados');
      notifyListeners();
    } catch (e) {
      print('Error eliminando datos de logs: $e');
    }
  }
}