import 'package:flutter/material.dart';
import 'card_analysis_page.dart';

class CardDetailPage extends StatelessWidget {
  final WalletCard card;

  const CardDetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.bankName),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Center(
                child: _buildVerticalCard(context),
              ),
              const SizedBox(height: 24),
              Text(card.maskedNumber, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 12),
              Text(card.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.6;
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
}
