import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/water/bloc/water_bloc.dart';
import 'features/water/bloc/water_state.dart';
import 'features/water/screens/home_screen.dart';
import 'features/water/screens/onboarding_screen.dart';
import 'package:smart_task/l10n/app_localizations.dart';

class WaterReminderApp extends StatelessWidget {
  const WaterReminderApp({super.key});

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
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('gu'),
          ],
          theme: ThemeData(
            useMaterial3: true,
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2196F3),
              primary: const Color(0xFF2196F3),
              surface: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F9FF),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          home: state.onboardingCompleted
              ? const HomeScreen()
              : const OnboardingScreen(),
        );
      },
    );
  }
}
