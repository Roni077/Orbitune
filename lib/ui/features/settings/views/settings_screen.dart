import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../../core/helpers/settings_provider.dart';
import '../../../../domain/repositories/history_repository.dart';
import '../../../../core/helpers/providers.dart';
import 'folder_selection_dialog.dart';
import '../../home/viewmodels/home_viewmodel.dart';
import '../../player/views/equalizer_screen.dart';
import '../../search/viewmodels/search_viewmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Appearance'),
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
          const Divider(),
          _buildSectionHeader(context, 'Playback'),
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
          _buildSectionHeader(context, 'Library'),
          ListTile(
            leading: const Icon(Icons.folder_special),
            title: const Text('Folder Selection'),
            subtitle: const Text('Choose which folders to scan for music'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const FolderSelectionDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Rescan Library'),
            subtitle: const Text('Force refresh local songs'),
            onTap: () async {
              // We invalidate the provider to trigger a rescan/re-fetch
              // Since we are using on_audio_query which reads MediaStore,
              // this effectively pulls the latest MediaStore state.
              ref.invalidate(homeLocalTracksProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Library rescan initiated!')),
                );
              }
            },
          ),
          const Divider(),

          _buildSectionHeader(context, 'Audio'),
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
          _buildSectionHeader(context, 'Streaming'),
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
          const Divider(),
          _buildSectionHeader(context, 'Privacy & History'),
          SwitchListTile(
            secondary: const Icon(Icons.history_toggle_off),
            title: const Text('Pause Listening History'),
            subtitle: const Text('Stop recording recently played songs'),
            value: settings.pauseHistory,
            onChanged: (value) {
              notifier.updatePauseHistory(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.manage_search),
            title: const Text('Pause Search History'),
            subtitle: const Text('Stop saving your search queries'),
            value: settings.pauseSearchHistory,
            onChanged: (value) {
              notifier.updatePauseSearchHistory(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Search History'),
            subtitle: const Text('Remove all previous search terms'),
            onTap: () async {
              await ref.read(searchHistoryProvider.notifier).clearHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search history cleared!')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Clear Listening History'),
            subtitle: const Text('Remove all recorded play events'),
            onTap: () async {
              final historyRepo = ref.read(historyRepositoryProvider);
              await historyRepo.clearHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared successfully!')),
                );
              }
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Downloads'),
          SwitchListTile(
            secondary: const Icon(Icons.wifi),
            title: const Text('Download over Wi-Fi Only'),
            subtitle: const Text('Prevent using mobile data for downloads'),
            value: settings.wifiOnlyDownload,
            onChanged: (value) {
              notifier.updateWifiOnlyDownload(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Download Location'),
            subtitle: const Text('Managed automatically by OS'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download location is managed automatically via Scoped Storage.')),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Storage & Cache'),
          SwitchListTile(
            secondary: const Icon(Icons.auto_delete),
            title: const Text('Auto Cache Cleanup'),
            subtitle: const Text('Automatically clean cache when space is low'),
            value: settings.autoCacheCleanup,
            onChanged: (value) {
              notifier.updateAutoCacheCleanup(value);
            },
          ),
          FutureBuilder<String>(
            future: _calculateStorageUsage(),
            builder: (context, snapshot) {
              final subtitle = snapshot.connectionState == ConnectionState.waiting
                  ? 'Calculating...'
                  : (snapshot.data ?? 'Unknown');
              return ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Storage Usage'),
                subtitle: Text(subtitle),
                onTap: null,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('Clear Image Cache'),
            subtitle: const Text('Frees up storage space'),
            onTap: () async {
              await DefaultCacheManager().emptyCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image cache cleared successfully!')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Clean Database'),
            subtitle: const Text('Remove old history and orphaned online tracks'),
            onTap: () async {
              final db = ref.read(databaseProvider);
              await db.cleanUpDatabase();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database cleaned successfully!')),
                );
              }
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Orbitune'),
            subtitle: const Text('Version 1.0.0\nDeveloped with ♥'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Orbitune',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.music_note, size: 48),
                children: [
                  const Text('A beautiful and minimal local and online music player.'),
                  const SizedBox(height: 16),
                  const Text('Privacy Policy:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Orbitune respects your privacy. It collects no analytics, telemetry, or user data. All listening history and preferences are stored locally on your device.'),
                  const SizedBox(height: 16),
                  const Text('Third-Party Providers:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Orbitune accesses public metadata via YouTube. By using these features, you must comply with their respective Terms of Service.'),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Open-source Licenses'),
            subtitle: const Text('View third-party software licenses'),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Orbitune',
                applicationVersion: '1.0.0',
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Advanced'),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.red),
            title: const Text('Reset App Settings', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Restore default preferences'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Settings?'),
                  content: const Text('Are you sure you want to restore all settings to default? Your library and history will not be deleted.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
                  ],
                ),
              );
              
              if (confirm == true) {
                final prefs = ref.read(sharedPreferencesProvider);
                await prefs.clear();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings reset! Please restart the app.')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<String> _calculateStorageUsage() async {
    try {
      int totalBytes = 0;
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        totalBytes += _getDirSize(tempDir);
      }
      final docDir = await getApplicationDocumentsDirectory();
      if (docDir.existsSync()) {
        totalBytes += _getDirSize(docDir);
      }
      
      if (totalBytes < 1024) return '$totalBytes B';
      if (totalBytes < 1024 * 1024) return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
      if (totalBytes < 1024 * 1024 * 1024) return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } catch (e) {
      return 'Error calculating size';
    }
  }

  int _getDirSize(Directory dir) {
    int size = 0;
    try {
      if (dir.existsSync()) {
        dir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
          if (entity is File) {
            size += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      // Ignore errors for unreadable files
    }
    return size;
  }
}
