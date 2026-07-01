import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import 'signup_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _sendResetLink() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a valid email'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // Only registered users can reset their password.
      final exists = await SupabaseService.emailExists(email);
      if (!exists) {
        if (mounted) _showNoAccountDialog();
        return;
      }
      await SupabaseService.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Reset link sent! Check your email.'),
              backgroundColor: Color(0xFF339D44)),
        );
        Navigator.pop(context);
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

  void _showNoAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('No account found'),
        content: const Text(
            'This email is not registered. Create an account to get started.'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF339D44),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              );
            },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // Keep the Get Link button pinned to the bottom instead of riding up
      // with the keyboard.
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

            // Back button
            Positioned(
              top: 44,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // ── White curved card ──
            Positioned(
              top: 300,
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
                    const Text('Forgot Password',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                      'Enter your registered email below\nwe\'ll send you a reset link.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
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
                        onPressed: _loading ? null : _sendResetLink,
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
                            : const Text('Get Link',
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
