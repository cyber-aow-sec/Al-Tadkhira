import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_tadkhira/core/services/location_service.dart';
import 'package:al_tadkhira/core/services/notification_service.dart';
import 'package:al_tadkhira/core/services/prayer_times_service.dart';
import 'package:al_tadkhira/core/services/settings_service.dart';
import 'package:al_tadkhira/data/datasources/db_helper.dart';
import 'package:al_tadkhira/data/repositories/history_repository.dart';
import 'package:al_tadkhira/data/repositories/zikr_repository.dart';
import 'package:al_tadkhira/core/workers/notification_scheduler.dart';

// Services
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsService(prefs);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final prayerTimesServiceProvider = Provider<PrayerTimesService>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return PrayerTimesService(locationService);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Database & Repositories
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final zikrRepositoryProvider = Provider<ZikrRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return ZikrRepository(dbHelper);
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return HistoryRepository(dbHelper);
});

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler(ref);
});
