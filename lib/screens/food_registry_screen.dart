import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';

// Pantalla que permite añadir alimentos a la base de datos desde JSON
class FoodRegistryScreen extends StatefulWidget {
  const FoodRegistryScreen({super.key});

  @override
  State<FoodRegistryScreen> createState() => _FoodRegistryScreenState();
}

// Estado de la pantalla del registro de alimentos
class _FoodRegistryScreenState extends State<FoodRegistryScreen> {
  // Controlador para el campo de texto JSON
  final _jsonController = TextEditingController();

  // Función para añadir alimentos desde JSON
  void _addFoods(BuildContext context) {
    // Verificamos que el campo JSON no esté vacío
    if (_jsonController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El campo JSON no puede estar vacío.'), backgroundColor: Colors.orange),
        );
        return;
    }
    
    // Obtenemos el provider de alimentos
    final foodProvider = context.read<FoodProvider>();
    // Intentamos añadir los alimentos desde el JSON
    final result = foodProvider.addFoodsFromJson(_jsonController.text);
    
    // Mostramos el resultado al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        backgroundColor: result.startsWith("Error") ? Colors.orange : Colors.green,
      ),
    );
    
    // Si la operación fue exitosa, limpiamos el campo
    if (!result.startsWith("Error")) {
      _jsonController.clear();
      // Ocultamos el teclado
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el provider de alimentos para mostrar la lista
    final foodProvider = context.watch<FoodProvider>();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Tarjeta para añadir alimentos desde JSON
        _buildAddFoodCard(context),
        const SizedBox(height: 16),
        // Tarjeta que muestra la lista de alimentos disponibles
        _buildFoodListCard(context, foodProvider),
      ],
    );
  }

  // Widget para añadir alimentos desde JSON
  Card _buildAddFoodCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Text("Añadir Alimentos desde JSON", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Campo de texto para el JSON
            TextFormField(
              controller: _jsonController,
              decoration: const InputDecoration(
                labelText: 'JSON de Alimentos',
                hintText: 'Pega aquí el JSON con los alimentos...',
              ),
              maxLines: 10, // Permite múltiples líneas
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            
            // Botón para añadir los alimentos
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addFoods(context),
                child: const Text('Añadir Alimentos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget que muestra la lista de alimentos disponibles
  Card _buildFoodListCard(BuildContext context, FoodProvider foodProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la lista
            Text("Alimentos Disponibles (${foodProvider.foods.length})", 
                 style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            
            // Si no hay alimentos, mostramos un mensaje
            if (foodProvider.foods.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No hay alimentos registrados.")))
            else
              // Lista de alimentos
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: foodProvider.foods.length,
                itemBuilder: (ctx, index) {
                  final food = foodProvider.foods[index];
                  return ListTile(
                    // Nombre del alimento
                    title: Text(food.nombre),
                    // Información nutricional del alimento
                    subtitle: Text(
                      "${food.kcal} kcal | P: ${food.proteinas}g | C: ${food.carbohidratos}g | G: ${food.grasas}g | ${food.cantidadReferencia}g"
                    ),
                    // Botón para eliminar el alimento
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => foodProvider.deleteFood(food.id),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}