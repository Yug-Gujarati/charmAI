import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // 1. Primary Brand Colors (Gradients & Accents)
  /// Start of primary gradients, active navigation icons, "Glow" text highlights.
  static const Color skyBlue = Color(0xFF4FC3F7);
  
  /// End of primary gradients, subtle accents, decorative background glows.
  static const Color softPink = Color(0xFFF48FB1);

  // 2. Backgrounds & Surfaces
  /// The base layer for all screens.
  static const Color mainAppBackground = Color(0xFF000000); // Deep Midnight
  
  /// Used for containers, cards, and the base of the bottom navigation bar.
  static const Color surfaceDark = Color(0xFF1A1A24); // Card & Section Surface
  
  /// Floating buttons, secondary containers, and top app bars. (rgba(255, 255, 255, 0.05))
  static const Color glassSurface = Color(0x0DFFFFFF);

  // 3. Typography (Text Hierarchy)
  /// Main headlines, primary labels, and button text.
  static const Color primaryText = Color(0xFFFFFFFF); // Pure White

  static const Color transparent = Colors.transparent;
  
  /// Descriptions, sub-labels, and inactive navigation items.
  static const Color secondaryText = Color(0xFF94A3B8); // Slate Gray

  static const Color buttonText = Color(0xFF000000);
  
  /// Smaller section titles and high-emphasis labels.
  static const Color subHeaderEmphasis = Color(0xFFE0F2FE); // Sky Mist

  // 4. Functional & Interaction Colors
  /// Glowing borders on selected style thumbnails.
  static const Color selectedGlowHighlight = Color(0xFF9ADBFF);
  
  /// Active toggle switches and success notifications.
  static const Color successHighlight = Color(0xFF4ADE80);
  
  /// "Logout" buttons, error messages, and delete actions.
  static const Color errorDestructive = Color(0xFFF87171);

  // 5. Signature Gradients
  /// "Generate," "Upload Photo," and "Apply Selection" buttons.
  static const LinearGradient primaryActionGradient = LinearGradient(
    colors: [skyBlue, softPink],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.mainAppBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.skyBlue,
        secondary: AppColors.softPink,
        surface: AppColors.surfaceDark,
        error: AppColors.errorDestructive,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.primaryText),
        bodyMedium: TextStyle(color: AppColors.secondaryText),
        headlineSmall: TextStyle(color: AppColors.subHeaderEmphasis),
      ),
      // Add other theme configurations as needed
    );
  }
}
