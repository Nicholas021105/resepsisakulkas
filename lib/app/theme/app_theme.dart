import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_palet.dart';
import 'app_spacing.dart';
import 'app_text.dart';

abstract class AppTheme {
  static final ThemeData terang = _bangun(Palet.terang);
  static final ThemeData gelap = _bangun(Palet.gelap);

  static ThemeData _bangun(Palet p) {
    final skema = ColorScheme(
      brightness: p.modeGelap ? Brightness.dark : Brightness.light,
      primary: p.aksenTua,
      onPrimary: p.diAksen,
      primaryContainer: p.aksenLembut,
      onPrimaryContainer: p.tinta,
      secondary: p.wortel,
      onSecondary: p.diMagnet,
      secondaryContainer: p.wortelLembut,
      onSecondaryContainer: p.tinta,
      error: p.wortelTeks,
      onError: p.modeGelap ? p.latar : p.diAksen,
      surface: p.permukaan,
      onSurface: p.tinta,
      onSurfaceVariant: p.tintaLembut,
      surfaceContainerHighest: p.latar,
      outline: p.tintaLembut,
      outlineVariant: p.garis,
    );
    final teks = AppText.textTheme(p);
    final sudut = BorderRadius.circular(AppSpacing.radiusM);
    OutlineInputBorder tepiInput(Color warna, [double tebal = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: BorderSide(color: warna, width: tebal),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: skema,
      extensions: [p],
      scaffoldBackgroundColor: p.latar,
      fontFamily: AppText.teks,
      textTheme: teks,
      iconTheme: IconThemeData(color: p.tinta),
      dividerTheme: DividerThemeData(color: p.garis, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.latar,
        foregroundColor: p.tinta,
        surfaceTintColor: p.latar,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: teks.headlineSmall,
        systemOverlayStyle: p.modeGelap
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: p.permukaan,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: sudut,
          side: BorderSide(color: p.garis),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.permukaan,
        hintStyle: teks.bodyMedium?.copyWith(color: p.tintaLembut),
        prefixIconColor: p.tintaLembut,
        suffixIconColor: p.tintaLembut,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        border: tepiInput(p.garis),
        enabledBorder: tepiInput(p.garis),
        focusedBorder: tepiInput(p.aksenTua, 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.aksenTua,
          foregroundColor: p.diAksen,
          disabledBackgroundColor: p.garis,
          disabledForegroundColor: p.tintaLembut,
          minimumSize: const Size(AppSpacing.sentuh, AppSpacing.tombol),
          textStyle: teks.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.tinta,
          minimumSize: const Size(AppSpacing.sentuh, 52),
          textStyle: teks.labelLarge,
          side: BorderSide(color: p.tinta),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.aksenTua,
          minimumSize: const Size(AppSpacing.sentuh, AppSpacing.sentuh),
          textStyle: teks.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: p.tinta,
          minimumSize: const Size(AppSpacing.sentuh, AppSpacing.sentuh),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.permukaan,
        selectedColor: p.balik,
        labelStyle: teks.labelMedium,
        secondaryLabelStyle: teks.labelMedium?.copyWith(color: p.diBalik),
        checkmarkColor: p.diBalik,
        side: BorderSide(color: p.garis),
        shape: const StadiumBorder(),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.aksenTua : p.garis,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.diAksen : p.tintaLembut,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.transparan),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? p.aksenTua
              : AppColors.transparan,
        ),
        checkColor: WidgetStatePropertyAll(p.diAksen),
        side: BorderSide(color: p.tintaLembut, width: 1.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs + 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.balik,
        contentTextStyle: teks.bodyMedium?.copyWith(color: p.diBalik),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: sudut),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.permukaanTinggi,
        surfaceTintColor: p.permukaanTinggi,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        ),
        titleTextStyle: teks.headlineSmall,
        contentTextStyle: teks.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.permukaanTinggi,
        surfaceTintColor: p.permukaanTinggi,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: p.garis,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusL),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.permukaanTinggi,
        surfaceTintColor: p.permukaanTinggi,
        textStyle: teks.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: sudut,
          side: BorderSide(color: p.garis),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.permukaan,
        surfaceTintColor: p.permukaan,
        indicatorColor: p.aksenLembut,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(teks.labelMedium),
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: p.tinta)),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: p.wortelTeks,
        textColor: p.diBalik,
        textStyle: teks.labelSmall?.copyWith(letterSpacing: 0),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.aksen,
        linearTrackColor: p.garis,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.balik,
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        ),
        textStyle: teks.labelMedium?.copyWith(color: p.diBalik),
      ),
    );
  }
}
