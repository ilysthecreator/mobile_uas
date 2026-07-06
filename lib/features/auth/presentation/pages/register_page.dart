import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_mobile/core/theme/app_theme.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/ticket/presentation/pages/dashboard_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _termsAccepted = false;
  bool _showToast = false;
  String? _errorMessage;

  late AnimationController _toastController;
  late Animation<double> _toastFadeAnimation;
  late Animation<Offset> _toastSlideAnimation;

  @override
  void initState() {
    super.initState();
    _toastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _toastFadeAnimation = CurvedAnimation(parent: _toastController, curve: Curves.easeIn);
    _toastSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _toastController, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _toastController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      setState(() => _errorMessage = 'You must agree to the Terms of Service and Privacy Policy');
      return;
    }

    setState(() => _errorMessage = null);

    final auth = ref.read(authProvider);
    final usernameText = _usernameController.text.trim();
    // Capitalize first letter of username for fullName representation
    final generatedFullName = usernameText.isNotEmpty 
        ? usernameText[0].toUpperCase() + usernameText.substring(1)
        : '';

    final success = await auth.register(
      fullName: generatedFullName,
      username: usernameText.toLowerCase(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      setState(() {
        _showToast = true;
      });
      _toastController.forward();

      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
        (route) => false,
      );
    } else if (mounted) {
      setState(() => _errorMessage = 'Email address is already registered');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProviderVal = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      body: Stack(
        children: [
          // Background soft mesh
          if (!isDark)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD3E4FE),
                      Color(0xFFE5EEFF),
                      Color(0xFFDCE9FF),
                      Color(0xFFEFF4FF),
                    ],
                    stops: [0.0, 0.33, 0.66, 1.0],
                  ),
                ),
              ),
            ),
          
          // Outer scroll content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 460),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header title
                          Text(
                            'Create an Account',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF0B1C30),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Secure access to your personal dashboard',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Error Panel
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.statusOpen.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.statusOpen.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppTheme.statusOpen, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: GoogleFonts.inter(
                                        color: AppTheme.statusOpen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Username
                          _buildLabel('Username'),
                          _buildTextField(
                            controller: _usernameController,
                            hint: 'alexthompson',
                            icon: Icons.alternate_email_rounded,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a username';
                              }
                              if (value.trim().length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email
                          _buildLabel('Corporate Email'),
                          _buildTextField(
                            controller: _emailController,
                            hint: 'alex.t@company.com',
                            icon: Icons.mail_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _buildLabel('Password'),
                          _buildTextField(
                            controller: _passwordController,
                            hint: '••••••••',
                            icon: Icons.lock_outlined,
                            obscure: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Terms agreement
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _termsAccepted,
                                  activeColor: AppTheme.primaryNavy,
                                  onChanged: (val) {
                                    setState(() {
                                      _termsAccepted = val ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFFADC6FF) : const Color(0xFF0058BE),
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFFADC6FF) : const Color(0xFF0058BE),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Action Button
                          ElevatedButton(
                            onPressed: authProviderVal.isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryNavy,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: authProviderVal.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Create Account',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 16),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 20),

                          // Redirect to Login
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Text.rich(
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Login here',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? const Color(0xFFADC6FF) : const Color(0xFF0058BE),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Custom animated success toast
          if (_showToast)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: SlideTransition(
                  position: _toastSlideAnimation,
                  child: FadeTransition(
                    opacity: _toastFadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.statusClosed,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Account created successfully! Redirecting...',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0B1C30)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: isDark ? const Color(0xFF444651) : const Color(0xFFC5C5D3)),
        prefixIcon: Icon(icon, size: 20, color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF757682)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF4FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // Style as underline inputs with rounded top corners
        border: UnderlineInputBorder(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          borderSide: BorderSide(color: AppTheme.primaryNavy, width: 2.0),
        ),
        errorBorder: UnderlineInputBorder(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          borderSide: const BorderSide(color: AppTheme.statusOpen, width: 1.5),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          borderSide: const BorderSide(color: AppTheme.statusOpen, width: 2.0),
        ),
      ),
      validator: validator,
    );
  }
}
