import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../player/player_providers.dart';

class PlaybackSettingsScreen extends ConsumerStatefulWidget {
  const PlaybackSettingsScreen({super.key});

  @override
  ConsumerState<PlaybackSettingsScreen> createState() => _PlaybackSettingsScreenState();
}

class _PlaybackSettingsScreenState extends ConsumerState<PlaybackSettingsScreen> {
  int _sleepMinutes = 0;

  @override
  Widget build(BuildContext context) {
    final audioHandler = ref.watch(audioHandlerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playback'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Sleep Timer'),
            subtitle: Text(_sleepMinutes == 0 ? 'Off' : '$_sleepMinutes minutes'),
            trailing: const Icon(Icons.timer),
            onTap: () {
              // Show a dialog to select sleep timer duration
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Set Sleep Timer'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [0, 15, 30, 60, 120].map((mins) {
                        return ListTile(
                          title: Text(mins == 0 ? 'Off' : '$mins minutes'),
                          onTap: () {
                            setState(() {
                              _sleepMinutes = mins;
                            });
                            if (mins == 0) {
                              audioHandler.cancelSleepTimer();
                            } else {
                              audioHandler.startSleepTimer(Duration(minutes: mins));
                            }
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
