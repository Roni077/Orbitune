import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'appearance_settings_screen.dart';
import 'audio_settings_screen.dart';
import 'library_settings_screen.dart';
import 'advanced_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Appearance'),
            subtitle: const Text('Theme, colors, and visual options'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearanceSettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.audiotrack),
            title: const Text('Audio & Playback'),
            subtitle: const Text('Equalizer, streaming quality, and crossfade'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AudioSettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Library & Data'),
            subtitle: const Text('Local folders, cache, and downloads'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibrarySettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Advanced & Privacy'),
            subtitle: const Text('History, app reset, and about'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvancedSettingsScreen())),
          ),
        ],
      ),
    );
  }
}

