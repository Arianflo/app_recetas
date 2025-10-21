import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool showImage;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: showImage
            ? Image.network(
                recipe.strMealThumb,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : null,
        title: Text(recipe.strMeal),
        subtitle: Text(recipe.strCategory ?? ''),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: onFavorite,
        ),
        onTap: onTap,
      ),
    );
  }
}
