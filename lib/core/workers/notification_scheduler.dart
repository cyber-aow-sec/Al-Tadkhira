import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_tadkhira/core/services/notification_service.dart';
import 'package:al_tadkhira/core/services/prayer_times_service.dart'; // ignore: unused_import
import 'package:al_tadkhira/data/repositories/zikr_repository.dart'; // ignore: unused_import
import 'package:al_tadkhira/data/models/zikr.dart';
import 'package:al_tadkhira/presentation/providers/providers.dart';
import 'package:adhan/adhan.dart'; // ignore: unused_import

class NotificationScheduler {
  final Ref ref;

  NotificationScheduler(this.ref);

  Future<void> scheduleDailyNotifications() async {
    final notificationService = ref.read(notificationServiceProvider);
    final prayerService = ref.read(prayerTimesServiceProvider);
    final zikrRepo = ref.read(zikrRepositoryProvider);

    await notificationService.cancelAll();

    final prayerTimes = await prayerService.getPrayerTimes(
      date: DateTime.now(),
    );
    if (prayerTimes == null) return;

    final adhkaar = await zikrRepo.readAll();
    final mandatoryAdhkaar = adhkaar.where((z) => z.isMandatory).toList();

    if (mandatoryAdhkaar.isEmpty) return;

    // Schedule for each prayer
    _scheduleForPrayer(
      notificationService,
      prayerTimes.fajr,
      'Fajr',
      mandatoryAdhkaar,
    );
    _scheduleForPrayer(
      notificationService,
      prayerTimes.dhuhr,
      'Dhuhr',
      mandatoryAdhkaar,
    );
    _scheduleForPrayer(
      notificationService,
      prayerTimes.asr,
      'Asr',
      mandatoryAdhkaar,
    );
    _scheduleForPrayer(
      notificationService,
      prayerTimes.maghrib,
      'Maghrib',
      mandatoryAdhkaar,
    );
    _scheduleForPrayer(
      notificationService,
      prayerTimes.isha,
      'Isha',
      mandatoryAdhkaar,
    );
  }

  void _scheduleForPrayer(
    NotificationService service,
    DateTime time,
    String prayerName,
    List<Zikr> adhkaar,
  ) {
    // Filter adhkaar linked to this prayer or all mandatory
    // For simplicity, just remind generic "Time for [Prayer] Adhkaar"

    if (time.isAfter(DateTime.now())) {
      service.schedulePrayerReminder(
        id: time.hashCode,
        title: '$prayerName Adhkaar',
        body: 'Don\'t forget your mandatory adhkaar after $prayerName.',
        scheduledTime: time.add(
          const Duration(minutes: 10),
        ), // 10 mins after prayer?
      );
    }
  }
}
