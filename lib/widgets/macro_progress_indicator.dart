import 'package:flutter/material.dart';

// Widget personalizado que muestra el progreso de un macronutriente
// (calorías, proteínas, carbohidratos, grasas) con una barra de progreso
class MacroProgressIndicator extends StatelessWidget {
    // Etiqueta del macronutriente (ej: "Calorías", "Proteínas")
    final String label;
    // Cantidad consumida
    final double consumed;
    // Cantidad objetivo
    final double goal;
    // Unidad de medida (ej: "kcal", "g")
    final String unit;

    // Constructor del widget
    const MacroProgressIndicator({
        super.key,
        required this.label, 
        required this.consumed, 
        required this.goal,
        required this.unit,
    });
    
    @override
    Widget build(BuildContext context) {
        // Calculamos el porcentaje de progreso
        final percentage = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
        
        // Determinamos el color de la barra de progreso
        Color progressColor;
        if (percentage >= 1.0) {
            // Si se alcanzó o superó el objetivo, color verde
            progressColor = Colors.green;
        } else if (percentage >= 0.8) {
            // Si está cerca del objetivo, color amarillo
            progressColor = Colors.orange;
        } else {
            // Si está lejos del objetivo, color rojo
            progressColor = Colors.red;
        }

        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Fila con la etiqueta y los valores
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            // Etiqueta del macronutriente
                            Text(label, style: const TextStyle(fontSize: 16)),
                            // Valores consumidos vs objetivo
                            Text(
                                "${consumed.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)} $unit",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                        ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Barra de progreso
                    LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[600],
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 8,
                    ),
                    
                    // Porcentaje de progreso
                    const SizedBox(height: 4),
                    Text(
                        "${(percentage * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                            fontSize: 12,
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                        ),
                    ),
                ],
            ),
        );
    }
}