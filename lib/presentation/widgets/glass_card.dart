import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10,
    this.backgroundColor = const Color(0x30FFFFFF),
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A GlassCard that fades + slides in on first build.
class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final int delayMs;

  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10,
    this.backgroundColor = const Color(0x30FFFFFF),
    this.padding,
    this.margin,
    this.delayMs = 0,
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GlassCard(
          borderRadius: widget.borderRadius,
          blur: widget.blur,
          backgroundColor: widget.backgroundColor,
          padding: widget.padding,
          margin: widget.margin,
          child: widget.child,
        ),
      ),
    );
  }
}
