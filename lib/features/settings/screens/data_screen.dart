import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DataSettingsScreen extends ConsumerWidget {
  const DataSettingsScreen({super.key});

  Future<void> _backupDatabase(BuildContext context) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final dbFile = File('${docDir.path}/default.isar');
      
      if (!await dbFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database file not found.')),
          );
        }
        return;
      }

      // Without file_picker/share_plus, we fallback to a hardcoded backup path
      // On Android, we can try to write to a public documents directory if available
      Directory? externalDir = await getExternalStorageDirectory();
      externalDir ??= docDir;

      final backupPath = '${externalDir.path}/orbitune_backup.isar';
      await dbFile.copy(backupPath);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup saved to: $backupPath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      Directory? externalDir = await getExternalStorageDirectory();
      externalDir ??= docDir;
      
      final backupFile = File('${externalDir.path}/orbitune_backup.isar');

      if (!await backupFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No backup found at: ${backupFile.path}')),
          );
        }
        return;
      }

      final dbFile = File('${docDir.path}/default.isar');
      await backupFile.copy(dbFile.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored. Please restart the app.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Backup'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Save and restore your library data, playlists, and settings.'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _backupDatabase(context),
            icon: const Icon(Icons.upload),
            label: const Text('Backup Library'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _restoreDatabase(context),
            icon: const Icon(Icons.download),
            label: const Text('Restore Library'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Note: Restart the app after a successful restore to load the data.',
            style: TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
