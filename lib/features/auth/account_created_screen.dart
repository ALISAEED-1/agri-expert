import 'package:flutter/material.dart';
import '../home/main_shell.dart';

/// Modal dialog shown after the user completes Personal Details.
///
/// Usage:
/// ```dart
/// AccountCreatedDialog.show(context);
/// ```
class AccountCreatedDialog extends StatelessWidget {
  const AccountCreatedDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (_) => const AccountCreatedDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Double-check icon
            const Icon(
              Icons.done_all_rounded,
              color: Color(0xFF339D44),
              size: 56,
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Account Created',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'You can now access your account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 24),

            // Login button
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66339D44),
                    offset: Offset(5, 12),
                    blurRadius: 19,
                    spreadRadius: -11,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainShell()),
                  (_) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF339D44),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
