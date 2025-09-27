import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_theme.dart';
import '../../widgets/gradient_button.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.verifyOTP(widget.verificationId, _otpController.text);

    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
    });

    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.sendOTP(widget.phoneNumber);

    setState(() {
      _isResending = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Back button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go(AppRoutes.login),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Back to Sign In',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Logo and title
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sms_outlined,
                        size: 40,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Verify Phone Number',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // OTP form
                Container(
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // OTP input field
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _otpController,
                        animationType: AnimationType.fade,
                        animationDuration: AppConstants.shortAnimationDuration,
                        enableActiveFill: true,
                        keyboardType: TextInputType.number,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          fieldHeight: 50,
                          fieldWidth: 45,
                          activeFillColor: theme.colorScheme.primary.withOpacity(0.1),
                          inactiveFillColor: theme.colorScheme.surfaceVariant,
                          selectedFillColor: theme.colorScheme.primary.withOpacity(0.2),
                          activeColor: theme.colorScheme.primary,
                          inactiveColor: theme.colorScheme.outline,
                          selectedColor: theme.colorScheme.primary,
                        ),
                        onCompleted: (value) {
                          _verifyOTP();
                        },
                        onChanged: (value) {},
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Verify button
                      GradientButton(
                        onPressed: authState.isLoading ? null : _verifyOTP,
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Verify OTP'),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Resend OTP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          TextButton(
                            onPressed: _isResending ? null : _resendOTP,
                            child: _isResending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Resend'),
                          ),
                        ],
                      ),
                      
                      // Error message
                      if (authState.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.errorRed.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.errorRed,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.errorRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Help text
                Text(
                  'Having trouble receiving the code? Make sure your phone number is correct and try again.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
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
