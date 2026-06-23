import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_providers.dart';
import '../../widgets/glass_container.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    final history = ref.watch(searchHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search songs, artists, albums...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              final historyNotifier = ref.read(searchHistoryProvider.notifier);
              if (!historyNotifier.state.contains(value)) {
                historyNotifier.state = [value, ...historyNotifier.state];
              }
            }
          },
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: query.isEmpty
          ? _buildHistory(ref, history)
          : _buildResults(results),
    );
  }

  Widget _buildHistory(WidgetRef ref, List<String> history) {
    if (history.isEmpty) {
      return const Center(child: Text('No recent searches.'));
    }
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(history[index]),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              final newHistory = List<String>.from(history)..removeAt(index);
              ref.read(searchHistoryProvider.notifier).state = newHistory;
            },
          ),
          onTap: () {
            ref.read(searchQueryProvider.notifier).state = history[index];
          },
        );
      },
    );
  }

  Widget _buildResults(List<dynamic> results) {
    if (results.isEmpty) {
      return const Center(child: Text('No results found.'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
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
          onTap: () {
            // TODO: Play song
          },
        );
      },
    );
  }
}
