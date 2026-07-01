import 'package:flutter/material.dart';
import '../../core/widgets/status_screen.dart';

class NotFoundScreen extends StatelessWidget {
  final VoidCallback? onGoBack;

  const NotFoundScreen({super.key, this.onGoBack});

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.error_outline_rounded,
      iconColor: const Color(0xFFFFA726),
      title: '404 Not Found',
      description:
          'The page you are looking for doesn\'t\nexist or has been moved. Please go\nback and try again.',
      buttonText: 'Go Back',
      onButtonPressed: onGoBack ?? () => Navigator.pop(context),
    );
  }
}
