class Recipe {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;

  Recipe({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    this.strCategory,
    this.strArea,
    this.strInstructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      idMeal: json['idMeal'],
      strMeal: json['strMeal'],
      strMealThumb: json['strMealThumb'],
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
    );
  }

    String get id => idMeal; // <- este getter permite usar recipe.id
}

