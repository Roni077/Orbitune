import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../library_providers.dart';

class ArtistsTab extends ConsumerWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(artistsProvider);

    if (artists.isEmpty) {
      return const Center(child: Text('No artists found.'));
    }

    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(artists[index]),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to Artist detail screen
          },
        );
      },
    );
  }
}
