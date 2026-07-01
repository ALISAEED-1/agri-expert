import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../auth/personal_details_screen.dart';
import '../home/main_shell.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () => _navigate());
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    // A password-recovery deep link is taking over navigation — stand down.
    if (SupabaseService.isPasswordRecovery) return;

    if (!SupabaseService.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    // Check if profile is complete
    try {
      final profile = await SupabaseService.getProfile();
      final expertise = profile?['expertise'] as String?;
      if (mounted) {
        if (expertise == null || expertise.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PersonalDetailsScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset('assets/images/Group 20.png', width: 180),
            const Spacer(),
            Column(
              children: [
                const Text(
                  'Powered by',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/tech farm SVG.png',
                        width: 24, height: 24),
                    const SizedBox(width: 6),
                    const Text(
                      'FARM TECH',
                      style: TextStyle(
                        color: Color(0xFF424242),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
