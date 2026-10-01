import 'package:flutter/material.dart';

/// Style variant for [CustomButton].
enum CustomButtonVariant {
  /// Filled solid background button (primary action).
  primary,

  /// Outlined border button with transparent background (secondary action).
  outlined,

  /// Flat text button with no border or background (tertiary action).
  text,
}

/// A comprehensive and highly configurable custom button widget supporting
/// loading indicators, icons, customized elevation, and multiple style variants.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = CustomButtonVariant.primary,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.height = 48.0,
    this.width,
    this.minimumSize,
    this.padding,
    this.elevation = 0,
    this.textStyle,
    this.loadingIndicatorColor,
    this.loadingIndicatorSize = 20.0,
    this.loadingIndicatorStrokeWidth = 2.0,
  });

  /// Factory constructor for a primary filled button.
  const factory CustomButton.primary({
    Key? key,
    String? text,
    Widget? child,
    Widget? icon,
    required VoidCallback? onPressed,
    bool isLoading,
    bool isDisabled,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? disabledBackgroundColor,
    Color? disabledForegroundColor,
    BorderRadius? borderRadius,
    double height,
    double? width,
    Size? minimumSize,
    EdgeInsetsGeometry? padding,
    double elevation,
    TextStyle? textStyle,
    Color? loadingIndicatorColor,
    double loadingIndicatorSize,
    double loadingIndicatorStrokeWidth,
  }) = _CustomPrimaryButton;

  /// Factory constructor for an outlined border button.
  const factory CustomButton.outlined({
    Key? key,
    String? text,
    Widget? child,
    Widget? icon,
    required VoidCallback? onPressed,
    bool isLoading,
    bool isDisabled,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? disabledForegroundColor,
    Color? borderColor,
    double borderWidth,
    BorderRadius? borderRadius,
    double height,
    double? width,
    Size? minimumSize,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Color? loadingIndicatorColor,
    double loadingIndicatorSize,
    double loadingIndicatorStrokeWidth,
  }) = _CustomOutlinedButton;

  /// Factory constructor for a flat text button.
  const factory CustomButton.text({
    Key? key,
    String? text,
    Widget? child,
    Widget? icon,
    required VoidCallback? onPressed,
    bool isLoading,
    bool isDisabled,
    Color? foregroundColor,
    Color? disabledForegroundColor,
    BorderRadius? borderRadius,
    double height,
    double? width,
    Size? minimumSize,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Color? loadingIndicatorColor,
    double loadingIndicatorSize,
    double loadingIndicatorStrokeWidth,
  }) = _CustomTextButton;

  /// Optional text label for the button.
  final String? text;

  /// Custom child widget replacing the text label.
  final Widget? child;

  /// Leading icon widget.
  final Widget? icon;

  /// Callback when the button is clicked. If null or [isDisabled] is true, button is disabled.
  final VoidCallback? onPressed;

  /// When true, displays a circular progress indicator and prevents taps.
  final bool isLoading;

  /// When true, button behaves as disabled.
  final bool isDisabled;

  /// Button style variant (primary, outlined, text).
  final CustomButtonVariant variant;

  /// Background color.
  final Color? backgroundColor;

  /// Text and icon color.
  final Color? foregroundColor;

  /// Background color when button is disabled.
  final Color? disabledBackgroundColor;

  /// Text and icon color when button is disabled.
  final Color? disabledForegroundColor;

  /// Border color (for outlined variant or bordered primary).
  final Color? borderColor;

  /// Border width.
  final double borderWidth;

  /// Corner radius of the button.
  final BorderRadius? borderRadius;

  /// Default height of the button.
  final double height;

  /// Width of the button. Defaults to stretch if null inside a Column/Flex or parent constraints.
  final double? width;

  /// Minimum size constraint.
  final Size? minimumSize;

  /// Inner padding.
  final EdgeInsetsGeometry? padding;

  /// Elevation of the button shadow.
  final double elevation;

  /// Text style of the label text.
  final TextStyle? textStyle;

  /// Color of the circular loading indicator.
  final Color? loadingIndicatorColor;

  /// Diameter of the loading indicator.
  final double loadingIndicatorSize;

  /// Stroke width of the loading indicator.
  final double loadingIndicatorStrokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(10);
    final effectiveMinSize =
        minimumSize ?? Size(width ?? double.infinity, height);

    final bool isClickable = !isDisabled && !isLoading && onPressed != null;

    Widget content;
    if (isLoading) {
      content = Center(
        child: SizedBox(
          width: loadingIndicatorSize,
          height: loadingIndicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: loadingIndicatorStrokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              loadingIndicatorColor ??
                  (variant == CustomButtonVariant.primary
                      ? Colors.white
                      : primaryColor),
            ),
          ),
        ),
      );
    } else if (child != null) {
      content = child!;
    } else {
      final labelWidget = Text(
        text ?? '',
        style:
            textStyle ??
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      );

      if (icon != null) {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [icon!, const SizedBox(width: 8), labelWidget],
        );
      } else {
        content = labelWidget;
      }
    }

    switch (variant) {
      case CustomButtonVariant.primary:
        return ElevatedButton(
          onPressed: isClickable ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? primaryColor,
            foregroundColor: foregroundColor ?? Colors.white,
            disabledBackgroundColor:
                disabledBackgroundColor ?? const Color(0xFFD8B296),
            disabledForegroundColor: disabledForegroundColor ?? Colors.white70,
            elevation: elevation,
            minimumSize: effectiveMinSize,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: effectiveRadius,
              side: borderColor != null
                  ? BorderSide(color: borderColor!, width: borderWidth)
                  : BorderSide.none,
            ),
          ),
          child: content,
        );

      case CustomButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isClickable ? onPressed : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.transparent,
            foregroundColor: foregroundColor ?? primaryColor,
            disabledForegroundColor:
                disabledForegroundColor ?? theme.disabledColor,
            minimumSize: effectiveMinSize,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            side: BorderSide(
              color: isClickable
                  ? (borderColor ?? primaryColor)
                  : (disabledForegroundColor ?? theme.disabledColor),
              width: borderWidth,
            ),
            shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
          ),
          child: content,
        );

      case CustomButtonVariant.text:
        return TextButton(
          onPressed: isClickable ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? primaryColor,
            disabledForegroundColor:
                disabledForegroundColor ?? theme.disabledColor,
            minimumSize: effectiveMinSize,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
          ),
          child: content,
        );
    }
  }
}

