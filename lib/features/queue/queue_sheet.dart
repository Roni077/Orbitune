import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../player/player_providers.dart';
import '../../../widgets/glass_container.dart';

class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueProvider);
    final queue = queueAsync.valueOrNull ?? [];
    final currentItemAsync = ref.watch(currentMediaItemProvider);
    final currentItem = currentItemAsync.valueOrNull;
    final audioHandler = ref.read(audioHandlerProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Up Next',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${queue.length} Tracks',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: queue.length,
              // ignore: deprecated_member_use
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                audioHandler.moveQueueItem(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = queue[index];
                final isPlaying = item.id == currentItem?.id;

                return ListTile(
                  key: ValueKey(item.id),
                  tileColor: isPlaying ? theme.colorScheme.primary.withValues(alpha: 0.1) : null,
                  leading: GlassContainer(
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.circular(8),
                    child: item.artUri != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(item.artUri!.toFilePath()),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.music_note, color: Colors.white54),
                  ),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                      color: isPlaying ? theme.colorScheme.primary : Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    item.artist ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: const ReorderableDragStartListener(
                    index: 0, // This is ignored by builder, we use the drag handle naturally
                    child: Icon(Icons.drag_handle, color: Colors.white38),
                  ),
                  onTap: () {
                    audioHandler.skipToQueueItem(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showQueueSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => const QueueSheet(),
    ),
  );
}
