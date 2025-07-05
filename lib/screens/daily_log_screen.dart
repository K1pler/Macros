import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/log_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/macro_progress_indicator.dart';
import '../models/log_entry.dart';
import '../models/user_profile.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedFoodId;
  final _quantityController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addFoodLog(BuildContext context) {
    final logProvider = context.read<LogProvider>();
    final quantity = double.tryParse(_quantityController.text);
    if (_selectedFoodId != null && quantity != null && quantity > 0) {
      logProvider.addFoodToLog(_selectedDate, _selectedFoodId!, quantity);
      setState(() {
        _selectedFoodId = null;
        _quantityController.clear();
      });
      FocusScope.of(context).unfocus(); // Oculta el teclado
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecciona un alimento y una cantidad válida.'),
            backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final logProvider = context.watch<LogProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final dailyLog = logProvider.getLogForDate(_selectedDate);
    final dailyTotals = logProvider.getTotalsForDate(_selectedDate, foodProvider.foods);
    final goals = profileProvider.goals;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSummaryCard(context, dailyTotals, goals),
        const SizedBox(height: 16),
        _buildAddFoodCard(context, foodProvider),
        const SizedBox(height: 16),
        _buildDailyLogList(context, dailyLog, foodProvider),
      ],
    );
  }

  Card _buildAddFoodCard(BuildContext context, FoodProvider foodProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}",
                    style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () => _selectDate(context)),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFoodId,
              hint: const Text('Selecciona un alimento'),
              isExpanded: true,
              items: foodProvider.foods.map((food) {
                return DropdownMenuItem(
                    value: food.id, child: Text(food.nombre));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFoodId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: "Cantidad (g)"),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addFoodLog(context),
                child: const Text("Añadir al Registro"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildSummaryCard(BuildContext context, Map<String, double> totals, UserGoals goals) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Resumen del Día", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
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

  Card _buildDailyLogList(BuildContext context, List<LogEntry> dailyLog, FoodProvider foodProvider) {
    final logProvider = context.read<LogProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Consumo del Día", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (dailyLog.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No hay alimentos registrados.")))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dailyLog.length,
                itemBuilder: (ctx, index) {
                  final entry = dailyLog[index];
                  try {
                    final food = foodProvider.foods.firstWhere((f) => f.id == entry.foodId);
                    return ListTile(
                      title: Text(food.nombre),
                      subtitle: Text("${entry.quantity.toStringAsFixed(0)} g"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => logProvider.deleteLogEntry(_selectedDate, entry.id),
                      ),
                    );
                  } catch (e) {
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