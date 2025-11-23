import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_tadkhira/presentation/providers/providers.dart';
import 'package:al_tadkhira/data/models/zikr.dart';
import 'package:al_tadkhira/presentation/screens/counter_screen.dart';

class ZikrList extends ConsumerWidget {
  const ZikrList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zikrRepository = ref.watch(zikrRepositoryProvider);

    return FutureBuilder<List<Zikr>>(
      future: zikrRepository.readAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading adhkaar'));
        }

        final zikrList = snapshot.data ?? [];

        if (zikrList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No Adhkaar yet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                const Text('Tap + to add your first Zikr'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: zikrList.length,
          itemBuilder: (context, index) {
            final zikr = zikrList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(zikr.color),
                  child: Text(
                    zikr.title[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(zikr.title),
                subtitle: zikr.note != null ? Text(zikr.note!) : null,
                trailing: zikr.dailyTarget > 0
                    ? Text('0 / ${zikr.dailyTarget}')
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CounterScreen(zikr: zikr),
                    ),
                  ).then((_) {
                    (context as Element).markNeedsBuild();
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}
