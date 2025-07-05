import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/log_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/macro_progress_indicator.dart';
import '../models/log_entry.dart';
import '../models/user_profile.dart';

// Pantalla que permite registrar los alimentos consumidos en un día específico
class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

// Estado de la pantalla del registro diario
class _DailyLogScreenState extends State<DailyLogScreen> {
  // Fecha seleccionada para el registro (por defecto hoy)
  DateTime _selectedDate = DateTime.now();
  // ID del alimento seleccionado para añadir
  String? _selectedFoodId;
  // Controlador para el campo de cantidad
  final _quantityController = TextEditingController();

  // Función para mostrar el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), // Fecha mínima permitida
      lastDate: DateTime(2101),  // Fecha máxima permitida
    );
    // Si el usuario seleccionó una fecha diferente, actualizamos el estado
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Función para añadir un alimento al registro del día
  void _addFoodLog(BuildContext context) {
    final logProvider = context.read<LogProvider>();
    // Convertimos el texto de cantidad a número
    final quantity = double.tryParse(_quantityController.text);
    
    // Verificamos que se haya seleccionado un alimento y la cantidad sea válida
    if (_selectedFoodId != null && quantity != null && quantity > 0) {
      // Añadimos el alimento al registro
      logProvider.addFoodToLog(_selectedDate, _selectedFoodId!, quantity);
      // Limpiamos los campos del formulario
      setState(() {
        _selectedFoodId = null;
        _quantityController.clear();
      });
      // Ocultamos el teclado
      FocusScope.of(context).unfocus();
    } else {
      // Mostramos un mensaje de error si los datos no son válidos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecciona un alimento y una cantidad válida.'),
            backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los providers para acceder a los datos
    final foodProvider = context.watch<FoodProvider>();
    final logProvider = context.watch<LogProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    
    // Obtenemos los objetivos del perfil
    final goals = profileProvider.goals;
    
    // Obtenemos el registro del día seleccionado
    final dailyLog = logProvider.getLogForDate(_selectedDate);
    
    // Calculamos los totales de macronutrientes para el día
    final totals = logProvider.getTotalsForDate(_selectedDate, foodProvider.foods);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Tarjeta para seleccionar fecha y añadir alimentos
        _buildAddFoodCard(context, foodProvider),
        const SizedBox(height: 16),
        // Tarjeta con el resumen de macronutrientes del día
        _buildSummaryCard(context, totals, goals),
        const SizedBox(height: 16),
        // Tarjeta con la lista de alimentos consumidos
        _buildDailyLogList(context, dailyLog, foodProvider),
      ],
    );
  }

  // Widget que permite añadir alimentos al registro
  Card _buildAddFoodCard(BuildContext context, FoodProvider foodProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Text("Añadir Alimento", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Selector de fecha
            Row(
              children: [
                Expanded(
                  child: Text("Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}"),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Cambiar Fecha'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Selector de alimento
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Alimento'),
              value: _selectedFoodId,
              items: foodProvider.foods.map((food) {
                return DropdownMenuItem<String>(
                  value: food.id,
                  child: Text(food.nombre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFoodId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Campo de cantidad
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Cantidad (g)',
                hintText: 'Ej: 100',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Botón para añadir el alimento
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addFoodLog(context),
                child: const Text('Añadir al Registro'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget que muestra el resumen de macronutrientes del día
  Card _buildSummaryCard(BuildContext context, Map<String, double> totals, UserGoals goals) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Título del resumen
            Text("Resumen del Día", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Indicadores de progreso para cada macronutriente
            MacroProgressIndicator(
              label: "Calorías",
              consumed: totals['kcal']!,
              goal: goals.calories,
              unit: 'kcal',
            ),
            MacroProgressIndicator(
              label: "Proteínas",
              consumed: totals['proteinas']!,
              goal: goals.protein,
              unit: 'g',
            ),
            MacroProgressIndicator(
              label: "Carbs",
              consumed: totals['carbohidratos']!,
              goal: goals.carbs,
              unit: 'g',
            ),
            MacroProgressIndicator(
              label: "Grasas",
              consumed: totals['grasas']!,
              goal: goals.fat,
              unit: 'g',
            ),
          ],
        ),
      ),
    );
  }

  // Widget que muestra la lista de alimentos consumidos en el día
  Card _buildDailyLogList(BuildContext context, List<LogEntry> dailyLog, FoodProvider foodProvider) {
    final logProvider = context.read<LogProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la lista
            Text("Consumo del Día", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            
            // Si no hay alimentos registrados, mostramos un mensaje
            if (dailyLog.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No hay alimentos registrados.")))
            else
              // Lista de alimentos consumidos
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dailyLog.length,
                itemBuilder: (ctx, index) {
                  final entry = dailyLog[index];
                  try {
                    // Buscamos el alimento correspondiente
                    final food = foodProvider.foods.firstWhere((f) => f.id == entry.foodId);
                    return ListTile(
                      title: Text(food.nombre),
                      subtitle: Text("${entry.quantity.toStringAsFixed(0)} g"),
                      // Botón para eliminar la entrada
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => logProvider.deleteLogEntry(_selectedDate, entry.id),
                      ),
                    );
                  } catch (e) {
                    // Si el alimento no se encuentra (puede haber sido eliminado)
                    return ListTile(
                      title: const Text("Alimento no encontrado"),
                      subtitle: const Text("Este alimento pudo haber sido borrado."),
                       trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => logProvider.deleteLogEntry(_selectedDate, entry.id),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}