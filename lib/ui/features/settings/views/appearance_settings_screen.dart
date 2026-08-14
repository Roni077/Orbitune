import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/settings_provider.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    
    final presetColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Mode'),
            subtitle: const Text('Choose light, dark, or system theme'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) notifier.updateThemeMode(newValue);
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('AMOLED Dark Mode'),
            subtitle: const Text('Use pitch black for dark mode'),
            value: settings.amoledMode,
            onChanged: settings.themeMode == ThemeMode.light ? null : (value) {
              notifier.updateAmoledMode(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.color_lens),
            title: const Text('Dynamic Colors'),
            subtitle: const Text('Use Material You colors based on wallpaper'),
            value: settings.dynamicColors,
            onChanged: (value) {
              notifier.updateDynamicColors(value);
            },
          ),
          if (!settings.dynamicColors) ...[
            ListTile(
              leading: const Icon(Icons.format_paint),
              title: const Text('Accent Color'),
              subtitle: const Text('Choose a custom accent color'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: presetColors.map((color) {
                    final isSelected = settings.accentColor == color.toARGB32();
                    return GestureDetector(
                      onTap: () => notifier.updateAccentColor(color),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2) : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
