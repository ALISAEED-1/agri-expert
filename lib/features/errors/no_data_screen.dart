import 'package:flutter/material.dart';
import '../../core/widgets/status_screen.dart';

class NoDataScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoDataScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.inbox_outlined,
      title: 'No Data Found',
      description:
          'There is no data to show right now.\nPlease try again later.',
      buttonText: 'Retry',
      onButtonPressed: onRetry ?? () => Navigator.pop(context),
    );
  }
}
