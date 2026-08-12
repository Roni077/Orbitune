import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/helpers/providers.dart';

enum SearchCategory { songs, albums, artists, playlists }

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}

final searchCategoryProvider = NotifierProvider<SearchCategoryNotifier, SearchCategory>(SearchCategoryNotifier.new);
class SearchCategoryNotifier extends Notifier<SearchCategory> {
  @override
  SearchCategory build() => SearchCategory.songs;
  void update(SearchCategory value) => state = value;
}

final searchHistoryProvider = NotifierProvider<SearchHistoryNotifier, List<String>>(() {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends Notifier<List<String>> {
  static const _historyKey = 'search_history';
  
  @override
  List<String> build() {
    _loadHistory();
    return [];
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> addQuery(String query) async {
    if (query.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final pauseSearchHistory = prefs.getBool('pause_search_history') ?? false;
    if (pauseSearchHistory) return;

    final history = prefs.getStringList(_historyKey) ?? [];
    
    history.remove(query);
    history.insert(0, query);
    
    if (history.length > 20) {
      history.removeLast();
    }
    
    await prefs.setStringList(_historyKey, history);
    state = history;
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    state = [];
  }
}

final searchSuggestionsProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final onlineAudioService = ref.read(onlineAudioServiceProvider);
  final result = await onlineAudioService.getSearchSuggestions(query);
  return result.getOrElse((_) => []);
});

final trendingSongsProvider = FutureProvider<List<dynamic>>((ref) async {
  final onlineAudioService = ref.read(onlineAudioServiceProvider);
  final result = await onlineAudioService.getTrendingSongs();
  return result.getOrElse((_) => []);
});

class SearchState {
  final AsyncValue<List<dynamic>> results; // Track or OnlineItem
  final bool isFetchingMore;
  final int currentPage;

  SearchState({
    required this.results,
    this.isFetchingMore = false,
    this.currentPage = 1,
  });

  SearchState copyWith({
    AsyncValue<List<dynamic>>? results,
    bool? isFetchingMore,
    int? currentPage,
  }) {
    return SearchState(
      results: results ?? this.results,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

final searchViewModelProvider = NotifierProvider<SearchViewModel, SearchState>(() {
  return SearchViewModel();
});

class SearchViewModel extends Notifier<SearchState> {
  String _lastQuery = '';
  SearchCategory _lastCategory = SearchCategory.songs;

  @override
  SearchState build() {
    return SearchState(results: const AsyncValue.data([]));
  }

  Future<void> search(String query, SearchCategory category) async {
    if (query.trim().isEmpty) {
      state = SearchState(results: const AsyncValue.data([]));
      return;
    }

    _lastQuery = query;
    _lastCategory = category;
    ref.read(searchHistoryProvider.notifier).addQuery(query.trim());
    state = SearchState(results: const AsyncValue.loading());

    await _fetchPage(1);
  }

  Future<void> loadMore() async {
    if (state.results.isLoading || state.isFetchingMore || _lastQuery.isEmpty) return;
    
    state = state.copyWith(isFetchingMore: true);
    await _fetchPage(state.currentPage + 1);
  }

  Future<void> _fetchPage(int page) async {
    final onlineAudioService = ref.read(onlineAudioServiceProvider);
    
    dynamic result;
    switch (_lastCategory) {
      case SearchCategory.songs:
        result = await onlineAudioService.searchSongs(_lastQuery, page: page);
        break;
      case SearchCategory.albums:
        result = await onlineAudioService.searchAlbums(_lastQuery, page: page);
        break;
      case SearchCategory.artists:
        result = await onlineAudioService.searchArtists(_lastQuery, page: page);
        break;
      case SearchCategory.playlists:
        result = await onlineAudioService.searchPlaylists(_lastQuery, page: page);
        break;
    }

    result.match(
      (failure) {
        if (page == 1) {
          state = SearchState(results: AsyncValue.error(failure.message, StackTrace.current));
        } else {
          state = state.copyWith(isFetchingMore: false);
        }
      },
      (items) {
        final currentItems = page == 1 ? [] : (state.results.value ?? []);
        state = SearchState(
          results: AsyncValue.data([...currentItems, ...items]),
          currentPage: page,
          isFetchingMore: false,
        );
      },
    );
  }
  
  void clearResults() {
    _lastQuery = '';
    state = SearchState(results: const AsyncValue.data([]));
  }
}
