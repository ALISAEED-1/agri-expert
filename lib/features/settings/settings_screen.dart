import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Color(0xff339D44),),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          ListTile(
            title: const Text('Account'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Rate our app'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: Image.asset('assets/images/logout.png', width: 24, height: 24),
            title: const Text('Logout',
                style: TextStyle(color: AppColors.logout)),
            onTap: () async {
              await SupabaseService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
