import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().initialize();
  await SettingsService().initialize();
  await AdService().initialize();
  runApp(const GymIntervalTimerApp());
}

class GymIntervalTimerApp extends StatelessWidget {
  const GymIntervalTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final settingsService = SettingsService();

    return AnimatedBuilder(
      animation: settingsService,
      builder: (context, _) {
        final theme = settingsService.currentTheme;

        return MaterialApp(
          title: 'Titan Intervals: HIIT Timer',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: theme.background,
            colorScheme: ColorScheme.dark(
              primary: theme.primary,
              secondary: theme.secondary,
              surface: theme.surface,
              error: const Color(0xFFFF1744),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: theme.background,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            fontFamily: null,
            useMaterial3: true,
          ),
          home: AnimatedBuilder(
            animation: authService,
            builder: (context, _) {
              if (!authService.isInitialized) {
                return Scaffold(
                  backgroundColor: theme.background,
                  body: Center(
                    child: CircularProgressIndicator(color: theme.primary),
                  ),
                );
              }

              if (authService.isLoggedIn) {
                return const HomeScreen();
              }

              return const AuthScreen();
            },
          ),
        );
      },
    );
  }
}
