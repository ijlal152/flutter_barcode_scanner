class ProductModel {
  final String barcode;
  final String name;
  final String brand;
  final String category;
  final String imageUrl;
  final String quantity;
  final String ingredients;
  final String nutriscore;
  final String ecoScore;
  final Map<String, String> nutriments;
  final List<String> labels;
  final String countries;
  final String stores;
  final String packaging;

  ProductModel({
    required this.barcode,
    this.name = 'Unknown Product',
    this.brand = 'Unknown Brand',
    this.category = 'Unknown Category',
    this.imageUrl = '',
    this.quantity = '',
    this.ingredients = '',
    this.nutriscore = '',
    this.ecoScore = '',
    this.nutriments = const {},
    this.labels = const [],
    this.countries = '',
    this.stores = '',
    this.packaging = '',
  });

  factory ProductModel.fromOpenFoodFacts(
    Map<String, dynamic> json,
    String barcode,
  ) {
    final product = json['product'] as Map<String, dynamic>? ?? {};

    // Parse nutriments
    final Map<String, String> nutrimentsParsed = {};
    final rawNutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    final keys = [
      'energy-kcal_100g',
      'fat_100g',
      'carbohydrates_100g',
      'proteins_100g',
      'salt_100g',
      'sugars_100g',
      'fiber_100g',
    ];
    final labels = [
      'Energy (kcal)',
      'Fat',
      'Carbs',
      'Proteins',
      'Salt',
      'Sugars',
      'Fiber',
    ];
    for (int i = 0; i < keys.length; i++) {
      if (rawNutriments.containsKey(keys[i])) {
        final val = rawNutriments[keys[i]];
        nutrimentsParsed[labels[i]] = '${val}g';
      }
    }

    // Parse labels list
    final labelsList = <String>[];
    final rawLabels = product['labels_tags'] as List<dynamic>? ?? [];
    for (final label in rawLabels.take(5)) {
      final cleaned = label
          .toString()
          .replaceAll('en:', '')
          .replaceAll('-', ' ');
      labelsList.add(_capitalize(cleaned));
    }

    return ProductModel(
      barcode: barcode,
      name:
          product['product_name'] ??
          product['product_name_en'] ??
          'Unknown Product',
      brand: product['brands'] ?? 'Unknown Brand',
      category: _parseCategory(
        product['categories'] ?? product['categories_en'] ?? '',
      ),
      imageUrl: product['image_front_url'] ?? product['image_url'] ?? '',
      quantity: product['quantity'] ?? '',
      ingredients:
          product['ingredients_text'] ?? product['ingredients_text_en'] ?? '',
      nutriscore: product['nutriscore_grade'] ?? '',
      ecoScore: product['ecoscore_grade'] ?? '',
      nutriments: nutrimentsParsed,
      labels: labelsList,
      countries: product['countries'] ?? '',
      stores: product['stores'] ?? '',
      packaging: product['packaging'] ?? '',
    );
  }

  static String _parseCategory(String raw) {
    if (raw.isEmpty) return 'General';
    final parts = raw.split(',');
    final last = parts.last.trim().replaceAll('en:', '').replaceAll('-', ' ');
    return _capitalize(last);
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
