import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_tadkhira/core/theme/app_theme.dart';
import 'package:al_tadkhira/presentation/providers/providers.dart';
import 'package:al_tadkhira/presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  // Initialize services
  await container.read(notificationServiceProvider).init();
  container.read(settingsServiceProvider).getThemeMode(); // Just to load

  // Schedule notifications
  // In a real app, we might want to do this in background or on specific events
  // For now, we do it on app launch
  container.read(notificationSchedulerProvider).scheduleDailyNotifications();

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch settings for theme changes (future implementation)
    // For now, just use light theme or system
    return MaterialApp(
      title: 'Al-Tadkhira',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
