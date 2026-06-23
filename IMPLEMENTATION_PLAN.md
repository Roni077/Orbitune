# Orbitune: Offline Music Player Architecture & Implementation Plan

This document outlines the architectural blueprint and execution plan for building the Orbitune offline music player. It strictly follows the project-scoped guidelines in `.agents/AGENTS.md` (MVVM architecture, declarative routing, etc.).

## Open Questions for Approval

1. **State Management:** The architecture skill recommends MVVM with `ChangeNotifier` and `provider` or `get_it`. Is `provider` + `get_it` acceptable, or do you prefer `flutter_riverpod` or `flutter_bloc`?
2. **Desktop Audio Engine:** `just_audio` is excellent for mobile but has limited official Windows support without community extensions. An alternative is `media_kit`, which is robust across all platforms. Are you okay with using `media_kit` to ensure high-quality Windows playback, or stick to `just_audio`?
3. **Design Aesthetic:** I plan to build a sleek, **premium dark-mode UI with glassmorphism effects** and dynamic gradients based on album art. Does this align with your vision?

## Proposed Architecture (Strict MVVM)

Following the `flutter-apply-architecture-best-practices` skill, the app will be structured into distinct layers:

1. **Data Layer (`lib/data/`)**: 
   - *Services*: Native media querying, audio player wrappers, and local storage (Hive/SharedPreferences).
   - *Repositories*: Single source of truth for audio files, playlists, and settings.
2. **Logic Layer (`lib/domain/`)**: 
   - *Models*: Immutable data classes for `Song`, `Playlist`, etc.
3. **UI Layer (`lib/ui/`)**: 
   - *Core*: Themes, shared widgets, glassmorphic containers.
   - *Features*: Specific MVVM structures for `Home`, `Player`, `Library`, etc.
   - *Routing*: `go_router` for declarative navigation and nested shell routes (BottomNavigationBar).

## Proposed Dependencies

- **Routing:** `go_router`
- **State & DI:** `provider`, `get_it`
- **Audio Playback:** `just_audio` (or `media_kit`) & `audio_service` (for lock-screen/background playback)
- **Local Files:** `on_audio_query` (to scan devices for `.mp3`/`.wav`), `permission_handler`
- **Local DB:** `hive` or `shared_preferences` (for playlists and favorites)
- **UI:** `google_fonts`, `palette_generator` (for dynamic UI colors based on album art)

## Execution Phases

### Phase 1: Core Setup & Dependencies
- Add all required packages to `pubspec.yaml`.
- Set up the folder structure (`lib/ui`, `lib/data`, `lib/domain`).
- Configure `get_it` for dependency injection.

### Phase 2: Navigation & Theming
- Implement `go_router` with a `StatefulShellRoute` to create a persistent bottom navigation bar (Home, Search, Library).
- Create the Orbitune Dark Theme with premium typography (`google_fonts`) and color tokens.

### Phase 3: Data Layer & Permissions
- Implement the `PermissionService` to request local storage/audio permissions on Android and iOS.
- Implement the `AudioQueryService` (wrapping `on_audio_query`) to fetch songs, albums, and artists.
- Create the `AudioRepository`.

### Phase 4: Audio Engine Integration
- Set up the background audio task using `audio_service`.
- Create the `AudioPlayerViewModel` to manage play, pause, seek, and current track state.

### Phase 5: High-Fidelity UI Construction
- Build the `HomeScreen` (Recent, Playlists).
- Build the full-screen `PlayerView` with dynamic background gradients, seek bars, and glassmorphism.
- Integrate micro-animations for play/pause transitions and list scrolling.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure strict linting.
- Add widget tests for the core UI components (`PlayerControls`, `SongListTile`).

### Manual Verification
- Deploy to an Android device/emulator to verify local storage permissions and file fetching.
- Verify background audio playback and lock-screen controls.
- Verify the UI aesthetics and responsive layout on mobile vs. desktop/Windows window sizes.
