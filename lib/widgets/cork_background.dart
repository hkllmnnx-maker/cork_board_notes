import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// رسم خلفية لوحة الفلين باستخدام CustomPainter
class CorkBackground extends StatelessWidget {
  final Widget? child;
  const CorkBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.corkBoard,
            AppColors.corkBoardDark,
          ],
        ),
      ),
      child: CustomPaint(
        painter: CorkTexturePainter(),
        child: child,
      ),
    );
  }
}

class CorkTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // seed ثابت للنمط نفسه دائمًا
    final paint = Paint();

    // نقاط بنية داكنة صغيرة (تقليد ملمس الفلين)
    for (int i = 0; i < 800; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.8 + 0.3;
      final alpha = (random.nextDouble() * 100 + 20).toInt();
      paint.color = Color.fromARGB(alpha, 80, 50, 30);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // نقاط أفتح
    for (int i = 0; i < 500; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.2;
      final alpha = (random.nextDouble() * 60 + 10).toInt();
      paint.color = Color.fromARGB(alpha, 180, 140, 100);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
