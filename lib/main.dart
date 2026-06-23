import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize GetIt, Isar, Hive, AudioService here in subsequent phases.
  
  runApp(
    const ProviderScope(
      child: OrbituneApp(),
    ),
  );
}

class OrbituneApp extends ConsumerWidget {
  const OrbituneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Orbitune',
      theme: ThemeData.dark(useMaterial3: true),
      // TODO: Replace with GoRouter in Phase 3
      home: const Scaffold(
        body: Center(
          child: Text('Orbitune - Initialized'),
        ),
      ),
    );
  }
}
