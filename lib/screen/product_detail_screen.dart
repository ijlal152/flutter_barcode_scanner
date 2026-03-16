import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildNameSection(),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildBarcodeSection(),
                  ),
                  const SizedBox(height: 20),
                  if (product.nutriscore.isNotEmpty ||
                      product.ecoScore.isNotEmpty)
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _buildScoresSection(),
                    ),
                  if (product.nutriments.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildNutrimentsSection(),
                    ),
                  ],
                  if (product.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: _buildIngredientsSection(),
                    ),
                  ],
                  if (product.labels.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: _buildLabelsSection(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: _buildMetaSection(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: product.imageUrl.isNotEmpty ? 320 : 120,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0F),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.5),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: product.barcode));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Barcode copied to clipboard'),
                backgroundColor: const Color(0xFF6C63FF),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.5),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const Icon(
              Icons.copy_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: product.imageUrl.isNotEmpty
            ? _buildHeroImage()
            : _buildFallbackHeader(),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: product.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[900]!,
            highlightColor: Colors.grey[800]!,
            child: Container(color: Colors.grey[900]),
          ),
          errorWidget: (_, __, ___) => _buildFallbackHeader(),
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFF0A0A0F).withOpacity(0.8),
                const Color(0xFF0A0A0F),
              ],
              stops: const [0.4, 0.8, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.3),
            const Color(0xFF00D4FF).withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          size: 64,
          color: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
                ),
              ),
              child: Text(
                product.brand,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _GrayPill(text: product.category),
            if (product.quantity.isNotEmpty) ...[
              const SizedBox(width: 8),
              _GrayPill(text: product.quantity),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildBarcodeSection() {
    return _SectionCard(
      icon: Icons.qr_code_rounded,
      title: 'Barcode',
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Barcode Number', style: _labelStyle),
                const SizedBox(height: 4),
                Text(
                  product.barcode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF6C63FF).withOpacity(0.15),
            ),
            child: const Icon(
              Icons.barcode_reader,
              color: Color(0xFF6C63FF),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresSection() {
    return Row(
      children: [
        if (product.nutriscore.isNotEmpty)
          Expanded(
            child: _ScoreCard(
              score: product.nutriscore.toUpperCase(),
              title: 'Nutriscore',
              color: _nutriscoreColor(product.nutriscore),
            ),
          ),
        if (product.nutriscore.isNotEmpty && product.ecoScore.isNotEmpty)
          const SizedBox(width: 12),
        if (product.ecoScore.isNotEmpty)
          Expanded(
            child: _ScoreCard(
              score: product.ecoScore.toUpperCase(),
              title: product.ecoScore.isNotEmpty ? 'Ecoscore' : 'EcoScore',
              color: _ecoscoreColor(product.ecoScore),
            ),
          ),
      ],
    );
  }

  Widget _buildNutrimentsSection() {
    return _SectionCard(
      title: 'Nutriments (per 100g)',
      icon: Icons.monitor_heart_rounded,
      child: Column(
        children: product.nutriments.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: _labelStyle),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                  ),
                  child: Text(
                    e.value,
                    style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return _SectionCard(
      icon: Icons.science_rounded,
      title: 'Ingredients',
      child: Text(
        product.ingredients,
        style: TextStyle(
          fontSize: 13,
          height: 1.7,
          color: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildLabelsSection() {
    return _SectionCard(
      icon: Icons.verified_rounded,
      title: 'Labels',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: product.labels.map((label) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00D4FF).withOpacity(0.4),
              ),
              color: const Color(0xFF00D4FF).withOpacity(0.08),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 12,
                  color: const Color(0xFF00D4FF).withOpacity(0.8),
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF00D4FF).withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetaSection() {
    final rows = <Map<String, String>>[];
    if (product.countries.isNotEmpty)
      rows.add({'Countries': product.countries});
    if (product.stores.isNotEmpty) rows.add({'Stores': product.stores});
    if (product.packaging.isNotEmpty)
      rows.add({'Packaging': product.packaging});

    if (rows.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      icon: Icons.info_rounded,
      title: 'Additional Info',
      child: Column(
        children: rows.map((row) {
          final key = row.keys.first;
          final value = row[key]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(key, style: _labelStyle),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  TextStyle get _labelStyle => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white.withOpacity(0.35),
    letterSpacing: 0.8,
    textBaseline: TextBaseline.alphabetic,
  );

  Color _nutriscoreColor(String score) {
    switch (score.toLowerCase()) {
      case 'a':
        return const Color(0xFF1DB954);
      case 'b':
        return const Color(0xFF90C43B);
      case 'c':
        return const Color(0xFFFFC107);
      case 'd':
        return const Color(0xFFFF8C00);
      case 'e':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  Color _ecoscoreColor(String score) {
    switch (score.toLowerCase()) {
      case 'a':
        return const Color(0xFF1DB954);
      case 'b':
        return const Color(0xFF90C43B);
      case 'c':
        return const Color(0xFFFFC107);
      case 'd':
        return const Color(0xFFFF8C00);
      case 'e':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF6C63FF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6C63FF),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String title;
  final String score;
  final Color color;

  const _ScoreCard({
    required this.title,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color,
            ),
            child: Center(
              child: Text(
                score,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrayPill extends StatelessWidget {
  final String text;
  const _GrayPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.07),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
      ),
    );
  }
}
