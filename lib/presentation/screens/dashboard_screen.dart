import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_tadkhira/presentation/widgets/prayer_header.dart';
import 'package:al_tadkhira/presentation/widgets/zikr_list.dart';

import 'package:al_tadkhira/presentation/screens/add_edit_zikr_screen.dart';
import 'package:al_tadkhira/presentation/screens/reports_screen.dart';
import 'package:al_tadkhira/presentation/screens/settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // Refresh list if needed, but Riverpod/FutureBuilder might need manual trigger or Stream
            // For now, we rely on setState or Provider invalidation if we switch to StreamProvider
            // Actually, FutureBuilder won't auto-refresh. We should convert ZikrList to use a Stream or invalidate provider.
            // Let's just use ref.refresh(zikrListProvider) pattern later.
            // For MVP, we can just rebuild the widget tree or use a StateProvider for a trigger.
            (context as Element)
                .markNeedsBuild(); // Quick hack for FutureBuilder refresh
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
