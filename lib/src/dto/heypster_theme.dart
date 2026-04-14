import 'dart:ui';

import 'package:meta/meta.dart';

import 'misc.dart';

/// Visual theming for heypster UI components.
///
/// Use the factory constructors for preset themes, or create a
/// custom theme by providing individual color values.
@immutable
class HeypsterTheme {
  /// The heypster brand navy color.
  ///
  /// Used as the default accent color in light mode.
  static const heypsterNavy = Color(0xFF0A233C);

  /// The preset this theme is based on, if any.
  final HeypsterThemePreset? preset;

  /// Accent color for buttons and interactive elements.
  final Color? accentColor;

  /// Background color for the dialog/picker.
  final Color? backgroundColor;

  /// Default text color.
  final Color? defaultTextColor;

  /// Background color for the search bar.
  final Color? searchBarBackgroundColor;

  /// Corner radius for the search bar.
  final double? searchBarCornerRadius;

  /// Text color for the search input.
  final Color? searchTextColor;

  /// Placeholder text color in the search bar.
  final Color? searchPlaceholderTextColor;

  /// Color for the search back button.
  final Color? searchBackButtonColor;

  /// Corner radius for GIF cells.
  final double? cellCornerRadius;

  /// Background color for loading cells.
  final Color? backgroundColorForLoadingCells;

  /// Background color for the dialog overlay.
  final Color? dialogOverlayBackgroundColor;

  /// Background color for retry buttons.
  final Color? retryButtonBackgroundColor;

  /// Text color for retry buttons.
  final Color? retryButtonTextColor;

  /// Color for the drag handle bar.
  final Color? handleBarColor;

  /// Creates a [HeypsterTheme] with custom values.
  const HeypsterTheme({
    this.preset,
    this.accentColor,
    this.backgroundColor,
    this.defaultTextColor,
    this.searchBarBackgroundColor,
    this.searchBarCornerRadius,
    this.searchTextColor,
    this.searchPlaceholderTextColor,
    this.searchBackButtonColor,
    this.cellCornerRadius,
    this.backgroundColorForLoadingCells,
    this.dialogOverlayBackgroundColor,
    this.retryButtonBackgroundColor,
    this.retryButtonTextColor,
    this.handleBarColor,
  });

  /// The default theme that adapts to system brightness.
  static const automaticTheme = HeypsterTheme(
    preset: HeypsterThemePreset.automatic,
    accentColor: heypsterNavy,
    cellCornerRadius: 10,
  );

  /// A preset theme that adapts to system brightness.
  factory HeypsterTheme.automatic() => automaticTheme;

  /// A dark preset theme.
  factory HeypsterTheme.dark() =>
      const HeypsterTheme(preset: HeypsterThemePreset.dark);

  /// A light preset theme.
  factory HeypsterTheme.light() =>
      const HeypsterTheme(preset: HeypsterThemePreset.light);

  /// Creates a copy with the given fields replaced.
  HeypsterTheme copyWith({
    HeypsterThemePreset? preset,
    Color? accentColor,
    Color? backgroundColor,
    Color? defaultTextColor,
    Color? searchBarBackgroundColor,
    double? searchBarCornerRadius,
    Color? searchTextColor,
    Color? searchPlaceholderTextColor,
    Color? searchBackButtonColor,
    double? cellCornerRadius,
    Color? backgroundColorForLoadingCells,
    Color? dialogOverlayBackgroundColor,
    Color? retryButtonBackgroundColor,
    Color? retryButtonTextColor,
    Color? handleBarColor,
  }) {
    return HeypsterTheme(
      preset: preset ?? this.preset,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      defaultTextColor: defaultTextColor ?? this.defaultTextColor,
      searchBarBackgroundColor:
          searchBarBackgroundColor ?? this.searchBarBackgroundColor,
      searchBarCornerRadius:
          searchBarCornerRadius ?? this.searchBarCornerRadius,
      searchTextColor: searchTextColor ?? this.searchTextColor,
      searchPlaceholderTextColor:
          searchPlaceholderTextColor ?? this.searchPlaceholderTextColor,
      searchBackButtonColor:
          searchBackButtonColor ?? this.searchBackButtonColor,
      cellCornerRadius: cellCornerRadius ?? this.cellCornerRadius,
      backgroundColorForLoadingCells:
          backgroundColorForLoadingCells ?? this.backgroundColorForLoadingCells,
      dialogOverlayBackgroundColor:
          dialogOverlayBackgroundColor ?? this.dialogOverlayBackgroundColor,
      retryButtonBackgroundColor:
          retryButtonBackgroundColor ?? this.retryButtonBackgroundColor,
      retryButtonTextColor: retryButtonTextColor ?? this.retryButtonTextColor,
      handleBarColor: handleBarColor ?? this.handleBarColor,
    );
  }
}
