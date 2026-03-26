import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/water/bloc/water_bloc.dart';
import 'features/water/bloc/water_state.dart';
import 'features/water/screens/home_screen.dart';
import 'features/water/screens/onboarding_screen.dart';
import 'features/water/screens/privacy_policy_screen.dart';
import 'features/water/screens/splash_screen.dart';
import 'l10n/app_localizations.dart';

class WaterReminderApp extends StatefulWidget {
  const WaterReminderApp({super.key});

  static const Color primaryWaterLight = Color(0xFF4FC3F7);
  static const Color primaryWater = Color(0xFF03A9F4);
  static const Color primaryWaterDark = Color(0xFF0288D1);
  static const Color deepWater = Color(0xFF01579B);

  static BoxDecoration getWaterGradientBox({double borderRadius = 20}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryWaterLight, primaryWater],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: primaryWater.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration getGlassBox() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: primaryWater.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  @override
  State<WaterReminderApp> createState() => _WaterReminderAppState();
}

class _WaterReminderAppState extends State<WaterReminderApp> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Daily Water Reminder',
          debugShowCheckedModeBanner: false,
          locale: Locale(state.locale),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: WaterReminderApp.primaryWater),
            useMaterial3: true,
            fontFamily: 'Inter',
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: WaterReminderApp.deepWater,
                letterSpacing: -0.5,
              ),
              headlineMedium: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: WaterReminderApp.deepWater,
                letterSpacing: -0.2,
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                color: Color(0xFF546E7A),
              ),
            ),
            scaffoldBackgroundColor: const Color(0xFFF0F9FF),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: WaterReminderApp.deepWater,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              iconTheme: IconThemeData(color: WaterReminderApp.deepWater),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: WaterReminderApp.primaryWater,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: WaterReminderApp.primaryWater,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFE3F2FD),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: WaterReminderApp.primaryWater, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: WaterReminderApp.deepWater,
              contentTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          home: _initialized
              ? (state.onboardingCompleted ? const HomeScreen() : const OnboardingScreen())
              : SplashScreen(onFinished: () => setState(() => _initialized = true)),
          routes: {
            '/privacy_policy': (context) => const PrivacyPolicyScreen(),
          },
        );
      },
    );
  }
}
