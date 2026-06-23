# Orbitune: Offline Music Player Architecture & Implementation Plan

This document outlines the architectural blueprint and execution plan for building the Orbitune offline music player. It incorporates all requirements from your detailed specification.

## Architecture & Tech Stack

- **State Management**: Riverpod (`flutter_riverpod`, `riverpod_annotation`)
- **Routing**: GoRouter
- **Database**: Isar (high performance, great for complex queries like tracks, albums, artists) & Hive (for simple key-value settings)
- **Dependency Injection**: GetIt (for singletons like AudioHandler) paired with Riverpod (for UI state)
- **Audio Engine**: Just Audio + Audio Service + Audio Session
- **Local Files**: `on_audio_query` & `permission_handler`
- **Models**: Freezed + Json Serializable
- **UI/UX**: Material 3, Dynamic Colors, AMOLED Dark Theme, Glassmorphism

## Folder Structure

Following your specification, a feature-based modular Clean Architecture approach:

```text
lib/
 ├── core/          # App-wide constants, errors, type defs
 ├── data/          # DTOs, API wrappers, local storage
 ├── domain/        # Entities, use cases
 ├── features/      # Feature modules (player, library, settings)
 ├── shared/        # Shared logic across features
 ├── services/      # External service wrappers (Audio, Permissions)
 ├── widgets/       # Reusable UI components
 ├── routes/        # GoRouter configuration
 ├── themes/        # Material 3 & Dynamic color configs
 ├── models/        # Global models
 ├── repositories/  # Repository interfaces & implementations
 └── main.dart      # Entry point
```

## Execution Phases

### Phase 1: Foundation & Dependencies
- Update `pubspec.yaml` with all dependencies (Riverpod, GoRouter, Isar, Hive, Just Audio, Audio Service, Freezed, etc.).
- Scaffold the directory structure.
- Initialize `GetIt` locator and Riverpod `ProviderScope`.
- Configure Android, iOS, and Windows native builds for audio permissions and background execution.

### Phase 2: Core Services & Data Layer
- Implement `PermissionService` (handling Android 13+ granular audio permissions).
- Implement `LocalMediaScannerService` using `on_audio_query` to index device storage.
- Initialize Isar Database schema (Songs, Albums, Artists, Playlists).
- Create `AudioRepository` to abstract data access.

### Phase 3: Audio Engine & Background Service
- Implement `AudioHandler` extending `BaseAudioHandler` using `just_audio`.
- Configure `audio_session` for audio focus and interruptions.
- Implement gapless playback, crossfade, and queue management within the `AudioHandler`.
- Expose playback state via Riverpod providers.

### Phase 4: UI Architecture & Theming
- Implement GoRouter configuration with `StatefulShellRoute` for the main navigation (Home, Library, Settings).
- Create AMOLED Dark and Light themes utilizing Material 3 Dynamic Colors.
- Build glassmorphism utility widgets.

### Phase 5: Feature Implementation - Library & Home
- Build the `Library` feature (Folders, Artists, Albums, Songs, Genres).
- Implement smooth scrolling and lazy loading for large lists.
- Build the `Home` feature (Recently Added, Most Played).

### Phase 6: Feature Implementation - Player UI
- Build the persistent `MiniPlayer` widget.
- Build the full-screen `PlayerScreen` with dynamic background blurs based on album art.
- Implement Hero animations between the MiniPlayer and Full Player.
- Add advanced controls (Lyrics, Equalizer access, Queue management, Pitch/Speed).

### Phase 7: Feature Implementation - Playlists & Advanced Features
- Implement Playlist CRUD operations using Isar.
- Build the Equalizer UI and audio effects service.
- Implement Search feature (instant search across tracks/albums/artists).

### Phase 8: Polish & Optimization
- Add `flutter_native_splash` and `flutter_launcher_icons`.
- Perform memory profiling and 120Hz animation optimization.
- Write unit, widget, and integration tests.

## Verification Plan

- **Automated**: Run `flutter analyze`, unit tests for `AudioHandler`, widget tests for `MiniPlayer`.
- **Manual**: Deploy to Android device to test background playback, lock screen controls, Media Style notifications, and Scoped Storage scanning. Test Windows desktop layout responsiveness.
