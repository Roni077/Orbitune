import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../services/audio/audio_service_provider.dart';
import '../../../../core/helpers/providers.dart';
import '../viewmodels/lyrics_provider.dart';

class LyricsScreen extends ConsumerWidget {
  final MediaItem mediaItem;

  const LyricsScreen({super.key, required this.mediaItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lyricsAsync = ref.watch(lyricsProvider(mediaItem));
    final audioHandler = ref.watch(audioHandlerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Lyrics', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            Text(
              mediaItem.title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, ref, mediaItem),
          ),
        ],
      ),
      body: lyricsAsync.when(
        data: (data) {
          if (data == null || (data['syncedLyrics'] == null && data['plainLyrics'] == null)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lyrics_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Lyrics not available',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }
          
          if (data['syncedLyrics'] != null && data['syncedLyrics']!.isNotEmpty) {
            final lines = _parseLrc(data['syncedLyrics']!);
            if (lines.isNotEmpty) {
              return SyncedLyricsView(lines: lines, audioHandler: audioHandler);
            }
          }

          final plain = data['plainLyrics'] ?? '';
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Center(
              child: Text(
                plain.replaceAll('<br>', '\n').replaceAll('<br/>', '\n'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error loading lyrics\n$err',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(lyricsProvider(mediaItem)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<LrcLine> _parseLrc(String lrcContent) {
    final lines = lrcContent.split('\n');
    final result = <LrcLine>[];
    final regex = RegExp(r'\[(\d{2,}):(\d{2})\.(\d{2,3})\](.*)');

    for (var line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final min = int.parse(match.group(1)!);
        final sec = int.parse(match.group(2)!);
        final msStr = match.group(3)!;
        final ms = int.parse(msStr.padRight(3, '0').substring(0, 3));
        final text = match.group(4)!.trim();
        
        final timestamp = Duration(minutes: min, seconds: sec, milliseconds: ms);
        result.add(LrcLine(timestamp, text));
      }
    }
    return result;
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref, MediaItem mediaItem) {
    final titleCtrl = TextEditingController(text: mediaItem.title);
    final artistCtrl = TextEditingController(text: mediaItem.artist);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Lyrics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Track Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: artistCtrl,
              decoration: const InputDecoration(labelText: 'Artist Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final lrcLib = ref.read(lrcLibServiceProvider);
              final repo = ref.read(lyricsRepositoryProvider);
              final durationMs = mediaItem.duration?.inMilliseconds ?? 0;
              
              final messenger = ScaffoldMessenger.of(context);
              
              // Show a loading snackbar
              messenger.showSnackBar(
                const SnackBar(content: Text('Searching lyrics...')),
              );
              
              final result = await lrcLib.getLyrics(titleCtrl.text, artistCtrl.text, durationMs);
              final data = result.getOrElse((_) => {});
              
              if (data.isNotEmpty) {
                await repo.saveLyrics(mediaItem.id, data);
                ref.invalidate(lyricsProvider(mediaItem));
                messenger.showSnackBar(
                  const SnackBar(content: Text('Lyrics updated!')),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('No lyrics found for your query')),
                );
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

class LrcLine {
  final Duration timestamp;
  final String text;
  LrcLine(this.timestamp, this.text);
}

class SyncedLyricsView extends StatefulWidget {
  final List<LrcLine> lines;
  final AudioHandler audioHandler;

  const SyncedLyricsView({super.key, required this.lines, required this.audioHandler});

  @override
  State<SyncedLyricsView> createState() => _SyncedLyricsViewState();
}

class _SyncedLyricsViewState extends State<SyncedLyricsView> {
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription _tickerSub;
  int _currentIndex = -1;
  bool _isManualScrolling = false;
  Timer? _manualScrollTimer;

  @override
  void initState() {
    super.initState();
    _tickerSub = Stream.periodic(const Duration(milliseconds: 200)).listen((_) {
      _updatePosition();
    });
  }

  void _updatePosition() {
    if (!mounted) return;
    
    final state = widget.audioHandler.playbackState.value;
    Duration currentPos = state.updatePosition;
    
    if (state.playing) {
      currentPos += DateTime.now().difference(state.updateTime);
    }

    int newIndex = -1;
    for (int i = 0; i < widget.lines.length; i++) {
      if (currentPos >= widget.lines[i].timestamp) {
        newIndex = i;
      } else {
        break;
      }
    }

    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
      if (!_isManualScrolling) {
        _scrollToCurrentLine();
      }
    }
  }

  void _scrollToCurrentLine() {
    if (_currentIndex < 0 || !_scrollController.hasClients) return;
    
    final viewportHeight = _scrollController.position.viewportDimension;
    // Estimate offset: each item is around 60 logical pixels tall
    // We want to center the active item, so subtract half the viewport
    final offset = (_currentIndex * 60.0) - (viewportHeight / 2) + 30.0;
    
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _onUserScroll() {
    setState(() {
      _isManualScrolling = true;
    });
    _manualScrollTimer?.cancel();
    _manualScrollTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isManualScrolling = false;
        });
        _scrollToCurrentLine();
      }
    });
  }

  @override
  void dispose() {
    _tickerSub.cancel();
    _manualScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is UserScrollNotification) {
          _onUserScroll();
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 200.0, horizontal: 24.0),
        itemCount: widget.lines.length,
        itemBuilder: (context, index) {
          final line = widget.lines[index];
          final isActive = index == _currentIndex;
          
          return Container(
            height: 60.0, // Fixed height to make scrolling math simple
            alignment: Alignment.center,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: isActive ? 24 : 20,
              ),
              textAlign: TextAlign.center,
              child: Text(
                line.text.isEmpty ? '...' : line.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}
