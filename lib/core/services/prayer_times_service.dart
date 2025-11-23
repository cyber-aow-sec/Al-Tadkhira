import 'package:adhan/adhan.dart';

import 'package:al_tadkhira/core/services/location_service.dart';

class PrayerTimesService {
  final LocationService _locationService;

  PrayerTimesService(this._locationService);

  Future<PrayerTimes?> getPrayerTimes({
    required DateTime date,
    CalculationMethod method = CalculationMethod.muslim_world_league,
  }) async {
    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      // TODO: Handle manual location fallback
      return null;
    }

    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = method.getParameters();
    params.madhab = Madhab.shafi; // Default, make configurable later

    return PrayerTimes.today(coordinates, params);
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
