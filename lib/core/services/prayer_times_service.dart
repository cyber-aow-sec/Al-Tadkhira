import 'package:adhan/adhan.dart';

import 'package:al_tadkhira/core/services/location_service.dart';

import 'package:al_tadkhira/core/services/settings_service.dart';

class PrayerTimesService {
  final LocationService _locationService;
  final SettingsService _settingsService;

  PrayerTimesService(this._locationService, this._settingsService);

  Future<PrayerTimes?> getPrayerTimes({required DateTime date}) async {
    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      // TODO: Handle manual location fallback
      return null;
    }

    final coordinates = Coordinates(position.latitude, position.longitude);

    // Get method from settings
    // We need to map int to CalculationMethod.
    // Adhan doesn't have a direct 'values' list that matches our int index perfectly if we just stored arbitrary index.
    // But we can assume we store the index of a list we define, or map it.
    // Let's assume we store the index corresponding to a list of methods we support.
    // For now, let's just support a few common ones or all.
    // Adhan's CalculationMethod is a class with static consts, not an enum in some versions, but let's check.
    // If it's an enum, we can use values[index].
    // If it's a class, we need a helper.
    // Let's assume it's an enum-like class.
    // We'll define a helper list here or in SettingsService.
    // Let's use a helper method to get the CalculationMethod from the index.
    final methodIndex = _settingsService.getCalculationMethod();
    final method = _getMethodFromIndex(methodIndex);

    final params = method.getParameters();
    params.madhab = Madhab.shafi; // Default, make configurable later

    return PrayerTimes.today(coordinates, params);
  }

  CalculationMethod _getMethodFromIndex(int index) {
    // This mapping must match what we show in SettingsScreen
    final methods = [
      CalculationMethod.muslim_world_league,
      CalculationMethod.egyptian,
      CalculationMethod.karachi,
      CalculationMethod.umm_al_qura,
      CalculationMethod.dubai,
      CalculationMethod.qatar,
      CalculationMethod.kuwait,
      CalculationMethod.singapore,
      CalculationMethod.turkey,
      CalculationMethod.tehran,
      CalculationMethod.north_america,
    ];
    if (index >= 0 && index < methods.length) {
      return methods[index];
    }
    return CalculationMethod.muslim_world_league;
  }

  Prayer getCurrentPrayer(PrayerTimes prayerTimes) {
    return prayerTimes.currentPrayer();
  }

  Prayer getNextPrayer(PrayerTimes prayerTimes) {
    return prayerTimes.nextPrayer();
  }

  DateTime? getTimeForPrayer(PrayerTimes prayerTimes, Prayer prayer) {
    return prayerTimes.timeForPrayer(prayer);
  }
}
