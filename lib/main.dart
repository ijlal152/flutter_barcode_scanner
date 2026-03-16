import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/screen/home_screen.dart';
import 'package:provider/provider.dart';
import 'services/product_service.dart';
import 'models/product_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const BarcodeScannerApp(),
    ),
  );
}

// ─── App State ────────────────────────────────────────────────────────────────
class AppState extends ChangeNotifier {
  ProductModel? _product;
  bool _isLoading = false;
  String? _error;
  List<ProductModel> _history = [];

  ProductModel? get product => _product;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProductModel> get history => _history;

  Future<void> fetchProduct(String barcode) async {
    _isLoading = true;
    _error = null;
    _product = null;
    notifyListeners();

    try {
      final result = await ProductService.fetchProduct(barcode);
      if (result != null) {
        _product = result;
        // Add to history (avoid duplicates)
        _history.removeWhere((p) => p.barcode == barcode);
        _history.insert(0, result);
        if (_history.length > 20) _history.removeLast();
      } else {
        _error = 'Product not found in database.\nBarcode: $barcode';
      }
    } catch (e) {
      _error = 'Network error. Please check your connection.\n$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProduct() {
    _product = null;
    _error = null;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}

// ─── App Root ─────────────────────────────────────────────────────────────────
class BarcodeScannerApp extends StatelessWidget {
  const BarcodeScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
      ),
      home: const HomeScreen(),
    );
  }
}
