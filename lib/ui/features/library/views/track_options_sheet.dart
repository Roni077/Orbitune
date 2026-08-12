import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../domain/entities/track.dart';
import '../viewmodels/local_songs_viewmodel.dart';
import 'add_to_playlist_sheet.dart';
import '../../../../domain/repositories/track_repository.dart';
import '../../../../services/downloads/download_manager.dart';

class TrackOptionsSheet extends ConsumerWidget {
  final Track track;

  const TrackOptionsSheet({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocal = track.source == TrackSource.local;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.music_note),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(track.artist, style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to Playlist'),
            onTap: () {
              Navigator.pop(context);
              showAddToPlaylistSheet(context, [track]);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('File Info'),
            onTap: () {
              Navigator.pop(context);
              _showFileInfo(context, track);
            },
          ),
          if (!isLocal)
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                final mediaItem = MediaItem(
                  id: track.id,
                  title: track.title,
                  artist: track.artist,
                  extras: {'url': track.dataUrl},
                );
                ref.read(downloadManagerProvider.notifier).enqueue(mediaItem);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added "${track.title}" to download queue')),
                );
              },
            ),
          if (isLocal) ...[
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Open Source File'),
              onTap: () async {
                Navigator.pop(context);
                final file = File(track.dataUrl);
                if (file.existsSync()) {
                  await OpenFilex.open(track.dataUrl);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File not found')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete from Device', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                _confirmDelete(context, ref, track);
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showFileInfo(BuildContext context, Track track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Track Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${track.title}'),
              Text('Artist: ${track.artist}'),
              Text('Album: ${track.album}'),
              const SizedBox(height: 8),
              Text('Source: ${track.source.name}'),
              const SizedBox(height: 8),
              const Text('File Path:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(track.dataUrl, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Track track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File?'),
        content: Text('Are you sure you want to permanently delete "${track.title}" from your device? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(context, ref, track);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(BuildContext context, WidgetRef ref, Track track) async {
    try {
      final file = File(track.dataUrl);
      if (file.existsSync()) {
        file.deleteSync();
        // Remove from database
        final repo = ref.read(trackRepositoryProvider);
        await repo.deleteTrack(track.id);
        
        // Refresh local songs list
        ref.read(localSongsViewModelProvider.notifier).loadLocalSongs();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted ${track.title}')));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File does not exist')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete file: $e')));
      }
    }
  }
}
