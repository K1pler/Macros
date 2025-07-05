import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores para los campos de macros para actualizarlos desde el provider
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  
  // Controladores para los campos del perfil
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _deficitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores con los datos del provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAllControllers();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Escuchar cambios en el provider para actualizar los TextFields
    context.watch<ProfileProvider>().addListener(_updateAllControllers);
    // Carga inicial
    _updateAllControllers();
  }

  void _updateAllControllers() {
    final provider = context.read<ProfileProvider>();
    final profile = provider.profile;
    
    // Actualizar controladores de macros
    final distribution = profile.macroDistribution;
    _proteinController.text = distribution['protein']!.toStringAsFixed(0);
    _carbsController.text = distribution['carbs']!.toStringAsFixed(0);
    _fatController.text = distribution['fat']!.toStringAsFixed(0);
    
    // Actualizar controladores del perfil
    _ageController.text = profile.age?.toString() ?? '';
    _weightController.text = profile.weight?.toString() ?? '';
    _heightController.text = profile.height?.toString() ?? '';
    _deficitController.text = profile.deficit.toStringAsFixed(0);
  }

  void _updateMacroControllers() {
    final provider = context.read<ProfileProvider>();
    final distribution = provider.profile.macroDistribution;
    _proteinController.text = distribution['protein']!.toStringAsFixed(0);
    _carbsController.text = distribution['carbs']!.toStringAsFixed(0);
    _fatController.text = distribution['fat']!.toStringAsFixed(0);
  }

  @override
  void dispose() {
    context.read<ProfileProvider>().removeListener(_updateAllControllers);
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _deficitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildDataCard(context, profile, profileProvider),
        const SizedBox(height: 16),
        _buildMacrosCard(context, profileProvider),
        const SizedBox(height: 16),
        _buildResultsCard(context, profileProvider),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            profileProvider.saveGoals();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('¡Objetivos guardados!'),
                  backgroundColor: Colors.green),
            );
          },
          child: const Text('Guardar Objetivos'),
        ),
      ],
    );
  }

  Card _buildDataCard(BuildContext context, profile, ProfileProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tus Datos", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildTextField(label: 'Edad (años)', controller: _ageController, onChanged: (v) => provider.updateProfileField('age', v), keyboardType: TextInputType.number),
            _buildTextField(label: 'Peso (kg)', controller: _weightController, onChanged: (v) => provider.updateProfileField('weight', v), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            _buildTextField(label: 'Altura (cm)', controller: _heightController, onChanged: (v) => provider.updateProfileField('height', v), keyboardType: TextInputType.number),
            _buildDropdownField(label: "Sexo", value: profile.sex, items: {'male': 'Hombre', 'female': 'Mujer'}, onChanged: (v) => provider.updateProfileField('sex', v)),
            _buildDropdownField(label: "Nivel de Actividad", value: profile.activityFactor, items: {1.2: 'Sedentario', 1.375: 'Ejercicio Ligero', 1.55: 'Ejercicio Moderado', 1.725: 'Ejercicio Fuerte', 1.9: 'Ejercicio Muy Fuerte'}, onChanged: (v) => provider.updateProfileField('activity', v)),
            _buildTextField(label: 'Déficit/Superávit (kcal)', controller: _deficitController, onChanged: (v) => provider.updateProfileField('deficit', v), keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Card _buildMacrosCard(BuildContext context, ProfileProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Distribución de Macros", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: "Distribución Predefinida",
              value: 'custom',
              items: {
                'custom': 'Personalizado',
                'balanced': 'Equilibrado (40C/30P/30G)',
                'high-protein': 'Alto en Proteínas (30C/40P/30G)',
                'low-carb': 'Bajo en Carbohidratos (20C/40P/40G)'
              },
              onChanged: (v) => provider.setMacroPreset(v!),
            ),
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Prot. (%)', controller: _proteinController, onChanged: (v) => provider.updateProfileField('protein', v), keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: _buildTextField(label: 'Carb. (%)', controller: _carbsController, onChanged: (v) => provider.updateProfileField('carbs', v), keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: _buildTextField(label: 'Grasas (%)', controller: _fatController, onChanged: (v) => provider.updateProfileField('fat', v), keyboardType: TextInputType.number)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card _buildResultsCard(BuildContext context, ProfileProvider provider) {
    final macroGrams = provider.macroGrams;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Resultados Calculados", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _infoTile("TMB (Metabolismo Basal)", "${provider.bmr.toStringAsFixed(0)} kcal"),
            _infoTile("GET (Gasto Energético Total)", "${provider.tdee.toStringAsFixed(0)} kcal"),
            const Divider(height: 24, color: Colors.white24),
            Text("Objetivo Calórico Final", style: Theme.of(context).textTheme.titleMedium),
            Text("${provider.finalCalories.toStringAsFixed(0)} kcal", style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.red[400], fontWeight: FontWeight.bold)),
            const Divider(height: 24, color: Colors.white24),
            _infoTile("Proteínas", "${macroGrams['protein']!.toStringAsFixed(1)} g"),
            _infoTile("Carbohidratos", "${macroGrams['carbs']!.toStringAsFixed(1)} g"),
            _infoTile("Grasas", "${macroGrams['fat']!.toStringAsFixed(1)} g"),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, String? initialValue, TextEditingController? controller, required Function(String) onChanged, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            controller: controller,
            decoration: const InputDecoration(),
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({required String label, required T value, required Map<T, String> items, required Function(T?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            decoration: const InputDecoration(),
            value: value,
            items: items.entries.map((entry) {
              return DropdownMenuItem<T>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}