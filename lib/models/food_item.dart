// Modelo que representa un alimento con sus valores nutricionales
class FoodItem {
  // ID único del alimento
  final String id;
  // Nombre del alimento
  final String nombre;
  // Tipo o categoría del alimento (ej: "Proteínas", "Carbohidratos", etc.)
  final String tipo;
  // Cantidad de referencia en gramos (ej: 100g)
  final double cantidadReferencia;
  // Calorías por cantidad de referencia
  final double kcal;
  // Gramos de proteínas por cantidad de referencia
  final double proteinas;
  // Gramos de carbohidratos por cantidad de referencia
  final double carbohidratos;
  // Gramos de grasas por cantidad de referencia
  final double grasas;

  // Constructor del alimento
  FoodItem({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.cantidadReferencia,
    required this.kcal,
    required this.proteinas,
    required this.carbohidratos,
    required this.grasas,
  });

  // Función para crear un FoodItem desde un JSON
  // Esto permite importar alimentos desde archivos JSON
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      // Generamos un ID único combinando timestamp y nombre
      id: DateTime.now().millisecondsSinceEpoch.toString() + (json['nombre'] ?? ''),
      // Nombre del alimento, con valor por defecto si no existe
      nombre: json['nombre'] ?? 'Sin nombre',
      // Tipo del alimento, con valor por defecto si no existe
      tipo: json['tipo'] ?? 'General',
      // Cantidad de referencia, por defecto 100g
      cantidadReferencia: (json['cantidad_referencia'] as num? ?? 100.0).toDouble(),
      // Calorías, por defecto 0
      kcal: (json['kcal'] as num? ?? 0.0).toDouble(),
      // Proteínas, por defecto 0
      proteinas: (json['proteinas'] as num? ?? 0.0).toDouble(),
      // Carbohidratos, por defecto 0
      carbohidratos: (json['carbohidratos'] as num? ?? 0.0).toDouble(),
      // Grasas, por defecto 0
      grasas: (json['grasas'] as num? ?? 0.0).toDouble(),
    );
  }
}