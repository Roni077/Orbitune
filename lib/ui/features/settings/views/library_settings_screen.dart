import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../../core/helpers/settings_provider.dart';
import '../../../../core/helpers/providers.dart';
import '../../home/viewmodels/home_viewmodel.dart';
import 'folder_selection_dialog.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LibrarySettingsScreen extends ConsumerWidget {
  const LibrarySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library & Data'),
      ),
      body: ListView(
        children: [
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
              ref.invalidate(homeLocalTracksProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Library rescan initiated!')),
                );
              }
            },
          ),
          const Divider(),
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
            subtitle: const Text('Remove old history and orphaned tracks'),
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
        ],
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
