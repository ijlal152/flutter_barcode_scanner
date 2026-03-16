// ignore_for_file: deprecated_member_use

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'product_detail_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Background gradient mesh
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildBody(context)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildScanButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00D4FF).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: FadeInDown(
        duration: const Duration(milliseconds: 600),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Scanner',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Scan any barcode instantly',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            Consumer<AppState>(
              builder: (context, state, _) {
                return state.history.isNotEmpty
                    ? _HistoryBadge(count: state.history.length)
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.isLoading) return _buildLoadingState();
        if (state.error != null) return _buildErrorState(state.error!, context);
        if (state.product != null) {
          return _buildProductPreview(context, state.product!);
        }
        if (state.history.isNotEmpty) return _buildHistory(context, state);
        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.3),
                    const Color(0xFF00D4FF).withOpacity(0.3),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 52,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No product scanned yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the scan button below to\nstart scanning product barcodes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 40),
            // Supported format chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                'EAN-13',
                'EAN-8',
                'QR Code',
                'UPC-A',
                'Code 128',
                'Data Matrix',
              ].map((f) => _FormatChip(label: f)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF6C63FF),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Fetching product details...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Searching global databases',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 38,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Product Not Found',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 32),
              _GlassButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onTap: () => context.read<AppState>().clearProduct(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductPreview(BuildContext context, product) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => _openDetail(context, product),
          child: _ProductCard(product: product),
        ),
      ),
    );
  }

  Widget _buildHistory(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FadeInLeft(
                child: Text(
                  'Scan History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              TextButton(
                onPressed: state.clearHistory,
                child: Text(
                  'Clear',
                  style: TextStyle(color: Colors.redAccent.withOpacity(0.8)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final product = state.history[index];
              return FadeInUp(
                delay: Duration(milliseconds: index * 60),
                child: GestureDetector(
                  onTap: () => _openDetail(context, product),
                  child: _HistoryCard(product: product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FadeInUp(
        duration: const Duration(milliseconds: 700),
        child: GestureDetector(
          onTap: () => _openScanner(context),
          child: Container(
            width: 200,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Scan Barcode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openScanner(BuildContext context) async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (barcode != null && context.mounted) {
      context.read<AppState>().fetchProduct(barcode);
    }
  }

  void _openDetail(BuildContext context, product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }
}

// ─── Sub-components ───────────────────────────────────────────────────────────

class _FormatChip extends StatelessWidget {
  final String label;
  const _FormatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
      ),
    );
  }
}

class _HistoryBadge extends StatelessWidget {
  final int count;
  const _HistoryBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF6C63FF).withOpacity(0.2),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4)),
      ),
      child: Text(
        '$count scanned',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6C63FF),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5)),
          color: const Color(0xFF6C63FF).withOpacity(0.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6C63FF)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          if (product.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderImage(),
              ),
            )
          else
            _PlaceholderImage(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  product.brand,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF6C63FF).withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _InfoPill(text: product.category),
                    if (product.quantity.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _InfoPill(text: product.quantity),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Tap to see full details',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final dynamic product;
  const _HistoryCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          if (product.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _SmallPlaceholder(),
              ),
            )
          else
            _SmallPlaceholder(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.brand,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String text;
  const _InfoPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.07),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.07),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        color: Colors.white.withOpacity(0.2),
        size: 34,
      ),
    );
  }
}

class _SmallPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.07),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        color: Colors.white.withOpacity(0.2),
        size: 22,
      ),
    );
  }
}
