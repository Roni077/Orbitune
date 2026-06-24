import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../themes/theme_provider.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Use Dynamic Colors'),
            subtitle: const Text('Extract colors from your wallpaper'),
            value: themeState.useDynamicColor,
            onChanged: (val) {
              ref.read(themeProvider.notifier).toggleDynamicColor(val);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...ThemeType.values.map((type) {
            // ignore: deprecated_member_use
            return RadioListTile<ThemeType>(
              title: Text(type.name[0].toUpperCase() + type.name.substring(1)),
              value: type,
              // ignore: deprecated_member_use
              groupValue: themeState.themeType,
              // ignore: deprecated_member_use
              onChanged: (ThemeType? value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setTheme(value);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
