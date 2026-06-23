import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orbitune'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, size: 64, color: Colors.deepPurpleAccent),
            const SizedBox(height: 16),
            Text('Home Screen', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
