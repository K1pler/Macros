class FoodItem {
  final String id;
  final String nombre;
  final String tipo;
  final double cantidadReferencia;
  final double kcal;
  final double proteinas;
  final double carbohidratos;
  final double grasas;

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

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString() + (json['nombre'] ?? ''),
      nombre: json['nombre'] ?? 'Sin nombre',
      tipo: json['tipo'] ?? 'General',
      cantidadReferencia: (json['cantidad_referencia'] as num? ?? 100.0).toDouble(),
      kcal: (json['kcal'] as num? ?? 0.0).toDouble(),
      proteinas: (json['proteinas'] as num? ?? 0.0).toDouble(),
      carbohidratos: (json['carbohidratos'] as num? ?? 0.0).toDouble(),
      grasas: (json['grasas'] as num? ?? 0.0).toDouble(),
    );
  }
}