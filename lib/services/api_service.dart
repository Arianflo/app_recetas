import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  // Usamos TheMealDB: https://www.themealdb.com/api.php
  static const String _base = 'https://www.themealdb.com/api/json/v1/1';

  // Busca recetas por texto o por filtro de categoría/área
  static Future<List<Recipe>> fetchRecipes(String query,
      {String? category, String? area}) async {
    String url;
    if (category != null && category != 'Todos') {
      url = '$_base/filter.php?c=$category';
    } else if (area != null && area != 'Todos') {
      url = '$_base/filter.php?a=$area';
    } else {
      final q = (query.trim().isEmpty) ? 'a' : Uri.encodeComponent(query.trim());
      url = '$_base/search.php?s=$q';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error al obtener datos: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    if (data['meals'] == null) return [];
    final List meals = data['meals'];

    // Si usamos filter.php, solo vienen idMeal, strMeal, strMealThumb
    return meals.map((m) {
      return Recipe(
        idMeal: m['idMeal'],
        strMeal: m['strMeal'],
        strMealThumb: m['strMealThumb'],
        strCategory: m.containsKey('strCategory') ? m['strCategory'] : null,
        strArea: m.containsKey('strArea') ? m['strArea'] : null,
        strInstructions: m.containsKey('strInstructions') ? m['strInstructions'] : null,
      );
    }).toList();
  }

  // NUEVO: Trae todas las categorías
  static Future<List<String>> fetchCategories() async {
    final url = '$_base/list.php?c=list';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error al obtener categorías: ${response.statusCode}');
    }
    final data = json.decode(response.body);
    final List categories = data['meals'];
    return categories.map<String>((c) => c['strCategory'] as String).toList();
  }

  // NUEVO: Trae todas las áreas (países)
  static Future<List<String>> fetchAreas() async {
    final url = '$_base/list.php?a=list';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error al obtener áreas: ${response.statusCode}');
    }
    final data = json.decode(response.body);
    final List areas = data['meals'];
    return areas.map<String>((a) => a['strArea'] as String).toList();
  }
}
