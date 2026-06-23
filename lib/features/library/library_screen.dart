import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/songs_tab.dart';
import 'widgets/albums_tab.dart';
import 'widgets/artists_tab.dart';
import 'widgets/genres_tab.dart';
import 'widgets/folders_tab.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                context.push('/search');
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Songs'),
              Tab(text: 'Albums'),
              Tab(text: 'Artists'),
              Tab(text: 'Genres'),
              Tab(text: 'Folders'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SongsTab(),
            AlbumsTab(),
            ArtistsTab(),
            GenresTab(),
            FoldersTab(),
          ],
        ),
      ),
    );
  }
}
