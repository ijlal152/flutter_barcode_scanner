import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _scanned = false;
  bool _torchOn = false;
  late AnimationController _animController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final value = barcodes.first.rawValue;
      if (value != null && value.isNotEmpty) {
        _scanned = true;
        _controller.stop();
        Navigator.pop(context, value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Dark overlay with cutout
          CustomPaint(size: Size.infinite, painter: _ScannerOverlayPainter()),
          // Animated scan line
          _buildScanLine(),
          // Corner decorations
          _buildCornerDecorations(),
          // Top bar
          _buildTopBar(context),
          // Bottom controls
          _buildBottomControls(),
          // Info text
          _buildInfoText(),
        ],
      ),
    );
  }

  Widget _buildScanLine() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _lineAnimation,
        builder: (context, _) {
          final scanAreaTop = MediaQuery.of(context).size.height / 2 - 140;
          final scanAreaHeight = 280.0;
          final lineY = scanAreaTop + (_lineAnimation.value * scanAreaHeight);

          return Positioned(
            left: MediaQuery.of(context).size.width / 2 - 130,
            top: lineY,
            child: Container(
              width: 260,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF6C63FF).withOpacity(0.8),
                    const Color(0xFF00D4FF),
                    const Color(0xFF6C63FF).withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCornerDecorations() {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cx = constraints.maxWidth / 2;
          final cy = constraints.maxHeight / 2;
          const size = 130.0;
          const cornerSize = 24.0;
          const lineWidth = 3.0;
          const color = Color(0xFF6C63FF);

          return Stack(
            children: [
              // Top-left
              Positioned(
                left: cx - size,
                top: cy - size,
                child: _Corner(
                  position: CornerPosition.topLeft,
                  size: cornerSize,
                  lineWidth: lineWidth,
                  color: color,
                ),
              ),
              // Top-right
              Positioned(
                right: cx - size,
                top: cy - size,
                child: _Corner(
                  position: CornerPosition.topRight,
                  size: cornerSize,
                  lineWidth: lineWidth,
                  color: color,
                ),
              ),
              // Bottom-left
              Positioned(
                left: cx - size,
                bottom: cy - size,
                child: _Corner(
                  position: CornerPosition.bottomLeft,
                  size: cornerSize,
                  lineWidth: lineWidth,
                  color: color,
                ),
              ),
              // Bottom-right
              Positioned(
                right: cx - size,
                bottom: cy - size,
                child: _Corner(
                  position: CornerPosition.bottomRight,
                  size: cornerSize,
                  lineWidth: lineWidth,
                  color: color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
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
              const Expanded(
                child: Center(
                  child: Text(
                    'Scan Barcode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _controller.toggleTorch();
                  setState(() => _torchOn = !_torchOn);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _torchOn
                        ? const Color(0xFFFFC107).withOpacity(0.3)
                        : Colors.black.withOpacity(0.5),
                    border: Border.all(
                      color: _torchOn
                          ? const Color(0xFFFFC107)
                          : Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Icon(
                    _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _torchOn ? const Color(0xFFFFC107) : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
            );

            if (image != null) {
              final File imageFile = File(image.path);
              final result = await _controller.analyzeImage(imageFile.path);

              if (result?.barcodes.isNotEmpty ?? false) {
                final barcode = result!.barcodes.first.rawValue;
                if (barcode != null) {
                  print('Barcode found: $barcode');
                  // Handle the barcode result here
                } else {
                  print('No barcode found in the image.');
                }
              } else {
                print('No barcodes detected.');
              }
            } else {
              print('No image selected.');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_library_rounded,
                  size: 18,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Pick from Gallery',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Positioned(
      bottom: 130,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          'Position the barcode within the frame',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        ),
      ),
    );
  }
}

// ─── Scanner Overlay Painter ──────────────────────────────────────────────────

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.72)
      ..style = PaintingStyle.fill;

    const scanAreaWidth = 260.0;
    const scanAreaHeight = 280.0;
    final left = (size.width - scanAreaWidth) / 2;
    final top = (size.height - scanAreaHeight) / 2;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight),
          const Radius.circular(12),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Corner Widget ─────────────────────────────────────────────────────────────

enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class _Corner extends StatelessWidget {
  final CornerPosition position;
  final double size;
  final double lineWidth;
  final Color color;

  const _Corner({
    required this.position,
    required this.size,
    required this.lineWidth,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CornerPainter(position, lineWidth, color)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final CornerPosition position;
  final double lineWidth;
  final Color color;

  _CornerPainter(this.position, this.lineWidth, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    switch (position) {
      case CornerPosition.topLeft:
        path.moveTo(0, h);
        path.lineTo(0, 0);
        path.lineTo(w, 0);
        break;
      case CornerPosition.topRight:
        path.moveTo(0, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h);
        break;
      case CornerPosition.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, h);
        path.lineTo(w, h);
        break;
      case CornerPosition.bottomRight:
        path.moveTo(0, h);
        path.lineTo(w, h);
        path.lineTo(w, 0);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
