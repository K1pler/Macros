class UserProfile {
  String sex;
  int? age;
  double? weight;
  double? height;
  double activityFactor;
  double deficit;
  Map<String, double> macroDistribution;

  UserProfile({
    this.sex = 'male',
    this.age,
    this.weight,
    this.height,
    this.activityFactor = 1.2,
    this.deficit = 0,
    Map<String, double>? macroDistribution,
  }) : macroDistribution = macroDistribution ?? {
    'protein': 30,
    'carbs': 40,
    'fat': 30
  };

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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      sex: json['sex'] ?? 'male',
      age: json['age'],
      weight: json['weight'],
      height: json['height'],
      activityFactor: json['activityFactor'] ?? 1.2,
      deficit: json['deficit'] ?? 0,
      macroDistribution: json['macroDistribution'] != null 
        ? Map<String, double>.from(json['macroDistribution'])
        : null,
    );
  }
}

class UserGoals {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  UserGoals({this.calories = 0, this.protein = 0, this.carbs = 0, this.fat = 0});

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory UserGoals.fromJson(Map<String, dynamic> json) {
    return UserGoals(
      calories: json['calories']?.toDouble() ?? 0,
      protein: json['protein']?.toDouble() ?? 0,
      carbs: json['carbs']?.toDouble() ?? 0,
      fat: json['fat']?.toDouble() ?? 0,
    );
  }
}