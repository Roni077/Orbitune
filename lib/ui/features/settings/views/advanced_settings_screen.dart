import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/settings_provider.dart';
import '../../../../domain/repositories/history_repository.dart';
import '../../search/viewmodels/search_viewmodel.dart';


class AdvancedSettingsScreen extends ConsumerWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced & Privacy'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.history_toggle_off),
            title: const Text('Pause Listening History'),
            subtitle: const Text('Stop recording recently played songs'),
            value: settings.pauseHistory,
            onChanged: (value) {
              notifier.updatePauseHistory(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.manage_search),
            title: const Text('Pause Search History'),
            subtitle: const Text('Stop saving your search queries'),
            value: settings.pauseSearchHistory,
            onChanged: (value) {
              notifier.updatePauseSearchHistory(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Search History'),
            subtitle: const Text('Remove all previous search terms'),
            onTap: () async {
              await ref.read(searchHistoryProvider.notifier).clearHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search history cleared!')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Clear Listening History'),
            subtitle: const Text('Remove all recorded play events'),
            onTap: () async {
              final historyRepo = ref.read(historyRepositoryProvider);
              await historyRepo.clearHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared successfully!')),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Orbitune'),
            subtitle: const Text('Version 1.0.0\nDeveloped with ♥'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Orbitune',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.music_note, size: 48),
                children: [
                  const Text('A beautiful and minimal local and online music player.'),
                  const SizedBox(height: 16),
                  const Text('Privacy Policy:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Orbitune respects your privacy. It collects no analytics, telemetry, or user data. All listening history and preferences are stored locally on your device.'),
                  const SizedBox(height: 16),
                  const Text('Third-Party Providers:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Orbitune accesses public metadata via YouTube. By using these features, you must comply with their respective Terms of Service.'),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Open-source Licenses'),
            subtitle: const Text('View third-party software licenses'),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Orbitune',
                applicationVersion: '1.0.0',
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.red),
            title: const Text('Reset App Settings', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Restore default preferences'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Settings?'),
                  content: const Text('Are you sure you want to restore all settings to default? Your library and history will not be deleted.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
                  ],
                ),
              );
              
              if (confirm == true) {
                final prefs = ref.read(sharedPreferencesProvider);
                await prefs.clear();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings reset! Please restart the app.')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
