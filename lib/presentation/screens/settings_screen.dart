import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_tadkhira/presentation/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showMethodDialog(BuildContext context) {
    final settingsService = ref.read(settingsServiceProvider);
    final currentMethod = settingsService.getCalculationMethod();

    final methods = [
      'Muslim World League',
      'Egyptian General Authority of Survey',
      'University of Islamic Sciences, Karachi',
      'Umm al-Qura University, Makkah',
      'Dubai',
      'Qatar',
      'Kuwait',
      'Singapore',
      'Turkey',
      'Tehran',
      'North America',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Calculation Method'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(methods.length, (index) {
                return RadioListTile<int>(
                  title: Text(methods[index]),
                  value: index,
                  groupValue: currentMethod,
                  onChanged: (value) async {
                    if (value != null) {
                      await settingsService.setCalculationMethod(value);
                      // Refresh prayer times
                      // We might need to trigger a refresh in PrayerHeader or just setState here if it affects this screen (it doesn't directly)
                      // But we should probably notify the user or refresh the app state.
                      // Since PrayerHeader watches the provider, if we update the service state... wait, the service state isn't watched for *settings* changes directly unless we make settings a provider that notifies.
                      // Currently SettingsService is just a class.
                      // We should probably make SettingsService a ChangeNotifier or use a StateNotifier for settings.
                      // For now, simple setState to update UI here if needed, and maybe force refresh prayer times?
                      // The PrayerTimesService reads settings on every call, so next call will be correct.
                      // We can force a refresh by invalidating the provider if we had a FutureProvider for prayer times.
                      // But PrayerHeader calls getPrayerTimes in build/initState.
                      // Let's just pop for now.
                      if (context.mounted) {
                        Navigator.pop(context);
                        setState(
                          () {},
                        ); // Refresh this screen to show updated value if we displayed it
                      }
                    }
                  },
                );
              }),
            ),
          ),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    final settingsService = ref.read(settingsServiceProvider);
    final currentThemeMode = settingsService.getThemeMode();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                value: ThemeMode.system,
                groupValue: currentThemeMode,
                onChanged: (value) async {
                  if (value != null) {
                    await settingsService.setThemeMode(value);
                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() {});
                      // Note: To make the app react to theme changes immediately,
                      // the main App widget needs to watch the settings/theme.
                      // We'll need to check main.dart.
                    }
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: currentThemeMode,
                onChanged: (value) async {
                  if (value != null) {
                    await settingsService.setThemeMode(value);
                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: currentThemeMode,
                onChanged: (value) async {
                  if (value != null) {
                    await settingsService.setThemeMode(value);
                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = ref.watch(settingsServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Calculation Method'),
            subtitle: const Text('Choose how prayer times are calculated'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showMethodDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(settingsService.getThemeMode().name.toUpperCase()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showThemeDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Daily Reset Time'),
            subtitle: const Text(
              'Set when daily zikr counts reset (Default: Midnight)',
            ),
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
}
