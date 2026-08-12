import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:audio_service/audio_service.dart';

import '../../../../services/downloads/download_manager.dart';
import '../../../../services/audio/audio_service_provider.dart';
import '../viewmodels/downloads_viewmodel.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadsProvider);
    final operations = ref.read(downloadOperationsProvider);
    final audioHandler = ref.read(audioHandlerProvider);
    final activeTasks = ref.watch(downloadManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (activeTasks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('Active Downloads', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () => ref.read(downloadManagerProvider.notifier).clearCompleted(),
                    child: const Text('Clear Completed'),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: activeTasks.length,
                itemBuilder: (context, index) {
                  final task = activeTasks[index];
                  return ListTile(
                    leading: const Icon(Icons.downloading),
                    title: Text(task.mediaItem.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.mediaItem.artist ?? 'Unknown', maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        if (task.status == DownloadStatus.downloading)
                          LinearProgressIndicator(value: task.progress)
                        else if (task.status == DownloadStatus.failed)
                          Text('Failed: ${task.error}', style: const TextStyle(color: Colors.red, fontSize: 12))
                        else if (task.status == DownloadStatus.completed)
                          const Text('Completed', style: TextStyle(color: Colors.green, fontSize: 12))
                        else if (task.status == DownloadStatus.canceled)
                          const Text('Canceled', style: TextStyle(color: Colors.orange, fontSize: 12))
                        else
                          const Text('Queued', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task.status == DownloadStatus.failed || task.status == DownloadStatus.canceled)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => ref.read(downloadManagerProvider.notifier).retry(task.id),
                          ),
                        if (task.status == DownloadStatus.downloading || task.status == DownloadStatus.queued)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => ref.read(downloadManagerProvider.notifier).cancel(task.id),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
          ],
          Expanded(
            flex: 2,
            child: downloadsAsync.when(
              data: (files) {
                if (files.isEmpty) {
                  return const Center(
                    child: Text(
                      'No downloaded tracks yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final basename = p.basenameWithoutExtension(file.path);
                    
                    String title = basename;
                    String artist = 'Unknown Artist';
                    final dashIndex = basename.indexOf(' - ');
                    if (dashIndex != -1) {
                      title = basename.substring(0, dashIndex);
                      artist = basename.substring(dashIndex + 3);
                    }

                    return ListTile(
                      leading: const Icon(Icons.audiotrack, size: 40),
                      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Download'),
                              content: Text('Are you sure you want to delete "$title"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await operations.deleteFile(file);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('File deleted')),
                              );
                            }
                          }
                        },
                      ),
                      onTap: () async {
                        final mediaItem = MediaItem(
                          id: file.path,
                          title: title,
                          artist: artist,
                          extras: {
                            'url': file.path,
                          }
                        );
                        await audioHandler.loadPlaylist([mediaItem]);
                        await audioHandler.play();
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
