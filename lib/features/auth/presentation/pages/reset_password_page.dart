import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_mobile/core/theme/app_theme.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    final auth = ref.read(authProvider);
    final success = await auth.resetPassword(_emailController.text.trim());

    if (success && mounted) {
      setState(() => _isSuccess = true);
      // Show success toast matching mockup
      _showSuccessToast();
    } else if (mounted) {
      setState(() => _errorMessage = 'Email address not found in our database');
    }
  }

  void _showSuccessToast() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 40,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.statusClosed, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppTheme.statusClosed,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Link Sent!',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0B1C30)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Please check your inbox (and spam folder) for instructions.',
                          style: GoogleFonts.inter(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProviderVal = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Custom App Bar matching mockup
    final appBar = AppBar(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Helpdesk Central',
        style: GoogleFonts.hankenGrotesk(
          color: isDark ? Colors.white : const Color(0xFF0B1C30),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3)),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFDCE9FF),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA_RJ3l7Nuu7NqwfXNqUbhHToHhE6fKQPRlP6bBD7OGL0UXohTmSjLvHm-7M1qV0C3r-SRaF0s_C1-v7WnqkdCoTSgalbRV_rElmdsVACE0Id-W5IbYLR-zviobFc_JmnYVncCBV6emskNEQwKsNiHs2AkcPpJstmkZSaEl62Nwjd3Z813MUgy91PkcnMq_ozAMy6oxDf9hia7_c1w6QZIZa0RNMJh8n2bZ8dQhH4yJE-M1eAgXad14PrkqlQTUQX4EGGFOF9n5Mgg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );

    // Help Section
    Widget buildHelpSection() {
      return Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'STILL NEED HELP?',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.support_agent_rounded, size: 16),
                label: const Text('Contact Admin'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.secondaryBlue,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 1,
                height: 16,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.library_books_outlined, size: 16),
                label: const Text('Browse Docs'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.secondaryBlue,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Secure Footer
    Widget buildFooter() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 16, color: isDark ? const Color(0xFF64748B) : const Color(0xFF757682)),
            const SizedBox(width: 8),
            Text(
              'SECURE ENTERPRISE AUTHENTICATION',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF757682),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      appBar: appBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                // Glowing Background Blobs
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryNavy.withValues(alpha: isDark ? 0.08 : 0.12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -80,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.secondaryBlue.withValues(alpha: isDark ? 0.05 : 0.08),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),

                // Form Canvas Center
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 440),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _isSuccess
                              ? _buildSuccessView()
                              : _buildFormView(authProviderVal, isDark),
                        ),
                        if (!_isSuccess) buildHelpSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFormView(AuthProvider authProviderVal, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon Box lock_reset
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.lock_reset_rounded, size: 36, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Forgot Password?',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF00236F),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "No worries! Enter your registered email address and we'll send you a link to reset your password.",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
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

          _buildLabel('Work Email Address'),
          _buildTextField(
            controller: _emailController,
            hint: 'alex.thompson@company.com',
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
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              'We\'ll verify this account before sending the link.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: authProviderVal.isLoading ? null : _handleReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
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
                        'Send Reset Link',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.send_rounded, size: 16),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Suddenly remembered? ',
                style: GoogleFonts.inter(fontSize: 13, color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651)),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'Back to Login',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.statusClosed,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.statusClosed.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.check_circle_outline_rounded, size: 36, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Link Sent!',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF00236F),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'We\'ve sent password reset instructions to:\n${_emailController.text}',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryNavy,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: Text(
            'Back to Sign In',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0B1C30)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
        prefixIcon: Icon(Icons.mail_outline_rounded, size: 20, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF757682)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF4FF).withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.statusOpen, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.statusOpen, width: 2.0),
        ),
      ),
      validator: validator,
    );
  }
}
