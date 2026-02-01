import 'package:flutter/widgets.dart';
import 'package:animate_do/animate_do.dart';

enum AnimationType {
  fadeIn,
  fadeInDown,
  fadeInUp,
  fadeInLeft,
  fadeInRight,
  elasticIn,
  flash,
}

class AppAnimation extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final AnimationType type;
  final Duration? delay;
  final Duration? duration;
  final bool infinite;

  const AppAnimation({
    super.key,
    required this.child,
    required this.enabled,
    required this.type,
    this.delay,
    this.duration,
    this.infinite = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled && !infinite) return child;

    switch (type) {
      case AnimationType.fadeIn:
        return FadeIn(
          delay: delay ?? Duration.zero,
          duration: duration ?? const Duration(milliseconds: 500),
          animate: enabled,
          child: child,
        );
      case AnimationType.fadeInDown:
        return FadeInDown(
          delay: delay ?? Duration.zero,
          duration: duration ?? const Duration(milliseconds: 500),
          animate: enabled,
          child: child,
        );
      case AnimationType.fadeInUp:
        return FadeInUp(
          delay: delay ?? Duration.zero,
          duration: duration ?? const Duration(milliseconds: 500),
          animate: enabled,
          child: child,
        );
      case AnimationType.fadeInLeft:
        return FadeInLeft(
          delay: delay ?? Duration.zero,
          duration: duration ?? const Duration(milliseconds: 500),
          animate: enabled,
          child: child,
        );
      case AnimationType.fadeInRight:
        return FadeInRight(
          delay: delay ?? Duration.zero,
          duration: duration ?? const Duration(milliseconds: 500),
          animate: enabled,
          child: child,
        );
      case AnimationType.elasticIn:
        return ElasticIn(
          delay: delay ?? Duration.zero,
          duration: duration ?? const Duration(milliseconds: 500),
          animate: enabled,
          child: child,
        );
      case AnimationType.flash:
        return Flash(
          delay: delay ?? Duration.zero,
          duration: duration ?? const Duration(milliseconds: 500),
          animate: enabled,
          infinite: infinite,
          child: child,
        );
    }
  }
}
