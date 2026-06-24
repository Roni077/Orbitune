import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../player/player_providers.dart';
import '../../core/providers.dart';

class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  double _loudnessGain = 0.0;
  bool _isInit = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final equalizer = ref.watch(equalizerProvider);
    final loudnessEnhancer = ref.watch(loudnessEnhancerProvider);
    final prefs = ref.watch(sharedPreferencesProvider);

    if (!_isInit) {
      _loudnessGain = (prefs.getDouble('loudness_gain') ?? 0.0) * 1000.0;
      _isInit = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Enhancement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master EQ Switch
            StreamBuilder<bool>(
              stream: equalizer.enabledStream,
              builder: (context, snapshot) {
                final enabled = snapshot.data ?? false;
                return SwitchListTile(
                  title: Text(
                    'Equalizer',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  value: enabled,
                  onChanged: (val) {
                    equalizer.setEnabled(val);
                    prefs.setBool('eq_enabled', val);
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: theme.colorScheme.primary,
                );
              },
            ),
            const SizedBox(height: 16),

            // EQ Parameters
            FutureBuilder<AndroidEqualizerParameters>(
              future: equalizer.parameters,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Equalizer not supported on this device.');
                }

                final params = snapshot.data!;
                return SizedBox(
                  height: 250,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: params.bands.map((band) {
                      return Column(
                        children: [
                          Expanded(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: StreamBuilder<double>(
                                stream: band.gainStream,
                                initialData: band.gain,
                                builder: (context, gainSnapshot) {
                                  final currentGain = gainSnapshot.data ?? 0.0;
                                  return Slider(
                                    min: params.minDecibels,
                                    max: params.maxDecibels,
                                    value: max(params.minDecibels, min(params.maxDecibels, currentGain)),
                                    onChanged: (val) {
                                      band.setGain(val);
                                      prefs.setDouble('eq_band_${band.index}', val);
                                    },
                                    activeColor: theme.colorScheme.primary,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${(band.centerFrequency / 1000).toStringAsFixed(1)}k',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                          ),
                          StreamBuilder<double>(
                            stream: band.gainStream,
                            initialData: band.gain,
                            builder: (context, gainSnapshot) {
                              final currentGain = gainSnapshot.data ?? 0.0;
                              return Text(
                                '${currentGain > 0 ? '+' : ''}${currentGain.toStringAsFixed(1)}',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                              );
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),
            const Divider(color: Colors.white24),
            const SizedBox(height: 24),

            // Loudness Enhancer
            StreamBuilder<bool>(
              stream: loudnessEnhancer.enabledStream,
              builder: (context, snapshot) {
                final enabled = snapshot.data ?? false;
                return SwitchListTile(
                  title: Text(
                    'Loudness Enhancer',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  value: enabled,
                  onChanged: (val) {
                    loudnessEnhancer.setEnabled(val);
                    prefs.setBool('loudness_enabled', val);
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: theme.colorScheme.primary,
                );
              },
            ),
            Slider(
              min: 0,
              max: 1000,
              value: _loudnessGain,
              onChanged: (val) {
                setState(() => _loudnessGain = val);
                loudnessEnhancer.setTargetGain(val / 1000.0);
                prefs.setDouble('loudness_gain', val / 1000.0);
              },
              activeColor: theme.colorScheme.primary,
            ),
            Center(
              child: Text(
                'Gain: ${(_loudnessGain / 1000.0).toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
