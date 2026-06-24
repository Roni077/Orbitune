import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutSettingsScreen extends ConsumerWidget {
  const AboutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.music_note, size: 50),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Orbitune',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text('Version 1.0.0'),
          ),
          const SizedBox(height: 32),
          ListTile(
            title: const Text('Licenses'),
            leading: const Icon(Icons.description),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Orbitune',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.music_note),
              );
            },
          ),
          const ListTile(
            title: Text('Developer'),
            subtitle: Text('Roni077'),
            leading: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
