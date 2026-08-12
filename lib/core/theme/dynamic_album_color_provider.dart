import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/audio/audio_service_provider.dart';
import 'dart:async';

class DynamicAlbumColorNotifier extends Notifier<ColorScheme?> {
  @override
  ColorScheme? build() => null;
  void setColorScheme(ColorScheme? scheme) => state = scheme;
}

final dynamicAlbumColorSchemeProvider = NotifierProvider<DynamicAlbumColorNotifier, ColorScheme?>(() {
  return DynamicAlbumColorNotifier();
});
// This provider listens to the current media item and extracts the color scheme.
final albumColorExtractorProvider = Provider<void>((ref) {
  final audioHandler = ref.read(audioHandlerProvider);
  
  StreamSubscription? subscription;
  
  subscription = audioHandler.mediaItem.listen((mediaItem) async {
    if (mediaItem?.artUri != null) {
      try {
        final imageProvider = CachedNetworkImageProvider(mediaItem!.artUri!.toString());
        // Extract color scheme using Material 3 built-in extraction
        final colorScheme = await ColorScheme.fromImageProvider(
          provider: imageProvider,
          brightness: Brightness.dark, // Defaulting to dark since app is mostly dark
        );
        ref.read(dynamicAlbumColorSchemeProvider.notifier).setColorScheme(colorScheme);
      } catch (e) {
        // If extraction fails, reset to null
        ref.read(dynamicAlbumColorSchemeProvider.notifier).setColorScheme(null);
      }
    } else {
      ref.read(dynamicAlbumColorSchemeProvider.notifier).setColorScheme(null);
    }
  });

  ref.onDispose(() {
    subscription?.cancel();
  });
});
