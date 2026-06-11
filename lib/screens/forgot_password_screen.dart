import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(_emailController.text);
    if (!mounted) return;
    if (success) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Failed to send reset email'),
          backgroundColor: AppTheme.errorColor,
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
            appBar: AppBar(
              title: const Text('Forgot Password'),
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.textPrimary(context),
              elevation: 0,
            ),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: _sent ? _buildSentState() : _buildForm(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 64,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Reset Password',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email and we\'ll send you a link to reset your password.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: 'Email Address',
            hint: 'you@company.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: AppValidators.validateEmail,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _sendReset,
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  Widget _buildSentState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read_outlined,
            size: 80, color: AppColors.accentLight),
        const SizedBox(height: 24),
        Text(
          'Check Your Email',
          style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted(context)),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}

// ── Mock OTP Verification ────────────────────────────────────────────────────
class OtpDemoScreen extends StatefulWidget {
  const OtpDemoScreen({super.key});

  @override
  State<OtpDemoScreen> createState() => _OtpDemoScreenState();
}

class _OtpDemoScreenState extends State<OtpDemoScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  bool _codeSent = false;
  final _phoneController = TextEditingController();
  static const String _demoOtp = '123456';

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_phoneController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter a valid 10-digit phone number'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    setState(() => _codeSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Demo OTP sent: 123456'),
        backgroundColor: AppColors.accentLight,
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the complete 6-digit OTP'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (otp == _demoOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'OTP verified! (Demo mode — logging in requires email/password)'),
          backgroundColor: AppColors.accentLight,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Incorrect OTP. Try: 123456'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isVerifying,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          title: const Text('OTP Verification (Demo)'),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary(context),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.phone_android_rounded,
                  size: 64, color: AppColors.accent),
              const SizedBox(height: 16),
              Text(
                _codeSent ? 'Enter Verification Code' : 'Enter Phone Number',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _codeSent
                    ? 'We\'ve sent a 6-digit code to your phone.\n(Demo OTP: 123456)'
                    : 'We\'ll send a verification code to this number',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
              const SizedBox(height: 32),
              if (!_codeSent) ...[
                AppTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _sendOtp,
                  child: const Text('Send OTP'),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (i) => _buildOtpBox(i)),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  child: const Text('Verify OTP'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _codeSent = false;
                    for (var c in _controllers) {
                      c.clear();
                    }
                  }),
                  child: const Text('Change Phone Number'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}