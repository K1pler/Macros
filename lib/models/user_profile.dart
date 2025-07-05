// Modelo que representa el perfil de un usuario con sus datos personales
class UserProfile {
  // Sexo del usuario ('male' o 'female')
  String sex;
  // Edad del usuario en años
  int? age;
  // Peso del usuario en kilogramos
  double? weight;
  // Altura del usuario en centímetros
  double? height;
  // Factor de actividad física (1.2 = sedentario, 1.9 = muy activo)
  double activityFactor;
  // Déficit calórico objetivo (calorías a reducir para perder peso)
  double deficit;
  // Distribución de macronutrientes en porcentajes
  Map<String, double> macroDistribution;

  // Constructor del perfil con valores por defecto
  UserProfile({
    this.sex = 'male',
    this.age,
    this.weight,
    this.height,
    this.activityFactor = 1.2, // Sedentario por defecto
    this.deficit = 0, // Sin déficit por defecto
    Map<String, double>? macroDistribution,
  }) : macroDistribution = macroDistribution ?? {
    // Distribución equilibrada por defecto: 30% proteínas, 40% carbohidratos, 30% grasas
    'protein': 30,
    'carbs': 40,
    'fat': 30
  };

  // Convierte el perfil a formato JSON para guardarlo
  Map<String, dynamic> toJson() {
    return {
      'sex': sex,
      'age': age,
      'weight': weight,
      'height': height,
      'activityFactor': activityFactor,
      'deficit': deficit,
      'macroDistribution': macroDistribution,
    };
  }

  // Crea un perfil desde un JSON (para cargar datos guardados)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      sex: json['sex'] ?? 'male',
      age: json['age'],
      weight: json['weight'],
      height: json['height'],
      activityFactor: json['activityFactor'] ?? 1.2,
      deficit: json['deficit'] ?? 0,
      // Convertimos el mapa de distribución de macros
      macroDistribution: json['macroDistribution'] != null 
        ? Map<String, double>.from(json['macroDistribution'])
        : null,
    );
  }
}

// Modelo que representa los objetivos nutricionales del usuario
class UserGoals {
  // Calorías objetivo por día
  final double calories;
  // Gramos de proteína objetivo por día
  final double protein;
  // Gramos de carbohidratos objetivo por día
  final double carbs;
  // Gramos de grasa objetivo por día
  final double fat;

  // Constructor de objetivos con valores por defecto
  UserGoals({this.calories = 0, this.protein = 0, this.carbs = 0, this.fat = 0});

  // Convierte los objetivos a formato JSON para guardarlos
  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  // Crea objetivos desde un JSON (para cargar datos guardados)
  factory UserGoals.fromJson(Map<String, dynamic> json) {
    return UserGoals(
      calories: json['calories']?.toDouble() ?? 0,
      protein: json['protein']?.toDouble() ?? 0,
      carbs: json['carbs']?.toDouble() ?? 0,
      fat: json['fat']?.toDouble() ?? 0,
    );
  }
}