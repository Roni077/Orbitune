import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../services/audio/audio_service_provider.dart';

import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/online_item.dart';
import '../viewmodels/search_viewmodel.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../library/views/add_to_playlist_sheet.dart';
import 'online_details_screen.dart';
import '../../library/views/artist_profile_screen.dart';
import '../../library/views/album_profile_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final category = SearchCategory.values[_tabController.index];
        ref.read(searchCategoryProvider.notifier).update(category);
        final query = _controller.text;
        if (query.isNotEmpty) {
           ref.read(searchViewModelProvider.notifier).search(query, category);
        }
      }
    });
    
    _controller.addListener(() {
      ref.read(searchQueryProvider.notifier).update(_controller.text);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(searchViewModelProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final history = ref.watch(searchHistoryProvider);
    final suggestions = ref.watch(searchSuggestionsProvider(searchQuery));
    
    final theme = Theme.of(context);
    final audioHandler = ref.read(audioHandlerProvider);

    final showEmptyState = searchQuery.isEmpty && searchState.results.value?.isEmpty == true;
    final showSuggestions = searchQuery.isNotEmpty && _focusNode.hasFocus && searchState.results.value?.isEmpty == true;
    final showResults = searchState.results.isLoading || (searchState.results.value != null && searchState.results.value!.isNotEmpty);
    final isOnline = true; // Assume always online for now as per user request

    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums...',
              border: InputBorder.none,
              icon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        ref.read(searchViewModelProvider.notifier).clearResults();
                      },
                    )
                  : null,
            ),
            onSubmitted: isOnline ? (query) {
              ref.read(searchViewModelProvider.notifier).search(query, ref.read(searchCategoryProvider));
              _focusNode.unfocus();
            } : null,
            enabled: isOnline,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Songs'),
            Tab(text: 'Albums'),
            Tab(text: 'Artists'),
            Tab(text: 'Playlists'),
          ],
        ),
      ),
      body: Builder(
        builder: (context) {
          if (!isOnline) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Online search is unavailable.', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Please check your internet connection.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            );
          }

          if (showEmptyState) {
            return CustomScrollView(
              slivers: [
                if (history.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => ref.read(searchHistoryProvider.notifier).clearHistory(),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(history[index]),
                          trailing: const Icon(Icons.north_west, size: 16),
                          onTap: () {
                            _controller.text = history[index];
                            _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                            ref.read(searchViewModelProvider.notifier).search(history[index], ref.read(searchCategoryProvider));
                            _focusNode.unfocus();
                          },
                        );
                      },
                      childCount: history.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Text('Trending Songs', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                ref.watch(trendingSongsProvider).when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox());
                    }
                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = items[index];
                          return InkWell(
                            onTap: () async {
                              final track = item as Track;
                              final mediaItem = MediaItem(
                                id: track.id,
                                album: track.album,
                                title: track.title,
                                artist: track.artist,
                                duration: Duration(milliseconds: track.durationMs),
                                extras: {'url': track.dataUrl},
                                artUri: track.artworkUrl != null ? Uri.parse(track.artworkUrl!) : null,
                              );
                              await audioHandler.addQueueItem(mediaItem);
                              await audioHandler.playMediaItem(mediaItem);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                    child: item.artworkUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: item.artworkUrl!,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            color: theme.colorScheme.primaryContainer,
                                            child: const Icon(Icons.music_note),
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text(item.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: items.length,
                      ),
                    );
                  },
                  loading: () => SliverToBoxAdapter(child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))),
                  error: (_, _) => const SliverToBoxAdapter(child: SizedBox()),
                ),
              ],
            );
          }

          if (showSuggestions) {
            return suggestions.when(
              data: (items) {
                if (items.isEmpty) return const SizedBox();
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.search),
                      title: Text(items[index]),
                      onTap: () {
                        _controller.text = items[index];
                        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                        ref.read(searchViewModelProvider.notifier).search(items[index], ref.read(searchCategoryProvider));
                        _focusNode.unfocus();
                      },
                    );
                  },
                );
              },
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            );
          }

          if (showResults || searchState.results.hasError) {
            return searchState.results.when(
              data: (results) {
                if (results.isEmpty) {
                  return const Center(child: Text('No results found.'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: results.length + (searchState.isFetchingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == results.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    final item = results[index];
                    
                    if (item is Track) {
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                            image: item.artworkUrl != null
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(item.artworkUrl!, maxWidth: 150, maxHeight: 150),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: item.artworkUrl == null
                              ? Icon(Icons.music_note, color: theme.colorScheme.onSecondaryContainer)
                              : null,
                        ),
                        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(item.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            showAddToPlaylistSheet(context, [item]);
                          },
                        ),
                        onTap: () async {
                          final tracks = results.whereType<Track>().toList();
                          final trackIndex = tracks.indexOf(item);
                          final mediaItems = tracks.map((t) => MediaItem(
                            id: t.id,
                            album: t.album,
                            title: t.title,
                            artist: t.artist,
                            duration: Duration(milliseconds: t.durationMs),
                            artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
                            extras: {'url': t.dataUrl},
                          )).toList();
                          
                          await audioHandler.loadPlaylist(mediaItems, initialIndex: trackIndex >= 0 ? trackIndex : 0);
                          await audioHandler.play();
                        },
                      );
                    } else if (item is OnlineItem) {
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(item.type == OnlineItemType.artist ? 25 : 10),
                            image: item.artworkUrl != null
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(item.artworkUrl!, maxWidth: 300, maxHeight: 300),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: item.artworkUrl == null
                              ? Icon(item.type == OnlineItemType.artist ? Icons.person : Icons.album, color: theme.colorScheme.onSecondaryContainer)
                              : null,
                        ),
                        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: item.subtitle != null ? Text(item.subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                        onTap: () {
                          if (item.type == OnlineItemType.artist) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ArtistProfileScreen(artistId: item.id)));
                          } else if (item.type == OnlineItemType.album) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumProfileScreen(onlineItem: item, albumTitle: item.title)));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => OnlineDetailsScreen(item: item)));
                          }
                        },
                      );
                    }
                    
                    return const SizedBox();
                  },
                );
              },
              loading: () => ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: LoadingSkeleton(width: double.infinity, height: 60, borderRadius: 10),
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: ${error.toString()}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          ref.read(searchViewModelProvider.notifier).search(_controller.text, ref.read(searchCategoryProvider));
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Search for your favorite songs.'));
        },
      ),
    );
  }
}

