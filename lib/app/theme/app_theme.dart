import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text.dart';

abstract class AppTheme {
  static ThemeData get terang {
    const skema = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.aksenTua,
      onPrimary: AppColors.putih,
      primaryContainer: AppColors.aksenLembut,
      onPrimaryContainer: AppColors.tinta,
      secondary: AppColors.wortel,
      onSecondary: AppColors.tinta,
      secondaryContainer: AppColors.wortelLembut,
      onSecondaryContainer: AppColors.tinta,
      error: AppColors.wortelTeks,
      onError: AppColors.putih,
      surface: AppColors.permukaan,
      onSurface: AppColors.tinta,
      onSurfaceVariant: AppColors.tintaLembut,
      surfaceContainerHighest: AppColors.latar,
      outline: AppColors.tintaLembut,
      outlineVariant: AppColors.garis,
    );
    final teks = AppText.textTheme;
    final sudut = BorderRadius.circular(AppSpacing.radiusM);

    return ThemeData(
      useMaterial3: true,
      colorScheme: skema,
      scaffoldBackgroundColor: AppColors.latar,
      fontFamily: AppText.teks,
      textTheme: teks,
      dividerTheme: const DividerThemeData(color: AppColors.garis, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.latar,
        foregroundColor: AppColors.tinta,
        surfaceTintColor: AppColors.latar,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: teks.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: AppColors.permukaan,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: sudut,
          side: const BorderSide(color: AppColors.garis),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.permukaan,
        hintStyle: teks.bodyMedium?.copyWith(color: AppColors.tintaLembut),
        prefixIconColor: AppColors.tintaLembut,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: const BorderSide(color: AppColors.garis),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: const BorderSide(color: AppColors.garis),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: const BorderSide(color: AppColors.aksenTua, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.aksenTua,
          foregroundColor: AppColors.putih,
          minimumSize: const Size(AppSpacing.sentuh, 56),
          textStyle: teks.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tinta,
          minimumSize: const Size(AppSpacing.sentuh, 52),
          textStyle: teks.labelLarge,
          side: const BorderSide(color: AppColors.tinta),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.aksenTua,
          minimumSize: const Size(AppSpacing.sentuh, AppSpacing.sentuh),
          textStyle: teks.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.permukaan,
        selectedColor: AppColors.tinta,
        labelStyle: teks.labelMedium,
        secondaryLabelStyle: teks.labelMedium?.copyWith(color: AppColors.putih),
        checkmarkColor: AppColors.putih,
        side: const BorderSide(color: AppColors.garis),
        shape: const StadiumBorder(),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.aksenTua
              : AppColors.garis,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.putih
              : AppColors.tintaLembut,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.transparan),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.tinta,
        contentTextStyle: teks.bodyMedium?.copyWith(color: AppColors.putih),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: sudut),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.permukaan,
        surfaceTintColor: AppColors.permukaan,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        ),
        titleTextStyle: teks.headlineSmall,
        contentTextStyle: teks.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.permukaan,
        surfaceTintColor: AppColors.permukaan,
        elevation: 0,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusL),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.permukaan,
        indicatorColor: AppColors.aksenLembut,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(teks.labelMedium),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(color: AppColors.tinta),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.aksen,
      ),
    );
  }
}
