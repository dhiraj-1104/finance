import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Style variant for [CustomTextFormField].
enum CustomTextFieldVariant {
  /// Standard rectangular border with rounded corners.
  outline,

  /// Clean underline border (ideal for floating card / minimal forms).
  underline,

  /// Filled background with outline.
  filled,

  /// No borders (ideal for inline form rows and table cells).
  none,
}

/// A comprehensive and highly configurable custom [TextFormField] widget
/// designed for consistent form inputs across the application.
class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.obscureText = false,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.inputFormatters,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.autofocus = false,
    this.autovalidateMode,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.contentPadding,
    this.isDense,
    this.fillColor,
    this.filled,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.disabledBorder,
    this.variant = CustomTextFieldVariant.outline,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.cursorColor,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
  });

  /// Text editing controller managing the value.
  final TextEditingController? controller;

  /// Initial text value when controller is not provided.
  final String? initialValue;

  /// Optional label text displayed above or inside the field.
  final String? labelText;

  /// Optional hint text displayed when field is empty.
  final String? hintText;

  /// Helper text displayed below the field.
  final String? helperText;

  /// Custom error text to force an error state.
  final String? errorText;

  /// Prefix widget placed before the text input.
  final Widget? prefixIcon;

  /// Prefix widget inline with text.
  final Widget? prefix;

  /// Suffix widget placed after the text input.
  final Widget? suffixIcon;

  /// Suffix widget inline with text.
  final Widget? suffix;

  /// Whether the text should be hidden (for passwords or PINs).
  final bool obscureText;

  /// When true, automatically provides an eye toggle icon to reveal/hide password.
  final bool isPassword;

  /// The keyboard type for the input field.
  final TextInputType? keyboardType;

  /// The keyboard action button type.
  final TextInputAction? textInputAction;

  /// Form validation callback.
  final String? Function(String?)? validator;

  /// Callback when text changes.
  final void Function(String)? onChanged;

  /// Callback when user submits the field.
  final void Function(String)? onFieldSubmitted;

  /// Callback when the field is tapped.
  final VoidCallback? onTap;

  /// Formatters restricting or modifying input characters.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the text field is read-only.
  final bool readOnly;

  /// Whether the text field is enabled.
  final bool enabled;

  /// Maximum line count (default: 1).
  final int? maxLines;

  /// Minimum line count.
  final int? minLines;

  /// Maximum character length.
  final int? maxLength;

  /// Focus node controlling keyboard focus.
  final FocusNode? focusNode;

  /// Whether to auto-focus this field on mount.
  final bool autofocus;

  /// Validation auto-trigger mode.
  final AutovalidateMode? autovalidateMode;

  /// Text style of the entered text.
  final TextStyle? style;

  /// Style of the label text.
  final TextStyle? labelStyle;

  /// Style of the hint text.
  final TextStyle? hintStyle;

  /// Style of the validation error text.
  final TextStyle? errorStyle;

  /// Padding within the input field.
  final EdgeInsetsGeometry? contentPadding;

  /// Whether the input field is compact.
  final bool? isDense;

  /// Fill color of the input background.
  final Color? fillColor;

  /// Whether the input background is filled.
  final bool? filled;

  /// Custom generic border.
  final InputBorder? border;

  /// Custom enabled state border.
  final InputBorder? enabledBorder;

  /// Custom focused state border.
  final InputBorder? focusedBorder;

  /// Custom error state border.
  final InputBorder? errorBorder;

  /// Custom focused error state border.
  final InputBorder? focusedErrorBorder;

  /// Custom disabled state border.
  final InputBorder? disabledBorder;

  /// Visual border variant (outline, underline, filled, none).
  final CustomTextFieldVariant variant;

  /// Border corner radius.
  final BorderRadius? borderRadius;

  /// Custom border line color.
  final Color? borderColor;

  /// Custom focused border line color.
  final Color? focusedBorderColor;

  /// Cursor color.
  final Color? cursorColor;

  /// Text alignment within the field.
  final TextAlign textAlign;

  /// Text capitalization mode.
  final TextCapitalization textCapitalization;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword || widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant CustomTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText ||
        oldWidget.isPassword != widget.isPassword) {
      _obscureText = widget.isPassword || widget.obscureText;
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  InputBorder _getBorder(BorderSide side) {
    final radius = widget.borderRadius ?? BorderRadius.circular(10);
    switch (widget.variant) {
      case CustomTextFieldVariant.underline:
        return UnderlineInputBorder(borderSide: side);
      case CustomTextFieldVariant.none:
        return InputBorder.none;
      case CustomTextFieldVariant.outline:
      case CustomTextFieldVariant.filled:
        return OutlineInputBorder(borderRadius: radius, borderSide: side);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.focusedBorderColor ?? theme.colorScheme.primary;
    final defaultBorderColor =
        widget.borderColor ?? theme.dividerColor.withValues(alpha: 0.3);

    Widget? suffix = widget.suffixIcon ?? widget.suffix;
    if (widget.isPassword && widget.suffixIcon == null) {
      suffix = IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        onPressed: _togglePasswordVisibility,
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      );
    }

    final effectiveBorder =
        widget.border ??
        _getBorder(BorderSide(color: defaultBorderColor, width: 1.0));
    final effectiveEnabledBorder =
        widget.enabledBorder ??
        _getBorder(BorderSide(color: defaultBorderColor, width: 1.0));
    final effectiveFocusedBorder =
        widget.focusedBorder ??
        _getBorder(BorderSide(color: primaryColor, width: 1.5));
    final effectiveErrorBorder =
        widget.errorBorder ??
        _getBorder(BorderSide(color: theme.colorScheme.error, width: 1.0));
    final effectiveFocusedErrorBorder =
        widget.focusedErrorBorder ??
        _getBorder(BorderSide(color: theme.colorScheme.error, width: 1.5));
    final effectiveDisabledBorder =
        widget.disabledBorder ??
        _getBorder(
          BorderSide(
            color: defaultBorderColor.withValues(alpha: 0.2),
            width: 1.0,
          ),
        );

    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      inputFormatters: widget.inputFormatters,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      autovalidateMode: widget.autovalidateMode,
      style: widget.style,
      textAlign: widget.textAlign,
      textCapitalization: widget.textCapitalization,
      cursorColor: widget.cursorColor ?? primaryColor,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: widget.labelStyle,
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
        helperText: widget.helperText,
        errorText: widget.errorText,
        errorStyle: widget.errorStyle,
        prefixIcon: widget.prefixIcon,
        prefix: widget.prefix,
        suffixIcon: suffix,
        suffix: widget.suffix,
        filled:
            widget.filled ?? (widget.variant == CustomTextFieldVariant.filled),
        fillColor: widget.fillColor,
        isDense: widget.isDense,
        contentPadding: widget.contentPadding,
        border: effectiveBorder,
        enabledBorder: effectiveEnabledBorder,
        focusedBorder: effectiveFocusedBorder,
        errorBorder: effectiveErrorBorder,
        focusedErrorBorder: effectiveFocusedErrorBorder,
        disabledBorder: effectiveDisabledBorder,
      ),
    );
  }
}
