import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppLayout {
  // 8px Grid System
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;
  static const double space80 = 80.0;

  // Reusable Vertical Spacing
  static const Widget height4 = SizedBox(height: space4);
  static const Widget height8 = SizedBox(height: space8);
  static const Widget height12 = SizedBox(height: space12);
  static const Widget height16 = SizedBox(height: space16);
  static const Widget height20 = SizedBox(height: space20);
  static const Widget height24 = SizedBox(height: space24);
  static const Widget height32 = SizedBox(height: space32);
  static const Widget height40 = SizedBox(height: space40);
  static const Widget height48 = SizedBox(height: space48);
  static const Widget height64 = SizedBox(height: space64);

  // Reusable Horizontal Spacing
  static const Widget width4 = SizedBox(width: space4);
  static const Widget width8 = SizedBox(width: space8);
  static const Widget width12 = SizedBox(width: space12);
  static const Widget width16 = SizedBox(width: space16);
  static const Widget width20 = SizedBox(width: space20);
  static const Widget width24 = SizedBox(width: space24);
  static const Widget width32 = SizedBox(width: space32);

  // Screen Padding
  static const double screenPadding = space24;
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(space24);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: space24);
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(vertical: space24);

  // Border Radius
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radius32 = 32.0;
  static const double radiusMax = 100.0;

  static final BorderRadius borderRadius8 = BorderRadius.circular(radius8);
  static final BorderRadius borderRadius12 = BorderRadius.circular(radius12);
  static final BorderRadius borderRadius16 = BorderRadius.circular(radius16);
  static final BorderRadius borderRadius20 = BorderRadius.circular(radius20);
  static final BorderRadius borderRadius24 = BorderRadius.circular(radius24);
  static final BorderRadius borderRadius32 = BorderRadius.circular(radius32);
  static final BorderRadius borderRadiusMax = BorderRadius.circular(radiusMax);

  // Common UI Decorators
  static InputDecoration commonInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: borderRadius12,
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: space16, vertical: space16),
    );
  }

  // Standard Touch Target Size
  static const double touchTargetSize = 48.0;

  // Helper for responsive width/height
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  static bool isMobile(BuildContext context) => screenWidth(context) < 600;
  static bool isTablet(BuildContext context) => screenWidth(context) >= 600 && screenWidth(context) < 1200;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= 1200;
}
