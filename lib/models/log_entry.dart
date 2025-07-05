// Modelo que representa una entrada en el registro diario de alimentos
class LogEntry {
  // ID único de la entrada
  final String id;
  // ID del alimento consumido (referencia a FoodItem)
  final String foodId;
  // Cantidad consumida en gramos
  final double quantity;

  // Constructor de la entrada del registro
  LogEntry({
    required this.id,
    required this.foodId,
    required this.quantity,
  });
}