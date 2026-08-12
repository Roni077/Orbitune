import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/metadata/download_service.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../domain/entities/track.dart';
import '../../../../services/audio/audio_service_provider.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  List<Track> _downloads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    setState(() => _isLoading = true);
    final service = ref.read(downloadServiceProvider);
    final tracks = await service.getDownloadedTracks();
    setState(() {
      _downloads = tracks;
      _isLoading = false;
    });
  }

  Future<void> _deleteTrack(Track track) async {
    final service = ref.read(downloadServiceProvider);
    final success = await service.deleteDownloadedTrack(track.dataUrl);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download deleted')));
        _loadDownloads();
      }
    }
  }

  void _playTrack(Track track, int index) {
    final audioHandler = ref.read(audioHandlerProvider);
    final mediaItems = _downloads.map((t) => MediaItem(
      id: t.id,
      album: t.album,
      title: t.title,
      artist: t.artist,
      duration: Duration(milliseconds: t.durationMs),
      extras: {'url': t.dataUrl},
      artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
    )).toList();
    
    audioHandler.loadPlaylist(mediaItems, initialIndex: index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _downloads.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_done, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No downloads yet.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: _downloads.length,
                  itemBuilder: (context, index) {
                    final track = _downloads[index];
                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.music_note, color: theme.colorScheme.onSecondaryContainer),
                      ),
                      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteTrack(track),
                      ),
                      onTap: () => _playTrack(track, index),
                    );
                  },
                ),
    );
  }
}
