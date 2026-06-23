import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../themes/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Use Dynamic Colors'),
            subtitle: const Text('Extract colors from your wallpaper'),
            value: themeState.useDynamicColor,
            onChanged: (val) {
              ref.read(themeProvider.notifier).toggleDynamicColor(val);
            },
          ),
          ListTile(
            title: const Text('Theme Mode'),
            subtitle: Text(themeState.themeType.name.toUpperCase()),
            trailing: const Icon(Icons.palette),
            onTap: () {
              // Cycle through themes for now
              final currentIdx = ThemeType.values.indexOf(themeState.themeType);
              final nextIdx = (currentIdx + 1) % ThemeType.values.length;
              ref.read(themeProvider.notifier).setTheme(ThemeType.values[nextIdx]);
            },
          )
        ],
      ),
    );
  }
}
