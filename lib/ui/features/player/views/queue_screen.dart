import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../services/audio/audio_service_provider.dart';
import '../../../../domain/entities/track.dart';
import '../../library/views/add_to_playlist_sheet.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Up Next'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Save as Playlist',
            onPressed: () {
              final queue = audioHandler.queue.value;
              if (queue.isNotEmpty) {
                final tracks = queue.map((item) {
                  final url = item.extras?['url']?.toString() ?? '';
                  final isOnline = url.startsWith('http');
                  return Track(
                    id: item.id,
                    title: item.title,
                    artist: item.artist ?? 'Unknown',
                    album: item.album ?? 'Unknown',
                    durationMs: item.duration?.inMilliseconds ?? 0,
                    source: isOnline ? TrackSource.online : TrackSource.local,
                    dataUrl: url,
                    artworkUrl: item.artUri?.toString(),
                  );
                }).toList();
                showAddToPlaylistSheet(context, tracks);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<MediaItem>>(
        stream: audioHandler.queue,
        builder: (context, snapshot) {
          final queue = snapshot.data ?? [];
          if (queue.isEmpty) {
            return const Center(child: Text('Queue is empty'));
          }

          return StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (context, mediaSnapshot) {
              final currentMedia = mediaSnapshot.data;

              return ReorderableListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: queue.length,
                // ignore: deprecated_member_use
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  audioHandler.customAction('moveQueueItem', {
                    'currentIndex': oldIndex,
                    'newIndex': newIndex,
                  });
                },
                itemBuilder: (context, index) {
                  final item = queue[index];
                  final isPlaying = currentMedia?.id == item.id;

                  return Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      audioHandler.removeQueueItem(item);
                    },
                    child: ListTile(
                      key: ValueKey('list_item_${item.id}'),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          image: item.artUri != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(item.artUri!.toString()),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: item.artUri == null
                            ? Icon(Icons.music_note, color: theme.colorScheme.onSecondaryContainer)
                            : (isPlaying
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.equalizer, color: Colors.white),
                                  )
                                : null),
                      ),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        item.artist ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                      onTap: () {
                        audioHandler.skipToQueueItem(index);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
