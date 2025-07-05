import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';

class FoodRegistryScreen extends StatefulWidget {
  const FoodRegistryScreen({super.key});

  @override
  State<FoodRegistryScreen> createState() => _FoodRegistryScreenState();
}

class _FoodRegistryScreenState extends State<FoodRegistryScreen> {
  final _jsonController = TextEditingController();

  void _addFoods(BuildContext context) {
    if (_jsonController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El campo JSON no puede estar vacío.'), backgroundColor: Colors.orange),
        );
        return;
    }
    final foodProvider = context.read<FoodProvider>();
    final result = foodProvider.addFoodsFromJson(_jsonController.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        backgroundColor: result.startsWith("Error") ? Colors.orange : Colors.green,
      ),
    );
    
    if (!result.startsWith("Error")) {
      _jsonController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Añadir Alimento(s) (JSON)", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Pega un array de objetos JSON. Ej: [{"nombre": "Pollo", ...}]',
                  style: Theme.of(context).textTheme.bodySmall
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jsonController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Pega el JSON aquí...',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addFoods(context),
                    child: const Text("Registrar desde JSON"),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Alimentos Registrados", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (foodProvider.foods.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("No hay alimentos en la base de datos.")))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: foodProvider.foods.length,
                    itemBuilder: (ctx, index) {
                      final food = foodProvider.foods[index];
                      return ListTile(
                        title: Text(food.nombre),
                        subtitle: Text("${food.kcal.toStringAsFixed(0)} kcal por ${food.cantidadReferencia.toStringAsFixed(0)}g"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () async {
                             final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                    title: const Text("Confirmar borrado"),
                                    content: Text("¿Seguro que quieres borrar '${food.nombre}'?"),
                                    actions: [
                                        TextButton(onPressed: ()=> Navigator.of(ctx).pop(false), child: const Text("Cancelar")),
                                        TextButton(onPressed: ()=> Navigator.of(ctx).pop(true), child: const Text("Borrar")),
                                    ]
                                )
                             );
                             if (confirm == true) {
                                foodProvider.deleteFood(food.id);
                             }
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}