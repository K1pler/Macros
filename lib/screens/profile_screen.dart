import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

// Pantalla que permite configurar el perfil del usuario y ver los cálculos nutricionales
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Estado de la pantalla de perfil
class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores para los campos de macros (para actualizarlos desde el provider)
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
    // Inicializamos los controladores con los datos del provider
    // Usamos addPostFrameCallback para asegurar que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAllControllers();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Escuchamos cambios en el provider para actualizar los TextFields automáticamente
    context.watch<ProfileProvider>().addListener(_updateAllControllers);
    // Carga inicial de los controladores
    _updateAllControllers();
  }

  // Función para actualizar todos los controladores con los datos del provider
  void _updateAllControllers() {
    final provider = context.read<ProfileProvider>();
    final profile = provider.profile;
    
    // Actualizamos controladores de macros
    final distribution = profile.macroDistribution;
    _proteinController.text = distribution['protein']!.toStringAsFixed(0);
    _carbsController.text = distribution['carbs']!.toStringAsFixed(0);
    _fatController.text = distribution['fat']!.toStringAsFixed(0);
    
    // Actualizamos controladores del perfil
    _ageController.text = profile.age?.toString() ?? '';
    _weightController.text = profile.weight?.toString() ?? '';
    _heightController.text = profile.height?.toString() ?? '';
    _deficitController.text = profile.deficit.toStringAsFixed(0);
  }

  @override
  void dispose() {
    // Removemos el listener para evitar memory leaks
    context.read<ProfileProvider>().removeListener(_updateAllControllers);
    // Liberamos los controladores
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
    // Obtenemos el provider de perfil para acceder a los datos
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Tarjeta con los datos personales del usuario
        _buildDataCard(context, profile, profileProvider),
        const SizedBox(height: 16),
        // Tarjeta con la distribución de macronutrientes
        _buildMacrosCard(context, profileProvider),
        const SizedBox(height: 16),
        // Tarjeta con los resultados calculados
        _buildResultsCard(context, profileProvider),
        const SizedBox(height: 24),
        // Botón para guardar los objetivos
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

  // Widget que muestra los datos personales del usuario
  Card _buildDataCard(BuildContext context, profile, ProfileProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Text("Tus Datos", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Campo de edad
            _buildTextField(
              label: 'Edad (años)', 
              controller: _ageController, 
              onChanged: (v) => provider.updateProfileField('age', v), 
              keyboardType: TextInputType.number
            ),
            
            // Campo de peso
            _buildTextField(
              label: 'Peso (kg)', 
              controller: _weightController, 
              onChanged: (v) => provider.updateProfileField('weight', v), 
              keyboardType: const TextInputType.numberWithOptions(decimal: true)
            ),
            
            // Campo de altura
            _buildTextField(
              label: 'Altura (cm)', 
              controller: _heightController, 
              onChanged: (v) => provider.updateProfileField('height', v), 
              keyboardType: TextInputType.number
            ),
            
            // Selector de sexo
            _buildDropdownField(
              label: "Sexo", 
              value: profile.sex, 
              items: {'male': 'Hombre', 'female': 'Mujer'}, 
              onChanged: (v) => provider.updateProfileField('sex', v)
            ),
            
            // Selector de nivel de actividad
            _buildDropdownField(
              label: "Nivel de Actividad", 
              value: profile.activityFactor, 
              items: {
                1.2: 'Sedentario', 
                1.375: 'Ejercicio Ligero', 
                1.55: 'Ejercicio Moderado', 
                1.725: 'Ejercicio Fuerte', 
                1.9: 'Ejercicio Muy Fuerte'
              }, 
              onChanged: (v) => provider.updateProfileField('activity', v)
            ),
            
            // Campo de déficit/superávit
            _buildTextField(
              label: 'Déficit/Superávit (kcal)', 
              controller: _deficitController, 
              onChanged: (v) => provider.updateProfileField('deficit', v), 
              keyboardType: TextInputType.number
            ),
          ],
        ),
      ),
    );
  }

  // Widget que muestra la distribución de macronutrientes
  Card _buildMacrosCard(BuildContext context, ProfileProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Text("Distribución de Macros", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Selector de distribución predefinida
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
            
            // Campos para distribución personalizada
            Row(
              children: [
                // Campo de proteínas
                Expanded(child: _buildTextField(
                  label: 'Prot. (%)', 
                  controller: _proteinController, 
                  onChanged: (v) => provider.updateProfileField('protein', v), 
                  keyboardType: TextInputType.number
                )),
                const SizedBox(width: 8),
                // Campo de carbohidratos
                Expanded(child: _buildTextField(
                  label: 'Carb. (%)', 
                  controller: _carbsController, 
                  onChanged: (v) => provider.updateProfileField('carbs', v), 
                  keyboardType: TextInputType.number
                )),
                const SizedBox(width: 8),
                // Campo de grasas
                Expanded(child: _buildTextField(
                  label: 'Grasas (%)', 
                  controller: _fatController, 
                  onChanged: (v) => provider.updateProfileField('fat', v), 
                  keyboardType: TextInputType.number
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget que muestra los resultados calculados
  Card _buildResultsCard(BuildContext context, ProfileProvider provider) {
    // Obtenemos los gramos de cada macronutriente
    final macroGrams = provider.macroGrams;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Título de la sección
            Text("Resultados Calculados", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Metabolismo basal
            _infoTile("TMB (Metabolismo Basal)", "${provider.bmr.toStringAsFixed(0)} kcal"),
            // Gasto energético total
            _infoTile("GET (Gasto Energético Total)", "${provider.tdee.toStringAsFixed(0)} kcal"),
            
            const Divider(height: 24, color: Colors.white24),
            
            // Calorías objetivo final
            Text("Objetivo Calórico Final", style: Theme.of(context).textTheme.titleMedium),
            Text(
              "${provider.finalCalories.toStringAsFixed(0)} kcal", 
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.red[400], 
                fontWeight: FontWeight.bold
              )
            ),
            
            const Divider(height: 24, color: Colors.white24),
            
            // Gramos de cada macronutriente
            _infoTile("Proteínas", "${macroGrams['protein']!.toStringAsFixed(1)} g"),
            _infoTile("Carbohidratos", "${macroGrams['carbs']!.toStringAsFixed(1)} g"),
            _infoTile("Grasas", "${macroGrams['fat']!.toStringAsFixed(1)} g"),
          ],
        ),
      ),
    );
  }

  // Widget helper para crear campos de texto
  Widget _buildTextField({
    required String label, 
    String? initialValue, 
    TextEditingController? controller, 
    required Function(String) onChanged, 
    TextInputType? keyboardType
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta del campo
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          // Campo de texto
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

  // Widget helper para crear campos de selección desplegable
  Widget _buildDropdownField<T>({
    required String label, 
    required T value, 
    required Map<T, String> items, 
    required Function(T?) onChanged
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta del campo
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          // Campo de selección
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

  // Widget helper para mostrar información en formato título-valor
  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título
          Text(title, style: const TextStyle(fontSize: 16)),
          // Valor
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}