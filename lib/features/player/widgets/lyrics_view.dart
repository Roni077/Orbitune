import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../data/services/lyrics_service.dart';
import '../player_providers.dart';

final lyricsServiceProvider = Provider((ref) => LyricsService());

final lyricsFutureProvider = FutureProvider.family<String?, String>((ref, audioFilePath) {
  final service = ref.watch(lyricsServiceProvider);
  return service.getLyrics(audioFilePath);
});

class LyricsView extends ConsumerStatefulWidget {
  final String audioFilePath;
  const LyricsView({super.key, required this.audioFilePath});

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  final ScrollController _scrollController = ScrollController();
  List<LyricsLine> _parsedLines = [];
  bool _isSynced = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lyricsAsync = ref.watch(lyricsFutureProvider(widget.audioFilePath));

    return lyricsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Failed to load lyrics')),
      data: (lyrics) {
        if (lyrics == null || lyrics.trim().isEmpty) {
          return const Center(
            child: Text(
              'No Lyrics found',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
          );
        }

        final service = ref.read(lyricsServiceProvider);
        _parsedLines = service.parseLrc(lyrics);
        _isSynced = _parsedLines.isNotEmpty;

        if (!_isSynced) {
          // Plain text lyrics
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Text(
              lyrics,
              style: theme.textTheme.titleLarge?.copyWith(
                height: 1.8,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        // Synchronized LRC Lyrics
        return StreamBuilder<Duration>(
          stream: AudioService.position,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            return _buildSyncedLyrics(position, theme);
          },
        );
      },
    );
  }

  Widget _buildSyncedLyrics(Duration currentPosition, ThemeData theme) {
    // Find the currently active line
    int activeIndex = -1;
    for (int i = 0; i < _parsedLines.length; i++) {
      if (currentPosition >= _parsedLines[i].time) {
        activeIndex = i;
      } else {
        break;
      }
    }

    // Auto-scroll (basic implementation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (activeIndex != -1 && _scrollController.hasClients) {
        // Approximate item height is 40. We want the active item near the middle.
        final targetOffset = (activeIndex * 50.0) - (MediaQuery.of(context).size.height / 3);
        if (targetOffset > 0) {
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height / 3,
        horizontal: 24,
      ),
      itemCount: _parsedLines.length,
      itemBuilder: (context, index) {
        final line = _parsedLines[index];
        final isActive = index == activeIndex;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: theme.textTheme.headlineSmall!.copyWith(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? theme.colorScheme.primary : Colors.white38,
            ),
            textAlign: TextAlign.center,
            child: Text(line.text),
          ),
        );
      },
    );
  }
}
