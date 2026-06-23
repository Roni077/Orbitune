import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../library_providers.dart';
import '../../../widgets/glass_container.dart';

class GenresTab extends ConsumerWidget {
  const GenresTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, extract unique genres from the songs provider
    final songsAsync = ref.watch(songsStreamProvider);

    return songsAsync.when(
      data: (songs) {
        final genres = songs.map((s) => s.genre ?? 'Unknown').toSet().toList()..sort();
        
        if (genres.isEmpty) {
          return const Center(child: Text('No genres found.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: genres.length,
          itemBuilder: (context, index) {
            return GlassContainer(
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Text(
                  genres[index],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
