import 'package:flutter/material.dart';

/// Widget que centra y limita el ancho del contenido para mantener
/// una buena relación de aspecto en diferentes tamaños de pantalla
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool centerHorizontally;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 600, // Ancho máximo para tablets/desktop
    this.padding,
    this.centerHorizontally = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // En móviles (< 600px), usar todo el ancho
    // En tablets/desktop, limitar el ancho y centrar
    final shouldLimit = screenWidth > maxWidth;

    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (shouldLimit && centerHorizontally) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }

    if (shouldLimit) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      );
    }

    return content;
  }
}

/// Breakpoints para diseño responsive
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
}

/// Extension para obtener el tamaño de pantalla fácilmente
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveBreakpoints.isMobile(this);
  bool get isTablet => ResponsiveBreakpoints.isTablet(this);
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(this);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}
