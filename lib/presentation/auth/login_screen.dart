import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import 'providers/auth_provider.dart';
import 'package:mobile/core/utils/biometric_service.dart';
import '../../config/app_language.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text.trim());

      // Check state after login attempt
      final state = ref.read(authProvider);
      if (state.isAuthenticated && mounted) {
        context.go('/dashboard');
      } else if (state.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF5F4), Color(0xFFF5F8FA)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/attendance_welcome.png',
                      height: 148,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appText(context, 'Welcome back', 'वापस स्वागत है'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appText(
                        context,
                        'Sign in to your account',
                        'अपने खाते में लॉग इन करें',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      label: appText(context, 'Email address', 'ईमेल पता'),
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.isEmpty
                          ? appText(
                              context,
                              'Enter your email',
                              'अपना ईमेल लिखें',
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: appText(context, 'Password', 'पासवर्ड'),
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) => value!.isEmpty
                          ? appText(
                              context,
                              'Enter your password',
                              'अपना पासवर्ड लिखें',
                            )
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleLogin,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(appText(context, 'Log in', 'लॉग इन करें')),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () async {
                        final bioService = BiometricService();
                        final authenticated = await bioService.authenticate();
                        if (authenticated && context.mounted) {
                          await ref
                              .read(authProvider.notifier)
                              .checkAuthStatus();
                          if (context.mounted &&
                              ref.read(authProvider).isAuthenticated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Biometric Authentication Successful!',
                                ),
                              ),
                            );
                            context.go('/dashboard');
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sign in once before using fingerprint sign-in.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.fingerprint),
                      label: Text(
                        appText(
                          context,
                          'Use fingerprint',
                          'फ़िंगरप्रिंट से लॉग इन करें',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: () =>
                                ref.read(appLanguageProvider).setLanguage('en'),
                            child: const Text('English'),
                          ),
                          TextButton(
                            onPressed: () =>
                                ref.read(appLanguageProvider).setLanguage('hi'),
                            child: const Text('हिन्दी'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
