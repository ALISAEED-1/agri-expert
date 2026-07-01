import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../home/main_shell.dart';
import 'personal_details_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await SupabaseService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!mounted) return;

      // Check if profile is complete (has expertise set)
      final profile = await SupabaseService.getProfile();
      final expertise = profile?['expertise'] as String?;

      if (mounted) {
        if (expertise == null || expertise.isEmpty) {
          // Profile incomplete → send to Personal Details
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PersonalDetailsScreen()),
            (_) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainShell()),
            (_) => false,
          );
        }
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: screenHeight,
        width: double.infinity,
        child: Stack(
          children: [
            // ── Background image (filling top portion + behind card curve) ──
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

            // ── Green gradient overlay on image ──
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

            // ── White curved card overlapping bottom of image ──
            Positioned(
              top: 300,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome Again!',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Login to Access Your Account',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 28),
                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passCtrl,
                        label: 'Password',
                        obscureText: _obscure,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen())),
                          child: const Text('Forgot Password?',
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          onPressed: _loading ? null : _login,
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
                              : const Text('Login',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Don't have an account?",
                          style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupScreen())),
                        child: const Text('Sign Up',
                            style: TextStyle(
                                color: Color(0xFF339D44),
                                fontWeight: FontWeight.bold,
                                fontSize: 27)),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
