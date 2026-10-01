import 'package:flutter/material.dart';

/// Predefined text scale levels for user selection.
enum AppTextScale {
  small(0.88, 'Small'),
  normal(1.0, 'Default'),
  medium(1.12, 'Medium'),
  large(1.25, 'Large'),
  extraLarge(1.38, 'Extra Large');

  const AppTextScale(this.scaleFactor, this.label);

  final double scaleFactor;
  final String label;

  static AppTextScale fromLabel(String? label) {
    if (label == null) return AppTextScale.normal;
    for (final scale in values) {
      if (scale.label.toLowerCase() == label.toLowerCase()) {
        return scale;
      }
    }
    return AppTextScale.normal;
  }

  static AppTextScale fromFactor(double factor) {
    AppTextScale closest = AppTextScale.normal;
    double minDiff = double.infinity;
    for (final scale in values) {
      final diff = (scale.scaleFactor - factor).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = scale;
      }
    }
    return closest;
  }
}

/// Controller that manages ThemeMode (light/dark/system) and Text Scale Factor.
class ThemeController extends ChangeNotifier {
  ThemeController({
    ThemeMode initialThemeMode = ThemeMode.light,
    double initialTextScaleFactor = 1.0,
  }) : _themeMode = initialThemeMode,
       _textScaleFactor = initialTextScaleFactor;

  ThemeMode _themeMode;
  double _textScaleFactor;

  ThemeMode get themeMode => _themeMode;
  double get textScaleFactor => _textScaleFactor;

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  AppTextScale get currentTextScale {
    return AppTextScale.fromFactor(_textScaleFactor);
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme(BuildContext context) {
    final currentIsDark = isDarkMode(context);
    setThemeMode(currentIsDark ? ThemeMode.light : ThemeMode.dark);
  }

  void setTextScaleFactor(double factor) {
    final clamped = factor.clamp(0.7, 1.6);
    if ((_textScaleFactor - clamped).abs() > 0.001) {
      _textScaleFactor = clamped;
      notifyListeners();
    }
  }

  void setTextScale(AppTextScale scale) {
    setTextScaleFactor(scale.scaleFactor);
  }

  void setTextScaleByLabel(String label) {
    setTextScale(AppTextScale.fromLabel(label));
  }

  void cycleTextScale() {
    final values = AppTextScale.values;
    final currentIndex = values.indexOf(currentTextScale);
    final nextIndex = (currentIndex + 1) % values.length;
    setTextScale(values[nextIndex]);
  }
}

/// Inherited widget providing access to [ThemeController] throughout the widget tree.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.notifier!;
  }

  static ThemeController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeScope>()?.notifier;
  }
}
