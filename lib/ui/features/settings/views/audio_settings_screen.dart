import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/settings_provider.dart';
import '../../player/views/equalizer_screen.dart';

class AudioSettingsScreen extends ConsumerWidget {
  const AudioSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio & Playback'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.equalizer),
            title: const Text('Equalizer & Audio Effects'),
            subtitle: const Text('Adjust bass, pitch, and frequencies'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EqualizerScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('Crossfade Duration'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.crossfadeDuration == 0
                      ? 'Disabled'
                      : '${settings.crossfadeDuration} seconds',
                ),
                Slider(
                  value: settings.crossfadeDuration.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: '${settings.crossfadeDuration}s',
                  onChanged: (val) {
                    notifier.updateCrossfadeDuration(val.toInt());
                  },
                ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.queue_music),
            title: const Text('Autoplay Related Songs'),
            subtitle: const Text('Automatically add related tracks to queue'),
            value: settings.autoplay,
            onChanged: (value) {
              notifier.updateAutoplay(value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Streaming Quality'),
            subtitle: Text(settings.streamingQuality),
            trailing: PopupMenuButton<String>(
              initialValue: settings.streamingQuality,
              onSelected: (String quality) {
                notifier.updateStreamingQuality(quality);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'Auto', child: Text('Auto')),
                const PopupMenuItem<String>(value: 'Low', child: Text('Low')),
                const PopupMenuItem<String>(value: 'Medium', child: Text('Medium')),
                const PopupMenuItem<String>(value: 'High', child: Text('High')),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.wifi_tethering_off),
            title: const Text('Wi-Fi Only Streaming'),
            subtitle: const Text('Prevent streaming over cellular data'),
            value: settings.wifiOnlyStreaming,
            onChanged: (value) {
              notifier.updateWifiOnlyStreaming(value);
            },
          ),
        ],
      ),
    );
  }
}
