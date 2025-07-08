import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../models/food_item.dart';

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

  // Función para cargar un ejemplo JSON con categorías
  void _loadExampleJson() {
    const exampleJson = '''[
  {
    "nombre": "Avena con Leche",
    "tipo": "Cereal",
    "categoria": "Desayuno",
    "cantidad_referencia": 100,
    "kcal": 389,
    "proteinas": 17,
    "carbohidratos": 66,
    "grasas": 7
  },
  {
    "nombre": "Huevos Revueltos",
    "tipo": "Proteínas",
    "categoria": "Desayuno",
    "cantidad_referencia": 100,
    "kcal": 155,
    "proteinas": 13,
    "carbohidratos": 1.1,
    "grasas": 11
  },
  {
    "nombre": "Pollo a la Plancha",
    "tipo": "Proteínas",
    "categoria": "Almuerzo",
    "cantidad_referencia": 100,
    "kcal": 165,
    "proteinas": 31,
    "carbohidratos": 0,
    "grasas": 3.6
  },
  {
    "nombre": "Arroz Integral",
    "tipo": "Carbohidratos",
    "categoria": "Almuerzo",
    "cantidad_referencia": 100,
    "kcal": 111,
    "proteinas": 2.6,
    "carbohidratos": 23,
    "grasas": 0.9
  },
  {
    "nombre": "Salmón al Horno",
    "tipo": "Proteínas",
    "categoria": "Cena",
    "cantidad_referencia": 100,
    "kcal": 208,
    "proteinas": 25,
    "carbohidratos": 0,
    "grasas": 12
  },
  {
    "nombre": "Ensalada Verde",
    "tipo": "Vegetales",
    "categoria": "Cena",
    "cantidad_referencia": 100,
    "kcal": 20,
    "proteinas": 2,
    "carbohidratos": 4,
    "grasas": 0.2
  },
  {
    "nombre": "Manzana",
    "tipo": "Frutas",
    "categoria": "Snacks",
    "cantidad_referencia": 100,
    "kcal": 52,
    "proteinas": 0.3,
    "carbohidratos": 14,
    "grasas": 0.2
  },
  {
    "nombre": "Almendras",
    "tipo": "Frutos Secos",
    "categoria": "Snacks",
    "cantidad_referencia": 100,
    "kcal": 579,
    "proteinas": 21,
    "carbohidratos": 22,
    "grasas": 50
  }
]''';
    
    _jsonController.text = exampleJson;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ejemplo JSON cargado. Puedes modificarlo o añadirlo directamente.'),
        backgroundColor: Colors.blue,
      ),
    );
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
            const SizedBox(height: 8),
            // Texto explicativo
            Text(
              "Pega un array de objetos JSON con los datos nutricionales de los alimentos. Cada alimento debe incluir: nombre, tipo, categoria, cantidad_referencia (en gramos), kcal, proteínas, carbohidratos y grasas.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            
            // Campo de texto para el JSON
            TextFormField(
              controller: _jsonController,
              decoration: const InputDecoration(
                labelText: 'JSON de Alimentos',
                hintText: '''Ejemplo de formato:
[
  {
    "nombre": "Arroz Blanco Cocido",
    "tipo": "Cereal",
    "categoria": "Almuerzo",
    "cantidad_referencia": 100,
    "kcal": 130,
    "proteinas": 2.7,
    "carbohidratos": 28,
    "grasas": 0.3
  }
]''',
                alignLabelWithHint: true,
              ),
              maxLines: 15, // Aumentamos las líneas para mostrar el ejemplo completo
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            
            // Botones de acción
            Row(
              children: [
                // Botón para limpiar el campo
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _jsonController.clear();
                      FocusScope.of(context).unfocus();
                    },
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 16),
                // Botón para añadir los alimentos
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addFoods(context),
                    child: const Text('Añadir Alimentos'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Botón para cargar ejemplo
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _loadExampleJson(),
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Cargar Ejemplo con Categorías'),
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
              // Lista de alimentos organizados por categorías
              _buildFoodListByCategories(foodProvider.foods, foodProvider),
          ],
        ),
      ),
    );
  }

  // Widget que construye la lista de alimentos organizados por categorías
  Widget _buildFoodListByCategories(List<FoodItem> foods, FoodProvider foodProvider) {
    // Agrupamos los alimentos por categoría
    Map<String, List<FoodItem>> foodsByCategory = {};
    
    for (var food in foods) {
      if (!foodsByCategory.containsKey(food.categoria)) {
        foodsByCategory[food.categoria] = [];
      }
      foodsByCategory[food.categoria]!.add(food);
    }
    
    // Ordenamos las categorías para una mejor presentación
    List<String> categoryOrder = ['Desayuno', 'Almuerzo', 'Cena', 'Snacks', 'General'];
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _getTotalCategoryItems(foodsByCategory, categoryOrder),
      itemBuilder: (ctx, index) {
        return _buildCategoryItem(index, foodsByCategory, categoryOrder, foodProvider);
      },
    );
  }

  // Calcula el total de elementos incluyendo los headers de categorías
  int _getTotalCategoryItems(Map<String, List<FoodItem>> foodsByCategory, List<String> categoryOrder) {
    int total = 0;
    
    // Contamos las categorías en el orden predefinido
    for (String category in categoryOrder) {
      if (foodsByCategory.containsKey(category)) {
        total += 1 + foodsByCategory[category]!.length; // 1 para el header + alimentos
      }
    }
    
    // Contamos las categorías que no están en el orden predefinido
    for (String category in foodsByCategory.keys) {
      if (!categoryOrder.contains(category)) {
        total += 1 + foodsByCategory[category]!.length; // 1 para el header + alimentos
      }
    }
    
    return total;
  }

  // Construye un elemento de la lista (puede ser header de categoría o alimento)
  Widget _buildCategoryItem(int index, Map<String, List<FoodItem>> foodsByCategory, List<String> categoryOrder, FoodProvider foodProvider) {
    int currentIndex = 0;
    
    // Procesamos las categorías en el orden predefinido
    for (String category in categoryOrder) {
      if (foodsByCategory.containsKey(category)) {
        if (index == currentIndex) {
          // Es el header de la categoría
          return _buildCategoryHeader(category);
        }
        currentIndex++;
        
        // Procesamos los alimentos de esta categoría
        for (var food in foodsByCategory[category]!) {
          if (index == currentIndex) {
            // Es un alimento
            return _buildFoodItem(food, foodProvider);
          }
          currentIndex++;
        }
      }
    }
    
    // Procesamos las categorías que no están en el orden predefinido
    for (String category in foodsByCategory.keys) {
      if (!categoryOrder.contains(category)) {
        if (index == currentIndex) {
          // Es el header de la categoría
          return _buildCategoryHeader(category);
        }
        currentIndex++;
        
        // Procesamos los alimentos de esta categoría
        for (var food in foodsByCategory[category]!) {
          if (index == currentIndex) {
            // Es un alimento
            return _buildFoodItem(food, foodProvider);
          }
          currentIndex++;
        }
      }
    }
    
    return const SizedBox.shrink(); // No debería llegar aquí
  }

  // Widget para el header de una categoría
  Widget _buildCategoryHeader(String category) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.category, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Text(
            category,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para un elemento de alimento
  Widget _buildFoodItem(FoodItem food, FoodProvider foodProvider) {
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
  }
}