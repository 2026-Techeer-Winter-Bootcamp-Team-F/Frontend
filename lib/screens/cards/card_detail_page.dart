import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/screens/main_navigation.dart';
import 'card_analysis_page.dart';

class CardDetailPage extends StatefulWidget {
  final WalletCard card;

  const CardDetailPage({super.key, required this.card});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  static const int _currentTabIndex = 2;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  String _monthLabel(int month) {
    return '${month.toString().padLeft(2, '0')}월';
  }

  String _currentMonthLabel() {
    return '${_currentMonth.year}년 ${_monthLabel(_currentMonth.month)}';
  }

  String _previousMonthLabel() {
    final prev = DateTime(_currentMonth.year, _currentMonth.month - 1);
    return _monthLabel(prev.month);
  }

  String _nextMonthLabel() {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    return _monthLabel(next.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Flexible(
              flex: 4,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: _buildVerticalCard(context),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(widget.card.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 6),
            Text('${widget.card.maskedNumber} 본인', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 18),

            // Month selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: _goToPreviousMonth,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.chevron_left, size: 28, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(_previousMonthLabel(), style: TextStyle(color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
                  ),
                  Text(_currentMonthLabel(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  InkWell(
                    onTap: _goToNextMonth,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: Row(
                        children: [
                          Text(_nextMonthLabel(), style: TextStyle(color: Colors.white.withOpacity(0.9))),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right, size: 28, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Rounded white card area with semicircle chart
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // semicircle chart
                      SemicircleChart(percent: 0.7, received: 23000, total: 33000),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
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
                            const SizedBox(height: 12),
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
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      width: 440,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 74,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(index: 0, icon: Icons.home, label: '홈'),
          _buildNavItem(index: 1, icon: Icons.pie_chart_outline, label: '소비'),
          _buildNavItem(index: 2, icon: Icons.credit_card, label: '카드'),
          _buildNavItem(index: 3, icon: Icons.subscriptions, label: '구독'),
        ],
      ),
    );
  }

  Widget _buildNavItem({required int index, required IconData icon, required String label}) {
    final bool selected = _currentTabIndex == index;
    final color = selected ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant;
    final iconSize = selected ? 26.0 : 22.0;
    final selectedCircleSize = 36.0;
    final labelFontSize = 11.0;
    final spacing = 2.0;

    return Expanded(
      child: InkWell(
        onTap: () => _navigateToTab(index),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected)
                Container(
                  width: selectedCircleSize,
                  height: selectedCircleSize,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Center(child: Icon(icon, color: Colors.white, size: iconSize)),
                )
              else
                Icon(icon, color: color, size: iconSize),
              SizedBox(height: spacing),
              Text(label, style: TextStyle(color: color, fontSize: labelFontSize, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTab(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainNavigation(initialIndex: index),
      ),
      (route) => false,
    );
  }

  Widget _buildVerticalCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.5;
    final height = width * 1.6;

    if (widget.card.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          widget.card.imagePath!,
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
        color: widget.card.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card, size: 56, color: Colors.white.withOpacity(0.9)),
          const SizedBox(height: 16),
          Text(widget.card.bankName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width - 64;
        final desiredHeight = 160.0;
        final maxHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : desiredHeight;
        final height = math.min(desiredHeight, maxHeight).clamp(120.0, desiredHeight);
        return SizedBox(
          width: maxWidth,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(maxWidth, height),
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
      },
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
