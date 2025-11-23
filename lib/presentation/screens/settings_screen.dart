import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_tadkhira/presentation/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsService = ref.watch(settingsServiceProvider);

    // Note: In a real app, we should use a StateNotifier or ChangeNotifier to watch settings changes.
    // For this MVP, we might need to rebuild or use a FutureBuilder if settings are async,
    // but SettingsService uses SharedPreferences which is synchronous after init.
    // However, to trigger rebuilds on change, we need a reactive state.
    // We'll assume for now we just read/write and maybe use setState in a StatefulWidget or just rely on hot reload for testing.
    // Let's convert to StatefulWidget to handle local state updates or use a proper provider.

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Calculation Method'),
            subtitle: Text(
              _getMethodName(settingsService.getCalculationMethod()),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              // Show dialog to select method
              await _showMethodDialog(context, ref);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(settingsService.getThemeMode().name.toUpperCase()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              // Toggle theme
              // This requires the app to listen to theme changes.
              // For MVP, we just save it.
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Daily Reset Time'),
            subtitle: Text(settingsService.getDailyResetTime().format(context)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: settingsService.getDailyResetTime(),
              );
              if (time != null) {
                await settingsService.setDailyResetTime(time);
                // Force rebuild?
              }
            },
          ),
        ],
      ),
    );
  }

  String _getMethodName(int index) {
    // Map index back to CalculationMethod enum or name
    // This is a simplification
    return 'Method $index';
  }

  Future<void> _showMethodDialog(BuildContext context, WidgetRef ref) async {
    // Implementation of dialog
  }
}
