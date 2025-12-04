import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/interest_model.dart';

class InterestsService {
  static InterestsService? _instance;
  static InterestsService get instance {
    _instance ??= InterestsService._();
    return _instance!;
  }

  InterestsService._();

  List<Interest> _allInterests = [];
  Map<String, List<Interest>> _interestsByCategory = {};
  bool _isLoaded = false;

  /// Carga los intereses desde el archivo JSON
  Future<void> loadInterests() async {
    if (_isLoaded) return;

    try {
      // Cargar el archivo JSON desde assets
      final String jsonString = await rootBundle.loadString(
        'assets/interests.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _interestsByCategory.clear();
      _allInterests.clear();

      // Procesar cada categoría
      jsonData.forEach((category, interestsList) {
        final List<Interest> categoryInterests = [];

        for (var interestData in interestsList) {
          final interest = Interest.fromJson(interestData, category);
          categoryInterests.add(interest);
          _allInterests.add(interest);
        }

        _interestsByCategory[category] = categoryInterests;
      });

      _isLoaded = true;
      print('✅ Loaded ${_allInterests.length} interests from JSON');
    } catch (e) {
      print('❌ Error loading interests: $e');
      rethrow;
    }
  }

  /// Obtiene todos los intereses
  List<Interest> getAllInterests() {
    if (!_isLoaded) {
      throw Exception('Interests not loaded. Call loadInterests() first.');
    }
    return List.unmodifiable(_allInterests);
  }

  /// Obtiene los intereses por categoría
  Map<String, List<Interest>> getInterestsByCategory() {
    if (!_isLoaded) {
      throw Exception('Interests not loaded. Call loadInterests() first.');
    }
    return Map.unmodifiable(_interestsByCategory);
  }

  /// Obtiene los nombres de las categorías
  List<String> getCategories() {
    if (!_isLoaded) {
      throw Exception('Interests not loaded. Call loadInterests() first.');
    }
    return _interestsByCategory.keys.toList();
  }

  /// Busca un interés por nombre
  Interest? findInterestByName(String name) {
    try {
      return _allInterests.firstWhere(
        (interest) => interest.nombre.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Convierte una lista de nombres de intereses a objetos Interest
  List<Interest> convertNamesToInterests(List<String> names) {
    final List<Interest> interests = [];
    for (final name in names) {
      final interest = findInterestByName(name);
      if (interest != null) {
        interests.add(interest);
      }
    }
    return interests;
  }

  /// Convierte una lista de objetos Interest a nombres
  List<String> convertInterestsToNames(List<Interest> interests) {
    return interests.map((interest) => interest.nombre).toList();
  }
}
