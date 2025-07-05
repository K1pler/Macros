import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile _profile = UserProfile();
  UserGoals _goals = UserGoals();
  double _bmr = 0;
  double _tdee = 0;

  ProfileProvider() {
    _loadProfileAndGoals();
  }

  UserProfile get profile => _profile;
  UserGoals get goals => _goals;
  double get bmr => _bmr;
  double get tdee => _tdee;
  double get finalCalories => _tdee - _profile.deficit;

  Map<String, double> get macroGrams {
    if (finalCalories <= 0) return {'protein': 0, 'carbs': 0, 'fat': 0};
    final proteinGrams = (finalCalories * (_profile.macroDistribution['protein']! / 100)) / 4;
    final carbsGrams = (finalCalories * (_profile.macroDistribution['carbs']! / 100)) / 4;
    final fatGrams = (finalCalories * (_profile.macroDistribution['fat']! / 100)) / 9;
    return {'protein': proteinGrams, 'carbs': carbsGrams, 'fat': fatGrams};
  }

  void updateProfileField(String field, dynamic value) {
    switch (field) {
      case 'sex': _profile.sex = value; break;
      case 'age': _profile.age = int.tryParse(value); break;
      case 'weight': _profile.weight = double.tryParse(value); break;
      case 'height': _profile.height = double.tryParse(value); break;
      case 'activity': _profile.activityFactor = value; break;
      case 'deficit': _profile.deficit = double.tryParse(value) ?? 0; break;
      case 'protein': _profile.macroDistribution['protein'] = double.tryParse(value) ?? 0; break;
      case 'carbs': _profile.macroDistribution['carbs'] = double.tryParse(value) ?? 0; break;
      case 'fat': _profile.macroDistribution['fat'] = double.tryParse(value) ?? 0; break;
    }
    _calculateBmrAndTdee();
    _saveProfile(); // Automatically save when profile is updated
    notifyListeners();
  }

  void setMacroPreset(String preset) {
    if (preset == 'custom') return;
    switch (preset) {
        case 'balanced':
            _profile.macroDistribution = {'protein': 30, 'carbs': 40, 'fat': 30};
            break;
        case 'high-protein':
            _profile.macroDistribution = {'protein': 40, 'carbs': 30, 'fat': 30};
            break;
        case 'low-carb':
            _profile.macroDistribution = {'protein': 40, 'carbs': 20, 'fat': 40};
            break;
    }
    _calculateBmrAndTdee();
    _saveProfile(); // Automatically save when macro preset is changed
    notifyListeners();
  }

  void _calculateBmrAndTdee() {
    if (_profile.age == null || _profile.weight == null || _profile.height == null) {
      _bmr = 0;
      _tdee = 0;
      return;
    }
    _bmr = (10 * _profile.weight!) + (6.25 * _profile.height!) - (5 * _profile.age!) + (_profile.sex == 'male' ? 5 : -161);
    _tdee = _bmr * _profile.activityFactor;
  }
  
  void saveGoals() {
    _goals = UserGoals(
      calories: finalCalories,
      protein: macroGrams['protein']!,
      carbs: macroGrams['carbs']!,
      fat: macroGrams['fat']!,
    );
    _saveGoals(); // Automatically save goals when they are updated
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(_profile.toJson()));
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_goals', jsonEncode(_goals.toJson()));
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      try {
        final Map<String, dynamic> profileData = jsonDecode(profileJson);
        _profile = UserProfile.fromJson(profileData);
        _calculateBmrAndTdee();
        notifyListeners();
      } catch (e) {
        // If there's an error loading the profile, keep the default one
        print('Error loading profile: $e');
      }
    }
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString('user_goals');
    if (goalsJson != null) {
      try {
        final Map<String, dynamic> goalsData = jsonDecode(goalsJson);
        _goals = UserGoals.fromJson(goalsData);
        notifyListeners();
      } catch (e) {
        // If there's an error loading the goals, keep the default one
        print('Error loading goals: $e');
      }
    }
  }

  Future<void> _loadProfileAndGoals() async {
    await _loadProfile();
    await _loadGoals();
  }
}