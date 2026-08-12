import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../domain/entities/artist_profile.dart';
import '../../../../domain/entities/artist.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/online_item.dart';
import '../../../../services/audio/audio_service_provider.dart';
import '../../../../domain/repositories/favorites_repository.dart';
import '../../../../core/helpers/providers.dart';
import '../../search/views/online_details_screen.dart';
import 'album_profile_screen.dart';
import '../viewmodels/local_songs_viewmodel.dart';
 // for playing local tracks if needed or just play via audioHandler

final artistProfileProvider = FutureProvider.family<ArtistProfile, String>((ref, artistId) async {
  final service = ref.read(onlineAudioServiceProvider);
  final res = await service.getArtistProfile(artistId);
  return res.fold((l) => throw l, (r) => r);
});

class ArtistProfileScreen extends ConsumerStatefulWidget {
  final String artistId;

  const ArtistProfileScreen({super.key, required this.artistId});

  @override
  ConsumerState<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends ConsumerState<ArtistProfileScreen> {
  bool _isFavorite = false;
  bool _isLoadingFavorite = true;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final repo = ref.read(favoritesRepositoryProvider);
    final res = await repo.isArtistFavorite(widget.artistId);
    if (mounted) {
      setState(() {
        _isFavorite = res.getOrElse((_) => false);
        _isLoadingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite(ArtistProfile profile) async {
    final repo = ref.read(favoritesRepositoryProvider);
    setState(() => _isLoadingFavorite = true);
    if (_isFavorite) {
      await repo.removeFavoriteArtist(profile.id);
    } else {
      await repo.addFavoriteArtist(Artist(
        id: profile.id,
        name: profile.name,
        imageUrl: profile.artworkUrl,
      ));
    }
    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
        _isLoadingFavorite = false;
      });
    }
  }

  void _playTracks(WidgetRef ref, List<Track> tracks, [int startIndex = 0]) async {
    final audioHandler = ref.read(audioHandlerProvider);
    final mediaItems = tracks.map((t) => MediaItem(
      id: t.id,
      album: t.album,
      title: t.title,
      artist: t.artist,
      duration: Duration(milliseconds: t.durationMs),
      artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
      extras: {'url': t.dataUrl},
    )).toList();
    
    await audioHandler.loadPlaylist(mediaItems);
    if (startIndex > 0) {
      await audioHandler.skipToQueueItem(startIndex);
    }
    await audioHandler.play();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(artistProfileProvider(widget.artistId));
    final theme = Theme.of(context);
    final localSongs = ref.watch(localSongsViewModelProvider).tracks.value ?? [];

    return Scaffold(
      body: profileState.when(
        data: (profile) {
          final artistLocalSongs = localSongs.where((t) => t.artist.toLowerCase().contains(profile.name.toLowerCase())).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                actions: [
                  if (_isLoadingFavorite)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
                    )
                  else
                    IconButton(
                      icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                      color: _isFavorite ? Colors.red : Colors.white,
                      onPressed: () => _toggleFavorite(profile),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(profile.name, style: const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (profile.artworkUrl != null)
                        CachedNetworkImage(
                          imageUrl: profile.artworkUrl!,
                          fit: BoxFit.cover,
                          color: Colors.black.withValues(alpha: 0.4),
                          colorBlendMode: BlendMode.darken,
                        )
                      else
                        Container(color: theme.colorScheme.secondaryContainer),
                      if (profile.subscribers != null)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Text(
                            profile.subscribers!,
                            style: const TextStyle(color: Colors.white70, fontSize: 12, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                          ),
                        ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Row(
                          children: [
                            if (profile.shuffleId != null)
                              FloatingActionButton.small(
                                heroTag: 'shuffle_${profile.id}',
                                backgroundColor: theme.colorScheme.secondaryContainer,
                                child: Icon(Icons.shuffle, color: theme.colorScheme.onSecondaryContainer),
                                onPressed: () {
                                  // Shuffle logic with radio/shuffle IDs usually needs a specific endpoint,
                                  // but as a fallback, we can just shuffle the topSongs
                                  final tracks = List<Track>.from(profile.topSongs)..shuffle();
                                  _playTracks(ref, tracks);
                                },
                              ),
                            const SizedBox(width: 8),
                            FloatingActionButton.small(
                              heroTag: 'play_${profile.id}',
                              backgroundColor: theme.colorScheme.primary,
                              child: Icon(Icons.play_arrow, color: theme.colorScheme.onPrimary),
                              onPressed: () => _playTracks(ref, profile.topSongs),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  if (artistLocalSongs.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Local Songs', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    ...artistLocalSongs.map((track) => ListTile(
                          leading: track.artworkUrl != null
                              ? CachedNetworkImage(imageUrl: track.artworkUrl!, width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.music_note),
                          title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            _playTracks(ref, artistLocalSongs, artistLocalSongs.indexOf(track));
                          },
                        )),
                    const Divider(),
                  ],
                  if (profile.topSongs.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Top Songs', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    ...profile.topSongs.map((track) => ListTile(
                          leading: track.artworkUrl != null
                              ? CachedNetworkImage(imageUrl: track.artworkUrl!, width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.music_note),
                          title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(track.album, maxLines: 1, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            _playTracks(ref, profile.topSongs, profile.topSongs.indexOf(track));
                          },
                        )),
                  ],
                  if (profile.albums.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Albums', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    _buildHorizontalList(context, profile.albums),
                  ],
                  if (profile.singles.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Singles', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    _buildHorizontalList(context, profile.singles),
                  ],
                  if (profile.relatedArtists.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Related Artists', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    _buildHorizontalArtists(context, profile.relatedArtists),
                  ],
                  const SizedBox(height: 100),
                ]),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<OnlineItem> items) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              if (item.type == OnlineItemType.album) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumProfileScreen(onlineItem: item, albumTitle: item.title)));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OnlineDetailsScreen(item: item)));
              }
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.artworkUrl != null
                        ? CachedNetworkImage(imageUrl: item.artworkUrl!, width: 130, height: 130, fit: BoxFit.cover)
                        : Container(width: 130, height: 130, color: Theme.of(context).colorScheme.secondaryContainer),
                  ),
                  const SizedBox(height: 8),
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (item.subtitle != null)
                    Text(item.subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalArtists(BuildContext context, List<OnlineItem> items) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistProfileScreen(artistId: item.id)));
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: item.artworkUrl != null
                        ? CachedNetworkImage(imageUrl: item.artworkUrl!, width: 100, height: 100, fit: BoxFit.cover)
                        : Container(width: 100, height: 100, color: Theme.of(context).colorScheme.secondaryContainer),
                  ),
                  const SizedBox(height: 8),
                  Text(item.title, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
