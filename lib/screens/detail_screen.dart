import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/favorites_provider.dart';

class DetailScreen extends StatelessWidget {
  final Recipe recipe;
  const DetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.strMeal),
        actions: [
          IconButton(
            icon: Icon(
              favProvider.isFavorite(recipe.idMeal) // <-- aquí va el id
              ? Icons.favorite
              : Icons.favorite_border,
              ),
              onPressed: () => favProvider.toggleFavorite(recipe), // aquí sigue pasando el objeto completo
              tooltip: 'Añadir a favoritos',
              )


        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.strMealThumb.isNotEmpty)
              Center(
                  child: Image.network(
                recipe.strMealThumb,
                fit: BoxFit.cover,
              )),
            const SizedBox(height: 12),
            Text(
              'Categoría: ${recipe.strCategory ?? 'Desconocida'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Origen: ${recipe.strArea ?? 'Desconocido'}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            const Text(
              'Instrucciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(recipe.strInstructions ?? ''),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Compartir (demo)')),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Compartir receta'),
            )
          ],
        ),
      ),
    );
  }
}
