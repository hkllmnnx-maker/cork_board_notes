import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// رسم دبوس التثبيت (Pushpin) بأسلوب ثلاثي الأبعاد
class Pushpin extends StatelessWidget {
  final int colorIndex;
  final double size;
  const Pushpin({super.key, this.colorIndex = 0, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PushpinPainter(
          color: AppColors.pinColor(colorIndex),
          darkColor: AppColors.pinColorDark(colorIndex),
        ),
      ),
    );
  }
}

class _PushpinPainter extends CustomPainter {
  final Color color;
  final Color darkColor;
  _PushpinPainter({required this.color, required this.darkColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // الظل
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center.translate(1.5, 2.5), radius * 0.85, shadowPaint);

    // الجسم الأساسي
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.9,
        colors: [
          Color.lerp(color, Colors.white, 0.4) ?? color,
          color,
          darkColor,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.9, bodyPaint);

    // الانعكاس اللامع
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      radius * 0.2,
      highlightPaint,
    );

    // حافة داكنة
    final borderPaint = Paint()
      ..color = darkColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, radius * 0.9, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
