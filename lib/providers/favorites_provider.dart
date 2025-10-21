import 'package:flutter/material.dart';
import '../models/recipe.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Recipe> _favorites = [];

  List<Recipe> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String id) {
    return _favorites.any((recipe) => recipe.id == id);
  }

  void toggleFavorite(Recipe recipe) {
    if (isFavorite(recipe.id)) {
      _favorites.removeWhere((r) => r.id == recipe.id);
    } else {
      _favorites.add(recipe);
    }
    notifyListeners();
  }
}
