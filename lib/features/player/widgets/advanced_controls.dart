import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../player_providers.dart';

class AdvancedControlsSheet extends ConsumerStatefulWidget {
  const AdvancedControlsSheet({super.key});

  @override
  ConsumerState<AdvancedControlsSheet> createState() => _AdvancedControlsSheetState();
}

class _AdvancedControlsSheetState extends ConsumerState<AdvancedControlsSheet> {
  double _speed = 1.0;
  double _pitch = 1.0;

  @override
  Widget build(BuildContext context) {
    final audioHandler = ref.read(audioHandlerProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Playback Speed: ${_speed.toStringAsFixed(2)}x', style: theme.textTheme.titleMedium),
          Slider(
            value: _speed,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            label: '${_speed.toStringAsFixed(2)}x',
            onChanged: (value) {
              setState(() => _speed = value);
              audioHandler.setSpeed(value);
            },
          ),
          const SizedBox(height: 16),
          Text('Pitch: ${_pitch.toStringAsFixed(2)}', style: theme.textTheme.titleMedium),
          Slider(
            value: _pitch,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            label: _pitch.toStringAsFixed(2),
            onChanged: (value) {
              setState(() => _pitch = value);
              audioHandler.setPitch(value);
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _speed = 1.0;
                  _pitch = 1.0;
                });
                audioHandler.setSpeed(1.0);
                audioHandler.setPitch(1.0);
              },
              child: const Text('Reset Defaults'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push('/equalizer');
              },
              icon: const Icon(Icons.tune),
              label: const Text('Audio Equalizer'),
            ),
          ),
        ],
      ),
    );
  }
}

void showAdvancedControls(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const AdvancedControlsSheet(),
  );
}
