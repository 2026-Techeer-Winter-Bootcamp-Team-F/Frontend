import 'package:flutter/material.dart';

class WalletCard {
  final Color color;
  final String label;
  final String bankName;
  final String maskedNumber;
  final String? imagePath;

  const WalletCard({
    this.imagePath,
    required this.color,
    required this.label,
    this.bankName = '카드',
    this.maskedNumber = '',
  });
}
