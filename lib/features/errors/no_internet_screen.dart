import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/status_screen.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.signal_wifi_connected_no_internet_4_rounded,
      iconColor: AppColors.error,
      title: 'No Internet',
      description:
          'You are not connected to the internet.\nMake sure your Wi-Fi or mobile data\nis turned on, then try again.',
      buttonText: 'Try Again',
      onButtonPressed: onRetry ?? () => Navigator.pop(context),
    );
  }
}
