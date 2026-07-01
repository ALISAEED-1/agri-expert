import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UploadField extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final String? fileName;

  const UploadField({
    super.key,
    required this.label,
    this.onTap,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFF339D44),
          radius: 10,
          dashWidth: 6,
          dashSpace: 4,
          strokeWidth: 1.4,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  fileName ?? label,
                  style: TextStyle(
                    color: fileName != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              fileName != null
                  ? const Icon(Icons.check_circle,
                      color: Color(0xFF339D44), size: 22)
                  : Image.asset(
                      'assets/images/flat-color-icons_upload.png',
                      width: 22,
                      height: 22,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double radius;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.radius = 10,
    this.strokeWidth = 1.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final source = Path()..addRRect(rrect);
    final dashed = Path();

    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashed.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + dashSpace;
      }
    }

    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.dashWidth != dashWidth ||
      old.dashSpace != dashSpace ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth;
}
