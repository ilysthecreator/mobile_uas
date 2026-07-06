import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:project_mobile/features/ticket/presentation/pages/dashboard_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();
    _startProgress();
    _checkAuth();
  }

  void _startProgress() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return false;
      setState(() {
        _progressValue += 0.08 + (0.12 * (1.0 - _progressValue));
        if (_progressValue >= 1.0) {
          _progressValue = 1.0;
        }
      });
      return _progressValue < 1.0;
    });
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final authState = ref.read(authProvider);

    final Widget destination = authState.currentUser != null
        ? const DashboardPage()
        : const LoginPage();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A), // radial/mesh top left
              Color(0xFF00236F), // deep corporate navy bottom right
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Soft atmospheric orbs
            ..._buildBackgroundOrbs(),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Translucent floating card
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.confirmation_num_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Helpdesk Central',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Reliability, Efficiency, and Clarity in Every Ticket.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF90A8FF), // on-primary-container
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 56),

                    // Loading Indicator Ring
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // INITIALIZING KINETIC LEDGER
                    Text(
                      'INITIALIZING KINETIC LEDGER',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF90A8FF).withValues(alpha: 0.6),
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dynamic Progress Bar
                    Container(
                      width: 192, // w-48
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 192 * _progressValue,
                          height: 2,
                          decoration: const BoxDecoration(
                            color: Color(0xFF90A8FF), // bg-on-primary-container
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer info
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Corporate Modern UI System',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      'v2.4.0',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundOrbs() {
    return [
      Positioned(
        top: -120,
        left: -120,
        child: _AnimatedOrb(
          size: 320,
          color: const Color(0xFF2170E4).withValues(alpha: 0.20),
          controller: _pulseController,
        ),
      ),
      Positioned(
        bottom: -150,
        right: -150,
        child: _AnimatedOrb(
          size: 400,
          color: const Color(0xFF00236F).withValues(alpha: 0.30),
          controller: _pulseController,
          reverse: true,
        ),
      ),
    ];
  }
}

class _AnimatedOrb extends StatelessWidget {
  final double size;
  final Color color;
  final AnimationController controller;
  final bool reverse;

  const _AnimatedOrb({
    required this.size,
    required this.color,
    required this.controller,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = reverse ? 1.0 - controller.value : controller.value;
        return Transform.scale(
          scale: 0.92 + (value * 0.16),
          child: Opacity(
            opacity: 0.6 + (value * 0.4),
            child: child,
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
