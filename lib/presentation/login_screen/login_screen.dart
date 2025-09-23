import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/animated_gradient_background.dart';
import './widgets/app_logo.dart';
import './widgets/biometric_button.dart';
import './widgets/floating_input_field.dart';
import './widgets/primary_button.dart';
import './widgets/social_login_button.dart';

import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isFacebookLoading = false;

  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Mock credentials for demonstration
  final Map<String, dynamic> mockCredentials = {
    "admin": {
      "email": "admin@budgetflow.com",
      "password": "Admin123!",
      "role": "Administrator"
    },
    "user": {
      "email": "user@budgetflow.com",
      "password": "User123!",
      "role": "Regular User"
    },
    "demo": {
      "email": "demo@budgetflow.com",
      "password": "Demo123!",
      "role": "Demo User"
    }
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _fadeAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }


  void _handleLogin() async {
  if (!_formKey.currentState!.validate()) {
    HapticFeedback.heavyImpact();
    return;
  }

  setState(() {
    _isLoading = true;
  });

  HapticFeedback.mediumImpact();

  try {
    // 🔑 Call real backend login via AuthService
    final response = await AuthService().login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    HapticFeedback.lightImpact();

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() => _isLoading = false);

        // 🟢 Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful! 🎉")),
        );

        // ✅ Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard-home-screen');
      }
    } else {
      // Backend sent error (e.g., 400 or 401)
      if (mounted) {
        _showErrorDialog("Login failed: ${response.data["message"] ?? "Unknown error"}");
      }
    }
  } catch (e) {
    HapticFeedback.heavyImpact();

    if (mounted) {
      setState(() => _isLoading = false);
      _showErrorDialog("Login failed: $e");
    }
  }
}



  void _handleBiometricLogin() async {
    HapticFeedback.mediumImpact();

    // Simulate biometric authentication
    await Future.delayed(const Duration(seconds: 1));

    HapticFeedback.lightImpact();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard-home-screen');
    }
  }

  void _handleSocialLogin(String provider) async {
    HapticFeedback.lightImpact();

    switch (provider) {
      case 'google':
        setState(() => _isGoogleLoading = true);
        break;
      case 'apple':
        setState(() => _isAppleLoading = true);
        break;
      case 'facebook':
        setState(() => _isFacebookLoading = true);
        break;
    }

    // Simulate social login delay
    await Future.delayed(const Duration(seconds: 2));

    HapticFeedback.lightImpact();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard-home-screen');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Login Failed',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          const Positioned.fill(
            child: AnimatedGradientBackground(),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),

                        // App Logo
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: const AppLogo(size: 120),
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Welcome text
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'Welcome Back',
                                  style: AppTheme
                                      .lightTheme.textTheme.headlineMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Sign in to continue managing your budget',
                                  style: AppTheme.lightTheme.textTheme.bodyLarge
                                      ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Biometric login button
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                BiometricButton(
                                  onPressed: _handleBiometricLogin,
                                  isEnabled: !_isLoading,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Use biometric authentication',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Divider
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                  child: Text(
                                    'or continue with',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Email input field
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: FloatingInputField(
                              label: 'Email',
                              hint: 'Enter your email address',
                              iconName: 'email',
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              validator: _validateEmail,
                            ),
                          ),
                        ),

                        // Password input field
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: FloatingInputField(
                              label: 'Password',
                              hint: 'Enter your password',
                              iconName: 'lock',
                              isPassword: true,
                              controller: _passwordController,
                              validator: _validatePassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              isPasswordVisible: _isPasswordVisible,
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Remember me and forgot password
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                        HapticFeedback.lightImpact();
                                      },
                                      fillColor:
                                          WidgetStateProperty.resolveWith(
                                              (states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return Colors.white;
                                        }
                                        return Colors.transparent;
                                      }),
                                      checkColor: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      side: const BorderSide(
                                          color: Colors.white, width: 2),
                                    ),
                                    Text(
                                      'Remember me',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    // Navigate to forgot password screen
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Sign in button
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: PrimaryButton(
                              text: 'Sign In',
                              onPressed: _handleLogin,
                              isLoading: _isLoading,
                              isEnabled: !_isLoading,
                            ),
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Social login buttons
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                SocialLoginButton(
                                  text: 'Continue with Google',
                                  iconName: 'g_translate',
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black87,
                                  onPressed: () => _handleSocialLogin('google'),
                                  isLoading: _isGoogleLoading,
                                ),
                                SocialLoginButton(
                                  text: 'Continue with Apple',
                                  iconName: 'apple',
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  onPressed: () => _handleSocialLogin('apple'),
                                  isLoading: _isAppleLoading,
                                ),
                                SocialLoginButton(
                                  text: 'Continue with Facebook',
                                  iconName: 'facebook',
                                  backgroundColor: const Color(0xFF1877F2),
                                  textColor: Colors.white,
                                  onPressed: () =>
                                      _handleSocialLogin('facebook'),
                                  isLoading: _isFacebookLoading,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Sign up link
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'New user? ',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.pushNamed(
                                        context, '/registration-screen');
                                  },
                                  child: Text(
                                    'Create Account',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}