class _CustomPrimaryButton extends CustomButton {
  const _CustomPrimaryButton({
    super.key,
    super.text,
    super.child,
    super.icon,
    required super.onPressed,
    super.isLoading = false,
    super.isDisabled = false,
    super.backgroundColor,
    super.foregroundColor,
    super.disabledBackgroundColor,
    super.disabledForegroundColor,
    super.borderRadius,
    super.height = 48.0,
    super.width,
    super.minimumSize,
    super.padding,
    super.elevation = 0,
    super.textStyle,
    super.loadingIndicatorColor,
    super.loadingIndicatorSize = 20.0,
    super.loadingIndicatorStrokeWidth = 2.0,
  }) : super(variant: CustomButtonVariant.primary);
}

class _CustomOutlinedButton extends CustomButton {
  const _CustomOutlinedButton({
    super.key,
    super.text,
    super.child,
    super.icon,
    required super.onPressed,
    super.isLoading = false,
    super.isDisabled = false,
    super.backgroundColor,
    super.foregroundColor,
    super.disabledForegroundColor,
    super.borderColor,
    super.borderWidth = 1.0,
    super.borderRadius,
    super.height = 48.0,
    super.width,
    super.minimumSize,
    super.padding,
    super.textStyle,
    super.loadingIndicatorColor,
    super.loadingIndicatorSize = 20.0,
    super.loadingIndicatorStrokeWidth = 2.0,
  }) : super(variant: CustomButtonVariant.outlined);
}

class _CustomTextButton extends CustomButton {
  const _CustomTextButton({
    super.key,
    super.text,
    super.child,
    super.icon,
    required super.onPressed,
    super.isLoading = false,
    super.isDisabled = false,
    super.foregroundColor,
    super.disabledForegroundColor,
    super.borderRadius,
    super.height = 48.0,
    super.width,
    super.minimumSize,
    super.padding,
    super.textStyle,
    super.loadingIndicatorColor,
    super.loadingIndicatorSize = 20.0,
    super.loadingIndicatorStrokeWidth = 2.0,
  }) : super(variant: CustomButtonVariant.text);
}
