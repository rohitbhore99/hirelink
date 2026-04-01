import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hirelink1/core/di/providers.dart';
import 'package:hirelink1/features/user/domain/models/user_model.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isOtpSent = false;
  String? _generatedOtp;
  final AuthService _authService = AuthService();

  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );
    _formAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _logoController.forward();
    _formController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _logoController.dispose();
    _formController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    // Simulate network delay for sending email
    await Future.delayed(const Duration(seconds: 1));
    
    // In a production app, you would integrate a backend service 
    // or an email API like SendGrid/Mailgun here to actually email the user.
    // For now, we mock the OTP.
    _generatedOtp = "123456";
    
    setState(() {
      _isOtpSent = true;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent! (DEMO: Please enter 123456)'),
          duration: Duration(seconds: 4),
        )
      );
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isOtpSent) {
      return _sendOtp();
    }

    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_otpController.text.trim() != _generatedOtp) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP. Please try again.'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
        return;
      }

      final user = await _authService.signUp(_emailController.text.trim(), _passwordController.text);
      if (user != null && mounted) {
        final token = await FirebaseMessaging.instance.getToken();
        final userModel = UserModel(
          uid: user.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.isEmpty ? '' : _phoneController.text.trim(),
          role: 'jobseeker',
          skills: '',
          bio: '',
          profileImageUrl: '',
          resumeUrl: '',
          fcmToken: token ?? '',
          headline: '',
          location: '',
          desiredRole: '',
          experienceLevel: '',
          languagesKnown: '',
          portfolioGithub: '',
          portfolioLinkedin: '',
          portfolioWebsite: '',
          educationDegree: '',
          educationCollege: '',
          educationYear: '',
          educationScore: '',
          projectTitle: '',
          projectDescription: '',
          projectTechnologies: '',
          projectLink: '',
          achievements: '',
          certifications: '',
          awards: '',
          hackathons: '',
        );
        await ref.read(userRepositoryProvider).createUser(userModel);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _googleSignup() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.googleSignIn();
      if (user != null && mounted) {
        final repo = ref.read(userRepositoryProvider);
        final existingUser = await repo.getUser(user.uid);
        if (existingUser == null) {
          final token = await FirebaseMessaging.instance.getToken();
          final userModel = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'Google User',
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            role: 'jobseeker',
            skills: '',
            bio: '',
            profileImageUrl: user.photoURL ?? '',
            resumeUrl: '',
            fcmToken: token ?? '',
            headline: '',
            location: '',
            desiredRole: '',
            experienceLevel: '',
            languagesKnown: '',
            portfolioGithub: '',
            portfolioLinkedin: '',
            portfolioWebsite: '',
            educationDegree: '',
            educationCollege: '',
            educationYear: '',
            educationScore: '',
            projectTitle: '',
            projectDescription: '',
            projectTechnologies: '',
            projectLink: '',
            achievements: '',
            certifications: '',
            awards: '',
            hackathons: '',
          );
          await repo.createUser(userModel);
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google signup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Widget formSection = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Account',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Join HireLink and elevate your career.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32.0),

          // Name Field
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant, size: 22),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant, size: 22),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Phone Field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Phone (optional)',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.onSurfaceVariant, size: 22),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 16.0),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a password',
              prefixIcon: Icon(Icons.lock_outlined, color: colorScheme.onSurfaceVariant, size: 22),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a password';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // OTP Field (visible only when sent)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: !_isOtpSent ? const SizedBox.shrink() : Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  hintText: 'Enter the 6-digit code',
                  prefixIcon: Icon(Icons.vpn_key_outlined, color: colorScheme.onSurfaceVariant, size: 22),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Sign Up / Get OTP Button
          SizedBox(
            height: 52.0,
            child: FilledButton(
              onPressed: _isLoading ? null : _signup,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(_isOtpSent ? 'Verify & Create Account' : 'Get OTP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 32.0),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: colorScheme.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'OR',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider(color: colorScheme.outlineVariant)),
            ],
          ),
          const SizedBox(height: 32.0),

          // Google Login
          SizedBox(
            height: 52.0,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _googleSignup,
              icon: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                height: 24,
                width: 24,
                errorBuilder: (_, __, ___) => Icon(Icons.g_mobiledata_rounded, size: 32, color: colorScheme.onSurface),
              ),
              label: Text(
                'Sign up with Google',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 48.0),

          // Signup Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: Text(
                  'Sign In',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;
            if (isDesktop) {
              return Row(
                children: [
                  // Left side
                  Expanded(
                    flex: 5,
                    child: AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.95 + (0.05 * _logoAnimation.value),
                          child: Opacity(
                            opacity: _logoAnimation.value,
                            child: Container(
                              margin: const EdgeInsets.all(32.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.primary,
                                    Color.lerp(colorScheme.primary, Colors.black, 0.4) ?? colorScheme.primary,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(48.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Image.asset('assets/images/logo.jpeg', width: 140, fit: BoxFit.contain),
                                    ),
                                    const SizedBox(height: 32.0),
                                    Text(
                                      'Start Your\nSuccess Story',
                                      style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, height: 1.1),
                                    ),
                                    const SizedBox(height: 16.0),
                                    Text(
                                      'Join a vast community of professionals and find the perfect match for your career aspirations.',
                                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(height: 48.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Right side - Form
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
                          child: AnimatedBuilder(
                            animation: _formAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - _formAnimation.value)),
                                child: Opacity(
                                  opacity: _formAnimation.value,
                                  child: formSection,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Mobile/Tablet
            return AnimatedBuilder(
              animation: _formAnimation,
              builder: (context, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - _formAnimation.value)),
                    child: Opacity(
                      opacity: _formAnimation.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32.0),
                          // Mobile Logo
                          AnimatedBuilder(
                            animation: _logoAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(color: colorScheme.primary.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 8)),
                                    ],
                                  ),
                                  child: Image.asset('assets/images/logo.jpeg', width: 140, fit: BoxFit.contain),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 48.0),
                          // Form
                          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: formSection),
                          const SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}    
