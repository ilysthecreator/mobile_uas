import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_mobile/core/theme/app_theme.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:project_mobile/features/auth/presentation/pages/reset_password_page.dart';
import 'package:project_mobile/features/ticket/presentation/pages/dashboard_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _staySignedIn = false;
  String? _errorMessage;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    final auth = ref.read(authProvider);
    final success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (mounted) {
      setState(() {
        _errorMessage = 'Invalid email or password (Hint: password is "password")';
      });
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
          // Dot grid background
          if (!isDark)
            Positioned.fill(
              child: CustomPaint(
                painter: DotGridPainter(
                  dotColor: const Color(0xFFE5EEFF),
                  spacing: 24.0,
                  dotRadius: 1.5,
                ),
              ),
            ),

          // Abstract background ambient glows
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryNavy.withValues(alpha: 0.04),
                    AppTheme.primaryNavy.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondaryBlue.withValues(alpha: 0.04),
                    AppTheme.secondaryBlue.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Form area with scroll
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          // Brand Identity Logo Card
                          Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryNavy,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryNavy.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.support_agent_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Helpdesk Central',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryNavy,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Enterprise Ticket Management',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 36),

                          // Welcome Box
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Welcome Back',
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF0B1C30),
                                  ),
                                ),
                                Text(
                                  'Access your support dashboard',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Error Banner
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
                                        const Icon(Icons.error_outline_rounded, color: AppTheme.statusOpen, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: GoogleFonts.inter(color: AppTheme.statusOpen, fontSize: 11, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Login Form
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Email/Username label & input
                                      _buildLabel(Icons.alternate_email_rounded, 'Email or Username'),
                                      _buildTextField(
                                        controller: _emailController,
                                        hint: 'alex.thompson@helpdesk.com',
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Please enter your email or username';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),

                                      // Password label & input
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildLabel(Icons.lock_outline_rounded, 'Password'),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
                                              );
                                            },
                                            child: Text(
                                              'Forgot Password?',
                                              style: GoogleFonts.jetBrainsMono(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: isDark ? const Color(0xFFADC6FF) : const Color(0xFF0058BE),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      _buildTextField(
                                        controller: _passwordController,
                                        hint: '••••••••',
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
                                            return 'Please enter your password';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Stay signed in switch
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 44,
                                      height: 24,
                                      child: Switch(
                                        value: _staySignedIn,
                                        activeThumbColor: Colors.white,
                                        activeTrackColor: AppTheme.secondaryBlue,
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE5EEFF),
                                        onChanged: (val) {
                                          setState(() {
                                            _staySignedIn = val;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Stay signed in for 30 days',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Login Button
                                ElevatedButton(
                                  onPressed: authProviderVal.isLoading ? null : _handleLogin,
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
                                              'Login',
                                              style: GoogleFonts.hankenGrotesk(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward, size: 16),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Register link
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                                );
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: "Don't have an account? ",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Register for Access',
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
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sticky footer layout
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE5EEFF),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'SYSTEM STATUS',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF757682),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.statusClosed, // operational green
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ALL SYSTEMS OPERATIONAL',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.statusClosed,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Privacy',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: const Color(0xFF757682),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Terms',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: const Color(0xFF757682),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(IconData icon, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
          ),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0B1C30)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: isDark ? const Color(0xFF444651) : const Color(0xFFC5C5D3)),
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

class DotGridPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double dotRadius;

  DotGridPainter({
    required this.dotColor,
    this.spacing = 24.0,
    this.dotRadius = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
