import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/audio/audio_service_provider.dart';
import 'dart:math';
import 'dart:convert';

class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  String _selectedPreset = 'Custom';
  double _loudnessGain = 0.0;
  double _pitch = 1.0;
  bool _customLoaded = false;

  static const Map<String, List<double>> _presets = {
    'Normal': [0.0, 0.0, 0.0, 0.0, 0.0],
    'Pop': [-1.0, 2.0, 5.0, 1.0, -2.0],
    'Classic': [5.0, 3.0, -2.0, 4.0, 4.0],
    'Classical': [5.0, 3.0, -2.0, 4.0, 4.0],
    'Jazz': [4.0, 2.0, -2.0, 2.0, 5.0],
    'Rock': [5.0, 3.0, -1.0, 3.0, 5.0],
    'Bass Boost': [10.0, 5.0, 0.0, 0.0, 0.0],
    'Dance': [6.0, 0.0, 2.0, 4.0, 1.0],
    'Electronic': [4.0, -1.0, 1.0, -2.0, 5.0],
    'Hip-Hop': [5.0, 3.0, 0.0, 1.0, 3.0],
    'Vocal': [-2.0, -1.0, 4.0, 3.0, -2.0],
  };

  void _applyPreset(String presetName, AndroidEqualizerParameters parameters) async {
    setState(() {
      _selectedPreset = presetName;
    });
    
    List<double>? presetGains;
    
    if (presetName == 'Custom') {
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getString('custom_eq_preset');
      if (customJson != null) {
        try {
          presetGains = List<double>.from(jsonDecode(customJson));
        } catch (_) {}
      }
      // If no saved custom preset, just leave it as is
      if (presetGains == null) return;
    } else {
      presetGains = _presets[presetName];
    }
    
    if (presetGains == null) return;

    final numBands = parameters.bands.length;
    for (int i = 0; i < numBands; i++) {
      // Map i from [0, numBands-1] to [0, presetGains.length-1]
      int presetIndex = (i * (presetGains.length - 1) / max(1, numBands - 1)).round();
      final targetGain = presetGains[presetIndex];
      // clamp to min/max
      final clampedGain = max(parameters.minDecibels, min(parameters.maxDecibels, targetGain));
      parameters.bands[i].setGain(clampedGain);
    }
  }

  Future<void> _saveCustomPreset(AndroidEqualizerParameters parameters) async {
    final prefs = await SharedPreferences.getInstance();
    final gains = parameters.bands.map((b) => b.gain).toList();
    await prefs.setString('custom_eq_preset', jsonEncode(gains));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom preset saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final theme = Theme.of(context);
    final equalizer = audioHandler.equalizer;
    final loudnessEnhancer = audioHandler.loudnessEnhancer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer & Effects'),
        centerTitle: true,
      ),
      body: FutureBuilder<AndroidEqualizerParameters>(
        future: equalizer.parameters,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Equalizer is not supported on this device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
          final parameters = snapshot.data;
          if (parameters == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_customLoaded) {
            _customLoaded = true;
            Future.microtask(() {
              _applyPreset('Custom', parameters);
            });
          }

          return StreamBuilder<bool>(
            stream: equalizer.enabledStream,
            builder: (context, enabledSnapshot) {
              final isEnabled = enabledSnapshot.data ?? false;

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                children: [
                  SwitchListTile(
                    title: const Text('Enable Equalizer', style: TextStyle(fontWeight: FontWeight.bold)),
                    value: isEnabled,
                    onChanged: (value) {
                      equalizer.setEnabled(value);
                      loudnessEnhancer.setEnabled(value);
                    },
                  ),
                  const Divider(),
                  Opacity(
                    opacity: isEnabled ? 1.0 : 0.5,
                    child: IgnorePointer(
                      ignoring: !isEnabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Preset', style: TextStyle(fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    if (_selectedPreset == 'Custom')
                                      IconButton(
                                        icon: const Icon(Icons.save),
                                        onPressed: () => _saveCustomPreset(parameters),
                                        tooltip: 'Save Custom Preset',
                                      ),
                                    DropdownButton<String>(
                                      value: _selectedPreset,
                                      underline: const SizedBox(),
                                      items: ['Custom', ..._presets.keys].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          _applyPreset(newValue, parameters);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: parameters.bands.map((band) {
                                return _buildSliderBand(context, band, parameters, theme);
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text('Loudness Enhancer (Boost)', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                          ),
                          Slider(
                            value: _loudnessGain,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            label: '${(_loudnessGain * 100).round()}%',
                            onChanged: (value) {
                              setState(() {
                                _loudnessGain = value;
                              });
                              // Assuming max boost is 2000mB (20dB) or typical max
                              loudnessEnhancer.setTargetGain(value * 2000.0);
                            },
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pitch Control', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                                Text('${_pitch.toStringAsFixed(2)}x', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Slider(
                            value: _pitch,
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            label: '${_pitch.toStringAsFixed(2)}x',
                            onChanged: (value) {
                              setState(() {
                                _pitch = value;
                              });
                              ref.read(audioHandlerProvider).setPitch(value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSliderBand(BuildContext context, AndroidEqualizerBand band, AndroidEqualizerParameters parameters, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          band.centerFrequency >= 1000 
            ? '${(band.centerFrequency / 1000).toStringAsFixed(1)}k' 
            : '${band.centerFrequency.round()}Hz',
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: max(parameters.minDecibels, min(parameters.maxDecibels, band.gain)),
              min: parameters.minDecibels,
              max: parameters.maxDecibels,
              thumbColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.surfaceContainerHighest,
              onChanged: (value) {
                band.setGain(value);
                if (_selectedPreset != 'Custom') {
                  setState(() {
                    _selectedPreset = 'Custom';
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${band.gain > 0 ? '+' : ''}${band.gain.toStringAsFixed(1)} dB',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
