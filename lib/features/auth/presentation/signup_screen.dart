import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../core/services/service_locator.dart';

import '../../../core/providers/settings_provider.dart';

import '../../../shared/widgets/app_animation.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ref
          .read(authServiceProvider)
          .signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );
      if (mounted) {
        if (response.session != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account Created! Welcome.')),
          );
          context.go('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Verification email sent! Please check your inbox.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Signup Failed: $e';

        if (e is AuthException) {
          if (e.message.toLowerCase().contains('rate limit')) {
            errorMessage =
                'Too many signup attempts. Please wait a while or disable "Confirm Email" in Supabase Auth settings.';
          } else {
            errorMessage = e.message;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final animationsEnabled = ref.watch(animationsProvider);

    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppAnimation(
                  type: AnimationType.fadeInDown,
                  enabled: animationsEnabled,
                  child: Center(
                    child: Image.asset('assets/images/logo.png', height: 80),
                  ),
                ),
                const SizedBox(height: 24),
                AppAnimation(
                  type: AnimationType.fadeInLeft,
                  enabled: animationsEnabled,
                  child: Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppAnimation(
                  type: AnimationType.fadeInLeft,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Start your health journey today',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 32),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 200),
                  child: CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _nameController,
                  ),
                ),
                const SizedBox(height: 24),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 300),
                  child: CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 24),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 400),
                  child: CustomTextField(
                    label: 'Password',
                    hint: 'Create a password',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 24),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 500),
                  child: CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter password',
                    controller: _confirmController,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 48),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 600),
                  child: PrimaryButton(
                    text: 'Sign Up',
                    isLoading: _isLoading,
                    onPressed: _signUp,
                  ),
                ),
                const SizedBox(height: 24),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 700),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
