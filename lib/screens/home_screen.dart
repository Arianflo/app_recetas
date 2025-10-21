import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/recipe.dart';
import 'detail_screen.dart';
import '../providers/favorites_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // 0: recetas, 1: favoritos
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showImages = true;
  late Future<List<Recipe>> _futureRecipes;

  // NUEVAS VARIABLES PARA FILTROS
  List<String> _categories = ['Todos'];
  List<String> _areas = ['Todos'];
  String _selectedCategory = 'Todos';
  String _selectedArea = 'Todos';

  @override
  void initState() {
    super.initState();
    _futureRecipes = ApiService.fetchRecipes('a');

    // Cargar categorías y áreas
    ApiService.fetchCategories().then((cats) {
      setState(() {
        _categories.addAll(cats);
      });
    });
    ApiService.fetchAreas().then((areas) {
      setState(() {
        _areas.addAll(areas);
      });
    });
  }

  // MODIFICADO para usar filtros
  void _search() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _futureRecipes = ApiService.fetchRecipes(
        _searchController.text,
        category: _selectedCategory == 'Todos' ? null : _selectedCategory,
        area: _selectedArea == 'Todos' ? null : _selectedArea,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App de Recetas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showImages ? Icons.image : Icons.image_not_supported),
            onPressed: () {
              setState(() {
                _showImages = !_showImages;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildSearchForm(),
            const SizedBox(height: 12),
            Expanded(
              child: _currentIndex == 0
                  ? _buildRecipeList(favProvider)
                  : _buildFavoritesList(favProvider),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Recetas'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // FORMULARIO DE BÚSQUEDA + FILTROS
  Widget _buildSearchForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar receta',
                    hintText: 'Ej: chicken, beef, pasta',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _search(),
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty) &&
                        _selectedCategory == 'Todos' &&
                        _selectedArea == 'Todos') {
                      return 'Escribe algo o selecciona un filtro';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _search, child: const Text('Buscar')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val!;
                      _searchController.clear();
                      _futureRecipes = ApiService.fetchRecipes(
                        '',
                        category:
                            _selectedCategory == 'Todos' ? null : _selectedCategory,
                        area: _selectedArea == 'Todos' ? null : _selectedArea,
                      );
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedArea,
                  items: _areas
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedArea = val!;
                      _searchController.clear();
                      _futureRecipes = ApiService.fetchRecipes(
                        '',
                        category:
                            _selectedCategory == 'Todos' ? null : _selectedCategory,
                        area: _selectedArea == 'Todos' ? null : _selectedArea,
                      );
                    });
                  },
                  decoration: const InputDecoration(labelText: 'País'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(FavoritesProvider favProvider) {
    return FutureBuilder<List<Recipe>>(
      future: _futureRecipes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron recetas'));
        }

        final recipes = snapshot.data!;
        return ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            final isFav = favProvider.isFavorite(recipe.idMeal);
            return _buildRecipeTile(recipe, isFav, favProvider);
          },
        );
      },
    );
  }

  Widget _buildFavoritesList(FavoritesProvider favProvider) {
    if (favProvider.favorites.isEmpty) {
      return const Center(child: Text('No tienes recetas favoritas'));
    }
    return ListView.builder(
      itemCount: favProvider.favorites.length,
      itemBuilder: (context, index) {
        final recipe = favProvider.favorites[index];
        return _buildRecipeTile(recipe, true, favProvider);
      },
    );
  }

  Widget _buildRecipeTile(
      Recipe recipe, bool isFav, FavoritesProvider favProvider) {
    return Card(
      child: ListTile(
        leading: _showImages
            ? Image.network(
                recipe.strMealThumb,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              )
            : null,
        title: Text(recipe.strMeal),
        subtitle: Text(recipe.strCategory ?? ''),
        trailing: IconButton(
          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : null),
          onPressed: () => favProvider.toggleFavorite(recipe),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(recipe: recipe)),
          );
        },
      ),
    );
  }
}
