import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable "No Data Found" widget matching the mockup design.
/// Uses the undraw illustration + mountain background from assets.
class NoDataWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const NoDataWidget({
    super.key,
    this.title = 'No Data Found',
    this.subtitle = 'You have not answered any questions yet',
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return Container(
          color: const Color(0xFFF5F5F5),
          child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Mountain — full width, tip goes behind bottom bar
            Positioned(
              top: h * 0.40,
              left: -40,
              right: -40,
              bottom: -180,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0x18000000),
                  BlendMode.srcATop,
                ),
                child: Image.asset(
                  'assets/images/Mountain 1.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            // Illustration — positioned lower
            Positioned(
              top: h * 0.24,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/undraw_file_searching_re_3evy 1.png',
                  height: h * 0.35,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Title + subtitle — in the mid of mountain
            Positioned(
              top: h * 0.65,
              left: 40,
              right: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (buttonText != null)
              Positioned(
                bottom: h * 0.05,
                left: 40,
                right: 40,
                child: Center(
                  child: ElevatedButton(
                    onPressed: onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(160, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(buttonText!,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
          ],
        ),
        );
      },
    );
  }
}
