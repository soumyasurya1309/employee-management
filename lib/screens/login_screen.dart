import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed'),
          backgroundColor: const Color(0xFFF87171),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return LoadingOverlay(
          isLoading: auth.status == AuthStatus.loading,
          child: Scaffold(
            backgroundColor: AppColors.bg(context),
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.accent,
                                  AppColors.accentEnd
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.people_alt_rounded,
                                color: Colors.white, size: 28),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('Welcome back',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context)),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Text('Sign in to EmpTrack',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary(context)),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              AppTextField(
                                label: 'Email address',
                                hint: 'admin@company.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon:
                                    const Icon(Icons.mail_outline_rounded),
                                validator: (v) =>
                                    v == null || !v.contains('@')
                                        ? 'Enter a valid email'
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              AppTextField(
                                label: 'Password',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textMuted(context),
                                    size: 18,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) => v == null || v.length < 6
                                    ? 'Minimum 6 characters'
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/forgot-password'),
                                  child: const Text('Forgot password?',
                                      style: TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 12)),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GradientButton(
                                label: 'Sign In',
                                onPressed: _login,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(
                              child: Divider(
                                  color: AppColors.border(context))),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or',
                                style: TextStyle(
                                    color: AppColors.textMuted(context),
                                    fontSize: 12)),
                          ),
                          Expanded(
                              child: Divider(
                                  color: AppColors.border(context))),
                        ]),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.border(context)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Create new account',
                                style: TextStyle(
                                    color:
                                        AppColors.textSecondary(context),
                                    fontSize: 14),
                                textAlign: TextAlign.center),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/otp-demo'),
                          child: Text('Sign in with OTP (Demo)',
                              style: TextStyle(
                                  color: AppColors.textMuted(context),
                                  fontSize: 12),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}