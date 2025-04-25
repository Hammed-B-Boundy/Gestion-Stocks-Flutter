import 'package:flutter/material.dart';
import '../services/responsive_helper.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;
  final double? maxWidth;
  final AlignmentGeometry? alignment;

  const ResponsiveWrapper({
    Key? key,
    required this.child,
    this.padding,
    this.constraints,
    this.maxWidth,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: alignment,
        constraints:
            constraints ?? ResponsiveHelper.getAdaptiveConstraints(context),
        padding: padding ?? ResponsiveHelper.getAdaptivePadding(context),
        child: child,
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.padding,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      padding: padding,
      constraints: constraints,
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          if (ResponsiveHelper.isMobile(context)) {
            crossAxisCount = 1;
          } else if (ResponsiveHelper.isTablet(context)) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 3;
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.5 : 1.2,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          );
        },
      ),
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double baseSize;
  final TextAlign? textAlign;

  const ResponsiveText({
    Key? key,
    required this.text,
    this.style,
    this.baseSize = 16.0,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: (style ?? TextStyle()).copyWith(
        fontSize: ResponsiveHelper.getAdaptiveFontSize(context, baseSize),
      ),
      textAlign: textAlign,
    );
  }
}
