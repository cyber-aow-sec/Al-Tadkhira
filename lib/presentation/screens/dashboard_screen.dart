import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_tadkhira/presentation/widgets/prayer_header.dart';
import 'package:al_tadkhira/presentation/widgets/zikr_list.dart';
import 'package:al_tadkhira/presentation/providers/providers.dart';

import 'package:al_tadkhira/presentation/screens/add_edit_zikr_screen.dart';
import 'package:al_tadkhira/presentation/screens/reports_screen.dart';
import 'package:al_tadkhira/presentation/screens/settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Request permission on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermission();
    });
  }

  Future<void> _checkPermission() async {
    final locationService = ref.read(locationServiceProvider);
    await locationService.handlePermission();
    // After permission handling, we might want to trigger a refresh of prayer times
    // if the header is listening to something, or just let the user interact.
    // Ideally, we'd have a provider for "current location" that updates.
    // For now, we rely on the PrayerHeader to handle its own state or retry.
    // But to make it seamless, we can force a rebuild if we want, but let's stick to the plan:
    // 1. Request here.
    // 2. PrayerHeader handles "no permission" state with a button.
    // If the user grants it here, the PrayerHeader might still show error until refreshed.
    // We can fix that by making PrayerHeader watch a location provider, but let's keep it simple first.
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Tadhkirah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Pass a key or value to force rebuild if needed, or just let it be.
            // Since we call setState after permission check, it might rebuild.
            const PrayerHeader(),
            Expanded(child: const ZikrList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditZikrScreen()),
          ).then((_) {
            // Refresh list if needed
            (context as Element).markNeedsBuild();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
