import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final List<BoxShadow>? shadows;
  final Color? gradientStart;
  final Color? gradientEnd;
  final Clip? clipBehavior;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.blur = 20.0,
    this.opacity = 0.1,
    this.shadows,
    this.gradientStart,
    this.gradientEnd,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface.withOpacity(opacity);

    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        color: surfaceColor,
        boxShadow:
            shadows ??
            [
              // Glassmorphism double shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
        gradient: gradientStart != null || gradientEnd != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientStart ?? theme.colorScheme.primary.withOpacity(0.2),
                  gradientEnd ?? theme.colorScheme.secondary.withOpacity(0.2),
                ],
              )
            : null,
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}

// Glass Button Component
class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : DefaultTextStyle(
                  style:
                      theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                  child: child,
                ),
        ),
      ),
    );
  }
}

// Glass Card for Content
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: padding ?? const EdgeInsets.all(20),
      blur: 25.0,
      opacity: theme.brightness == Brightness.dark ? 0.15 : 0.08,
      child: child,
    );
  }
}
