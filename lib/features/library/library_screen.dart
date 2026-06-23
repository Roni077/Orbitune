import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_music, size: 64, color: Colors.deepPurpleAccent),
            const SizedBox(height: 16),
            Text('Library Screen', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
