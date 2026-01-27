import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'card_analysis_page.dart';

class CardDetailPage extends StatelessWidget {
  final WalletCard card;

  const CardDetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Center(child: _buildVerticalCard(context)),
              const SizedBox(height: 10),
              Text(card.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 6),
              Text('${card.maskedNumber} 본인', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 18),

              // Month selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chevron_left, size: 28, color: Colors.white),
                        const SizedBox(width: 6),
                        Text('01월', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                    Text('2025년 02월', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                    Row(
                      children: [
                        Text('03월', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right, size: 28, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Rounded white card area with semicircle chart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      // semicircle chart
                      SemicircleChart(percent: 0.7, received: 23000, total: 33000),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFF15C1D6))),
                                    const SizedBox(width: 8),
                                    Text('내가 받은 혜택', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
                                  ],
                                ),
                                Text(_formatWon(23000), style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFF8B5CF6))),
                                    const SizedBox(width: 8),
                                    Text('이 카드의 총 혜택', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
                                  ],
                                ),
                                Text(_formatWon(33000), style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                              ],
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.5;
    final height = width * 1.6;

    if (card.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          card.imagePath!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _fallbackCard(width, height),
        ),
      );
    }

    return _fallbackCard(width, height);
  }

  Widget _fallbackCard(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: card.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card, size: 56, color: Colors.white.withOpacity(0.9)),
          const SizedBox(height: 16),
          Text(card.bankName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  static String _formatWon(int value) {
    final s = value.toString();
    final out = s.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',');
    return '$out원';
  }
}

class SemicircleChart extends StatelessWidget {
  final double percent; // 0..1
  final int received;
  final int total;

  const SemicircleChart({super.key, required this.percent, required this.received, required this.total});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 64;
    final height = 160.0;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(width, height),
            painter: _SemicirclePainter(
              percent: percent,
              background: Colors.grey.shade200,
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFF0A8A96),
                  Color(0xFF15C1D6),
                  Color(0xFF6DEDF2),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('받은 혜택', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 6),
              Text(_formatWonStatic(received), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatWonStatic(int value) {
    final s = value.toString();
    final out = s.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',');
    return '$out원';
  }
}

class _SemicirclePainter extends CustomPainter {
  final double percent;
  final Color background;
  final Gradient gradient;

  _SemicirclePainter({required this.percent, required this.background, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height);
    final stroke = 24.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // draw full semicircle background (180 degrees)
    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    // draw foreground proportional arc from left to right (차오르는 그라데이션)
    final sweep = math.pi * (percent.clamp(0.0, 1.0));
    canvas.drawArc(rect, math.pi, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _SemicirclePainter oldDelegate) => oldDelegate.percent != percent;
}
