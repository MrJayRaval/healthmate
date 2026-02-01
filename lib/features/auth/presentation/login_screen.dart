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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Login Failed: $e';

        if (e is AuthException) {
          if (e.message.toLowerCase().contains('rate limit')) {
            errorMessage = 'Too many login attempts. Please wait a while.';
          } else {
            errorMessage = e.message;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppAnimation(
                  type: AnimationType.fadeInDown,
                  enabled: animationsEnabled,
                  duration: const Duration(milliseconds: 800),
                  child: Image.asset('assets/images/logo.png', height: 120),
                ),
                const SizedBox(height: 32),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  child: Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Sign in to continue to HealthMate AI',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 48),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 400),
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
                  delay: const Duration(milliseconds: 600),
                  child: CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 16),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 800),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 1000),
                  child: PrimaryButton(
                    text: 'Log In',
                    isLoading: _isLoading,
                    onPressed: _login,
                  ),
                ),
                const SizedBox(height: 32),
                AppAnimation(
                  type: AnimationType.fadeInUp,
                  enabled: animationsEnabled,
                  delay: const Duration(milliseconds: 1200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.push('/signup'),
                        child: const Text(
                          'Sign Up',
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
