# Orbitune

A beautifully designed, feature-rich, open-source Android music player built with Flutter. Orbitune focuses equally on offline local music playback and seamless online music discovery and streaming.

## Features

- **Offline First**: Fast and efficient local caching using Riverpod and a Drift SQL database.
- **Online Streaming**: Deep integration with JioSaavn (via custom API implementation) for searching, streaming, and discovering online music.
- **Dynamic Theming**: True Material 3 Dark theme that flawlessly extracts background colors natively from the active Album Artwork for a highly immersive experience.
- **Background Playback**: Powered by `just_audio` and `audio_service` to provide seamless background playback and full Android 14+ lock-screen media controls.
- **Synchronized Lyrics**: Automatically fetches and displays lyrics directly in the Now Playing screen.
- **Audio Equalizer**: Advanced hardware-level Android Equalizer & Bass Boost built right in.
- **Download Manager**: Background downloading support to save online tracks to your device for offline listening.

## Architecture

- **State Management**: `flutter_riverpod`
- **Database**: `drift` (SQLite)
- **Audio Engine**: `just_audio` + `audio_service`
- **Networking**: `http` & `dio` for streams and background downloads.

## Building from Source

To build Orbitune from source, ensure you have the latest stable version of Flutter installed.

```bash
# Get dependencies
flutter pub get

# Generate Drift database files and Riverpod models
flutter pub run build_runner build --delete-conflicting-outputs

# Build the APK for ARM64 (recommended for optimal performance on Android)
flutter build apk --release --target-platform android-arm64
```

## Permissions

The app requires the following permissions on Android to function properly:
- `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MEDIA_PLAYBACK`: For playing audio while the app is in the background.
- `POST_NOTIFICATIONS`: For displaying the media player controls in the notification drawer.
- `READ_EXTERNAL_STORAGE` / `READ_MEDIA_AUDIO`: (If expanding to local file scanning).
- `INTERNET`: For streaming online music and lyrics.
