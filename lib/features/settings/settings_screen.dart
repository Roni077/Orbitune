import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Appearance'),
            subtitle: const Text('Theme, dynamic colors'),
            leading: const Icon(Icons.palette),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/appearance'),
          ),
          ListTile(
            title: const Text('Playback'),
            subtitle: const Text('Sleep timer, audio tweaks'),
            leading: const Icon(Icons.play_circle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/playback'),
          ),
          ListTile(
            title: const Text('Data & Backup'),
            subtitle: const Text('Backup library and restore'),
            leading: const Icon(Icons.storage),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/data'),
          ),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('Version info, licenses'),
            leading: const Icon(Icons.info),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/about'),
          ),
        ],
      ),
    );
  }
}
