import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/set_new_password_screen.dart';
import 'features/splash/splash_screen.dart';

/// Global navigator key so we can navigate from the auth-state listener
/// (e.g. when a password-recovery deep link opens the app).
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://arbefcgjjnzudafrjzrs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFyYmVmY2dqam56dWRhZnJqenJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwODUwODgsImV4cCI6MjA5NDY2MTA4OH0.fBMyoAgPNV3yDiux9ZJB2WG5sWfuK_PdtvWrYJy-8tY',
  );

  // When the recovery deep link opens the app, Supabase emits
  // passwordRecovery — send the user to the Set New Password screen and
  // clear the stack so the splash navigation can't override it.
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      SupabaseService.isPasswordRecovery = true;
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SetNewPasswordScreen()),
        (route) => false,
      );
    }
  });

  runApp(const AgriExpertApp());
}

class AgriExpertApp extends StatelessWidget {
  const AgriExpertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriExpert',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
