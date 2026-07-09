import 'package:flutter/material.dart';

/// A custom page transitions builder that creates a smooth slide-and-fade transition.
///
/// Under the hood, it slides entering pages in from the right side and fades them in.
/// Simultaneously, exiting pages slide slightly to the left and fade out.
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Entering transition (push)
    final slideIn = Tween<Offset>(
      begin: const Offset(0.08, 0.0), // subtle slide-in from right
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    final fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    // Exiting transition (when covered by a new page)
    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.03, 0.0), // subtle slide-out to left
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    final fadeOut = Tween<double>(
      begin: 1.0,
      end: 0.85, // subtle fade to 85% opacity
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    return SlideTransition(
      position: slideOut,
      child: FadeTransition(
        opacity: fadeOut,
        child: SlideTransition(
          position: slideIn,
          child: FadeTransition(
            opacity: fadeIn,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A custom [PageRouteBuilder] that uses the smooth slide-and-fade transition
/// with customizable duration and settings.
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SmoothPageRoute({
    required this.child,
    super.settings,
    Duration duration = const Duration(milliseconds: 380),
    Duration reverseDuration = const Duration(milliseconds: 320),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideIn = Tween<Offset>(
              begin: const Offset(0.08, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );

            final fadeIn = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
                reverseCurve: Curves.easeIn,
              ),
            );

            final slideOut = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.03, 0.0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );

            final fadeOut = Tween<double>(
              begin: 1.0,
              end: 0.85,
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeOut,
                reverseCurve: Curves.easeIn,
              ),
            );

            return SlideTransition(
              position: slideOut,
              child: FadeTransition(
                opacity: fadeOut,
                child: SlideTransition(
                  position: slideIn,
                  child: FadeTransition(
                    opacity: fadeIn,
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
}
