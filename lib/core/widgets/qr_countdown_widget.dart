import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sguard/core/constants/app_colors.dart';
import 'package:sguard/core/constants/app_text_styles.dart';
import 'package:sguard/core/utils/date_formatter.dart';

class QrCountdownWidget extends StatelessWidget {
  final Duration remainingTime;
  final Duration totalTime;

  const QrCountdownWidget({
    super.key,
    required this.remainingTime,
    required this.totalTime,
  });

  Color get _progressColor {
    if (totalTime.inSeconds == 0) return AppColors.error;
    final ratio = remainingTime.inSeconds / totalTime.inSeconds;
    if (ratio > 0.5) return AppColors.success;
    if (ratio > 0.25) return AppColors.warning;
    return AppColors.error;
  }

  double get _progress {
    if (totalTime.inSeconds == 0) return 0.0;
    return (remainingTime.inSeconds / totalTime.inSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _CountdownArcPainter(
          progress: _progress,
          color: _progressColor,
          backgroundColor: AppColors.surfaceVariant,
          strokeWidth: 10.0,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormatter.countdownTimer(remainingTime),
                style: AppTextStyles.headlineMedium.copyWith(
                  color: _progressColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'remaining',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  const _CountdownArcPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc (starts at top, goes clockwise)
    if (progress > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CountdownArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
