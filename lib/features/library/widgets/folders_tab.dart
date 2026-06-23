import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../library_providers.dart';

class FoldersTab extends ConsumerWidget {
  const FoldersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsStreamProvider);

    return songsAsync.when(
      data: (songs) {
        // Group songs by folder (parent directory of the URI)
        final Map<String, int> folderCounts = {};
        for (var song in songs) {
          final uri = song.uri;
          if (uri.isNotEmpty) {
            // Very naive folder extraction
            final parts = uri.split('/');
            if (parts.length > 1) {
              final folder = parts[parts.length - 2];
              folderCounts[folder] = (folderCounts[folder] ?? 0) + 1;
            }
          }
        }

        final folders = folderCounts.keys.toList()..sort();

        if (folders.isEmpty) {
          return const Center(child: Text('No folders found.'));
        }

        return ListView.builder(
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folder = folders[index];
            return ListTile(
              leading: const Icon(Icons.folder, size: 40, color: Colors.amber),
              title: Text(folder, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${folderCounts[folder]} songs'),
              onTap: () {
                // TODO: Navigate to Folder detail screen
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
