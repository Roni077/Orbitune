import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../library_providers.dart';
import '../../../widgets/glass_container.dart';
import 'fast_scroll_list.dart';

class SongsTab extends ConsumerWidget {
  const SongsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsStreamProvider);

    return songsAsync.when(
      data: (songs) {
        if (songs.isEmpty) {
          return const Center(child: Text('No songs found in your library.'));
        }
        
        return FastScrollList(
          items: songs,
          titleExtractor: (song) => song.title,
          itemBuilder: (context, index, song) {
            return ListTile(
              leading: GlassContainer(
                width: 50,
                height: 50,
                borderRadius: BorderRadius.circular(8),
                child: song.albumArtPath != null && song.albumArtPath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(song.albumArtPath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.music_note, color: Colors.white54),
              ),
              title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Show context menu
                },
              ),
              onTap: () {
                // TODO: Play song using audioHandler
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
