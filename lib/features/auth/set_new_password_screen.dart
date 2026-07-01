import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import 'login_screen.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _save() async {
    final pass = _passCtrl.text;
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 6 characters'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (pass != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await SupabaseService.updatePassword(pass);
      await SupabaseService.signOut();
      SupabaseService.isPasswordRecovery = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password updated! Please log in.'),
              backgroundColor: Color(0xFF339D44)),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // Keep the Update Password button pinned to the bottom instead of
      // riding up with the keyboard.
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: screenHeight,
        width: double.infinity,
        child: Stack(
          children: [
            // ── Background image ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 500,
              child: Image.asset(
                'assets/images/Rectangle 9.png',
                fit: BoxFit.cover,
              ),
            ),

            // ── Green gradient overlay ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 380,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withAlpha(100),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── White curved card ──
            Positioned(
              top: 280,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Set New Password',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                      'Enter a new password for your account.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      controller: _passCtrl,
                      label: 'New Password',
                      obscureText: _obscure,
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _confirmCtrl,
                      label: 'Confirm Password',
                      obscureText: _obscure,
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      height: 56,
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
                        onPressed: _loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF339D44),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Update Password',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
