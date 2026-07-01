import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/status_screen.dart';

class ConnectionLostScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const ConnectionLostScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.wifi_off_rounded,
      iconColor: AppColors.error,
      title: 'Connection Lost',
      description:
          'Oops! It seems like your connection\nhas been lost. Please check your\ninternet and try again.',
      buttonText: 'Try Again',
      onButtonPressed: onRetry ?? () => Navigator.pop(context),
    );
  }
}
