// lib/widgets/scanner_overlay.dart
// ============================================================
// Widget overlay untuk tampilan viewfinder scanner
// Kotak pemandu scan + animasi garis scan
// ============================================================

import 'package:flutter/material.dart';

class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key});

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double>   _scanLineAnim;

  @override
  void initState() {
    super.initState();
    // Animasi garis scan naik-turun terus
    _animController = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
      child: Center(
        child: SizedBox(
          width:  260,
          height: 260,
          child: AnimatedBuilder(
            animation: _scanLineAnim,
            builder:   (_, __) => Stack(
              children: [
                // ── Corner brackets ───────────────────────
                // Top-left
                Positioned(
                  top: 0, left: 0,
                  child: _buildCorner(
                    topLeft: true, topRight: false,
                    bottomLeft: false, bottomRight: false,
                  ),
                ),
                // Top-right
                Positioned(
                  top: 0, right: 0,
                  child: _buildCorner(
                    topLeft: false, topRight: true,
                    bottomLeft: false, bottomRight: false,
                  ),
                ),
                // Bottom-left
                Positioned(
                  bottom: 0, left: 0,
                  child: _buildCorner(
                    topLeft: false, topRight: false,
                    bottomLeft: true, bottomRight: false,
                  ),
                ),
                // Bottom-right
                Positioned(
                  bottom: 0, right: 0,
                  child: _buildCorner(
                    topLeft: false, topRight: false,
                    bottomLeft: false, bottomRight: true,
                  ),
                ),

                // ── Scan line animasi ─────────────────────
                Positioned(
                  top:  10 + (_scanLineAnim.value * 240),
                  left: 10, right: 10,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF3B82F6).withOpacity(0.8),
                          const Color(0xFF3B82F6),
                          const Color(0xFF3B82F6).withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Sudut kotak scanner
  Widget _buildCorner({
    required bool topLeft,
    required bool topRight,
    required bool bottomLeft,
    required bool bottomRight,
  }) {
    const size      = 28.0;
    const thickness = 3.5;
    const color     = Color(0xFF3B82F6);

    return SizedBox(
      width: size, height: size,
      child: Stack(children: [
        if (topLeft || bottomLeft)
          Positioned(
            left:   0,
            top:    topLeft    ? 0 : null,
            bottom: bottomLeft ? 0 : null,
            child:  Container(
              width:  thickness,
              height: size,
              color:  color,
            ),
          ),
        if (topRight || bottomRight)
          Positioned(
            right:  0,
            top:    topRight    ? 0 : null,
            bottom: bottomRight ? 0 : null,
            child:  Container(
              width:  thickness,
              height: size,
              color:  color,
            ),
          ),
        if (topLeft || topRight)
          Positioned(
            top:   0,
            left:  topLeft  ? 0 : null,
            right: topRight ? 0 : null,
            child: Container(
              width:  size,
              height: thickness,
              color:  color,
            ),
          ),
        if (bottomLeft || bottomRight)
          Positioned(
            bottom: 0,
            left:   bottomLeft  ? 0 : null,
            right:  bottomRight ? 0 : null,
            child:  Container(
              width:  size,
              height: thickness,
              color:  color,
            ),
          ),
      ]),
    );
  }
}

// Custom painter untuk overlay gelap di luar area scan
class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.62);

    const cutoutSize = 260.0;
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final left   = cx - cutoutSize / 2;
    final top    = cy - cutoutSize / 2;
    final right  = cx + cutoutSize / 2;
    final bottom = cy + cutoutSize / 2;

    // Gambar 4 area gelap di sekitar kotak scan
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top),         paint); // atas
    canvas.drawRect(Rect.fromLTRB(0, bottom, size.width, size.height), paint); // bawah
    canvas.drawRect(Rect.fromLTRB(0, top, left, bottom),           paint); // kiri
    canvas.drawRect(Rect.fromLTRB(right, top, size.width, bottom), paint); // kanan
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}