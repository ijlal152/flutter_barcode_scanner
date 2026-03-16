import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductService {
  // Open Food Facts (food, beverages, cosmetics)
  static const String _openFoodFactsUrl =
      'https://world.openfoodfacts.org/api/v2/product';

  // Open Beauty Facts (cosmetics, perfumes)
  static const String _openBeautyFactsUrl =
      'https://world.openbeautyfacts.org/api/v2/product';

  // Open Products Facts (general products)
  static const String _openProductsFactsUrl =
      'https://world.openproductsfacts.org/api/v2/product';

  static Future<ProductModel?> fetchProduct(String barcode) async {
    // Try each API in sequence
    final apis = [
      _openFoodFactsUrl,
      _openBeautyFactsUrl,
      _openProductsFactsUrl,
    ];

    for (final apiUrl in apis) {
      try {
        final result = await _fetchFromApi(apiUrl, barcode);
        if (result != null) return result;
      } catch (e) {
        continue;
      }
    }

    return null;
  }

  static Future<ProductModel?> _fetchFromApi(
    String baseUrl,
    String barcode,
  ) async {
    final url = Uri.parse('$baseUrl/$barcode.json');
    final response = await http
        .get(
          url,
          headers: {
            'User-Agent': 'BarcodeScannerApp/1.0 (Flutter)',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'];

      // status 1 = found, status "success" = found
      if (status == 1 || status == 'success') {
        final product = data['product'] as Map<String, dynamic>?;
        if (product != null && product.isNotEmpty) {
          // Validate that the product has at least a name
          final name =
              product['product_name'] ?? product['product_name_en'] ?? '';
          if (name.toString().isNotEmpty) {
            return ProductModel.fromOpenFoodFacts(data, barcode);
          }
        }
      }
    }
    return null;
  }
}
