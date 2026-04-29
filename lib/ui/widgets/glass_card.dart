import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const GlassCard({Key? key, required this.child, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      // BackdropFilter يصنع تأثير الضباب
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            // لون شفاف بناءً على الوضع الليلي أو النهاري
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.2)), // حد أبيض خفيف
          ),
          child: child,
        ),
      ),
    );
  }
}