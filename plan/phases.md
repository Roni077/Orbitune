# Implementation Phases

This document outlines the step-by-step implementation strategy for the Orbitune Android music player, strictly following the 15 phases and explicitly mapping every required feature to its respective phase, including senior-level architectural constraints (MVVM, Isolates, Freezed, strict DI) and Premium UX guidelines.

## Phase 1: Project setup + architecture + theme
**Objectives & Features:**
- [ ] **Setup:** Initialize Flutter project for Android. Configure `pubspec.yaml` with all dependencies (`riverpod`, `freezed`, `isar`, `go_router`, `audio_service`, `just_audio`, `flutter_animate`, `google_fonts`, etc.).
- [ ] **Architecture:** Create Clean Architecture folders: `core`, `data`, `domain`, `services`, `ui`. Apply strict MVVM inside `ui/features` (split into `views` and `view_models`) per Flutter architecture skills.
- [ ] **Dependency Injection:** Enforce strict Riverpod rules: Views listen to ViewModels (Notifiers), ViewModels call UseCases, UseCases call Repositories.
- [ ] **UI/UX Design:** Establish Material 3, Dark-first, minimal, elegant design system. Spacing system (4, 8, 12, 16, 20, 24, 32). Integrate `google_fonts` (e.g., Outfit or Inter).
- [ ] **Theming:** Setup System, Light, Dark, and AMOLED themes. Configure `dynamic_color` for Android 12+ integration, and `palette_generator` for artwork-based theme support.
- [ ] **Components:** Create reusable widgets with `flutter_animate` for micro-interactions: `OrbituneButton`, `SongTile`, `AlbumCard`, `ArtworkView`, `SectionHeader`, `LoadingSkeleton` (using `shimmer`), `EmptyState`, `ErrorState`, `BottomSheetMenu`.
- [ ] **Navigation:** Setup declarative routing using `go_router`. Implement nested bottom navigation specifically using `StatefulShellRoute.indexedStack` and a `StatefulNavigationShell` per Flutter routing skills. Deep navigation support.
- [ ] **Accessibility & Responsive:** Ensure large touch targets, semantic labels, and scalable layouts. Tasteful animations honoring reduced-motion.

## Phase 2: Database + models + repositories
**Objectives & Features:**
- [ ] **Models (Immutability):** Create `Track` model and DTOs using `freezed` for immutability. Define `TrackSource` enum (`local`, `online`, `cached`).
- [ ] **Database:** Initialize local database (Isar) to persist: Songs, Artists, Albums, Playlists, PlaylistSongs, Favorites, RecentlyPlayed, SearchHistory, Settings, Queue, Downloads.
- [ ] **Concurrency:** Implement chunked inserts for Isar to prevent database locking during large reads/writes.
- [ ] **Repositories & Result Types:** Define abstractions. Use `Result<Success, Failure>` (fpdart or sealed classes) so the domain layer never throws raw exceptions to the UI.
- [ ] **State Management:** Initialize Riverpod state management. UI ViewModels will emit sealed classes (e.g., `UILoading`, `UIData`, `UIError`). No global mutable state.

## Phase 3: Android permissions + local music scanner
**Objectives & Features:**
- [ ] **Android Configuration:** Configure `AndroidManifest.xml` (API 12-15+ compatibility).
- [ ] **Required Screens:** Splash Screen, Onboarding / First Run, Permission Screen.
- [ ] **First Launch Flow:** Orbitune logo -> Welcome -> Explain local music access -> Request required Android media permission -> Scan local library -> Home.
- [ ] **Offline Scanner (Isolates):** Request permission, find supported media. Execute ID3 metadata extraction and heavy parsing inside a Dart `Isolate.run()` to prevent main UI thread jank. Insert/update database, detect deleted files.
- [ ] **Local Music Management:** Support deleting/removing files from library where permissions allow. Security (sanitize filenames).

## Phase 4: Audio engine + background playback
**Objectives & Features:**
- [ ] **Audio Architecture:** Setup centralized `AudioService` (singleton). No separate players per screen.
- [ ] **Audio Source Synchronization:** Create a `CustomAudioSource` factory that converts a `Track` to a `just_audio` URI based on its `TrackSource` enum (local file vs network url).
- [ ] **Sub-components:** Implement `AudioHandler`, `QueueManager`, `PlaybackState`, `MediaSession`, `EqualizerController`.
- [ ] **Player State:** `currentTrack`, `isPlaying`, `position`, `duration`, `bufferedPosition`, `queue`, `shuffleEnabled`, `repeatMode`.
- [ ] **Playback Controls:** Play, pause, resume, next, previous, seek, shuffle, repeat.
- [ ] **Background Features:** Background playback, media notification, lock-screen controls, bluetooth controls, headset controls. Destroy service on `onTaskRemoved`.
- [ ] **Interruptions:** Audio focus handling, interruption handling, becoming noisy handling. Resume playback. Persistent playback state.

## Phase 5: Home + Library + player UI
**Objectives & Features:**
- [ ] **Home Screens:** Home (Good evening, Recently played cards, Quick picks, Trending list, New releases cards, Popular artists, Your playlists). Use `shimmer` skeleton loaders for online fetches.
- [ ] **Library Screens:** Library (Tabs: Songs, Albums, Artists, Folders, Genres, Favorites, Recently Played, Downloads). Sorting (Title, Artist, Album, Date added, Duration, Play count) asc/desc. Staggered list animations via `flutter_animate`.
- [ ] **Entity Screens:** Artist Details, Album Details (artwork, name, artist, year, genre, track count/listing, play all, shuffle, queue, playlist, favorite). Dynamic UI tinting via `palette_generator`.
- [ ] **Player Screens:** Now Playing (premium full-screen, large artwork with subtle scale animation, title wrapped in `marquee`, dynamic background gradients, progress, times, play/pause, prev, next, shuffle, repeat, queue btn, lyrics btn, eq btn).
- [ ] **Mini Player:** Persistent above bottom navigation, updates instantly, thumbnail, title, artist, play/pause, next. Tap to open full player.
- [ ] **Context Menus:** Three-dot menu for all songs (Play, Play next, Add to queue/playlist, Favorite, Go to artist/album, View lyrics, Download).

## Phase 6: Playlists + Favorites + History
**Objectives & Features:**
- [ ] **Required Screens:** Playlists, Playlist Details, Queue, Favorites, Recently Played.
- [ ] **Queue Management:** View current queue, reorder, remove, clear, play specific, add songs/albums/playlists, shuffle. Persist queue.
- [ ] **Playlists:** Create unlimited local playlists, rename, delete, add/remove/reorder songs, play, shuffle, auto-generate artwork/count.
- [ ] **Favorites:** Favorite/unfavorite songs, view all, play all, shuffle. Must work for both local and online content.
- [ ] **Recently Played:** Track song, artist, timestamp, play count. Configurable limit so DB doesn't grow infinitely.
- [ ] **Empty States:** Custom states ("Create your first playlist", "Your favorites will appear here", "No music found").

## Phase 7: Online providers
**Objectives & Features:**
- [ ] **Required Screens:** Online Music.
- [ ] **Online Sources:** Integrate `jiosaavn`, `saavn_play`, `ytmusicapi_dart` packages.
- [ ] **Abstraction:** Build `OnlineMusicRepository` with `JioSaavnProvider`, `SaavnPlayProvider`, and `YouTubeMusicProvider`. Do not hard-code responses.
- [ ] **Failure Handling:** If JioSaavn fails, try next configured provider. If all fail: "Unable to load online music." Do not crash.
- [ ] **Online Song Page:** Artwork, title, artist, album, duration, play, queue, playlist, favorite, download (where legal), lyrics, related songs.
- [ ] **Networking:** Centralized network layer with timeout, retry, error mapping to `Failure` sealed class, connectivity detection, request cancellation.

## Phase 8: Online search + discovery
**Objectives & Features:**
- **Required Screens:** Search, Search Results.
- [ ] **Global Search Interface:** Search for Songs, Artists, Albums, Playlists across local and online providers.
- [ ] **Search UI:** Search field, debounced input, loading state, empty state, error state, search history (and clear history). Grouped by category with tabs (All, Songs, Artists, Albums, Playlists).

## Phase 9: Lyrics
**Objectives & Features:**
- [ ] **Required Screens:** Lyrics.
- [ ] **Lyrics Interface:** Static lyrics, synced lyrics, timestamped lyrics, auto-scrolling, current-line highlighting.
- [ ] **Abstraction:** `LyricsRepository` and `LyricsProvider`.
- [ ] **Fallback:** Display "Lyrics unavailable for this song" when missing. Never crash on missing lyrics. Do not scrape unauthorized sources.

## Phase 10: Equalizer
**Objectives & Features:**
- [ ] **Required Screens:** Equalizer.
- [ ] **Android Equalizer:** Native interface integration.
- [ ] **Features:** Enable/disable, Custom EQ, Bass boost, Virtualizer.
- [ ] **Presets:** Flat, Classical, Dance, Electronic, Hip-Hop, Jazz, Pop, Rock, Vocal, Custom.
- [ ] **Graceful Failure:** If device unsupported, fail gracefully and show friendly message, do not crash.

## Phase 11: Caching/download manager
**Objectives & Features:**
- [ ] **Required Screens:** Downloads.
- [ ] **Offline Architecture:** Local device music (already local), Online cache (temporary), Downloads (permanent, only where legally permitted).
- [ ] **Download Manager:** Abstraction to handle downloads. Show progress, downloaded, waiting, failed, cancelled. No DRM circumvention.
- [ ] **Offline-First Behavior:** Local library, playlists, favorites, history, cached metadata remain available. App shows "You're offline" empty states where applicable, but remains fully functional for local data.
- [ ] **Artwork View:** Persistent caching via `cached_network_image` (with strict `memCacheWidth` constraint), local image, memory cache, disk cache, `flutter_blurhash` fallback, loading, error. Image extraction runs in Isolates.

## Phase 12: Settings + customization
**Objectives & Features:**
- [ ] **Required Screens:** Settings, Playback Settings, Appearance Settings, Library Settings, Online Settings, About.
- [ ] **Playback Settings:** Gapless playback, crossfade, replay gain, normalize volume, resume on startup, autoplay.
- [ ] **Appearance Settings:** Light/Dark/System/AMOLED, dynamic colors, accent color, artwork-based theme.
- [ ] **Library Settings:** Scan music, choose folders, rescan, excluded folders.
- [ ] **Audio Settings:** Equalizer, bass boost, audio effects.
- [ ] **Online Settings:** Preferred provider, streaming quality, Wi-Fi-only streaming, cache settings.
- [ ] **Downloads Settings:** Location, Wi-Fi only, automatic cleanup.
- [ ] **Privacy Settings:** Clear search history, listening history, cache.
- [ ] **About:** Version, open-source licenses, credits, Privacy info.
- [ ] **Data Synchronization:** Persist all changes reliably. App should restore state after restart.

## Phase 13: Performance optimization
**Objectives & Features:**
- [ ] **UI Performance:** Lazy lists (ListView/SliverList), cached artwork, strict image bounds to prevent RAM bloat.
- [ ] **Logic Performance:** Efficient DB queries, online pagination, debounced search, minimal rebuilds via `freezed` equality.
- [ ] **Memory Management:** Dispose controllers, avoid memory leaks, avoid keeping huge playlists in memory.
- [ ] **Animation:** Ensure smooth scrolling and tasteful transitions (respecting reduced-motion).

## Phase 14: Testing + bug fixing
**Objectives & Features:**
- [ ] **Unit Tests:** Repositories, use cases, DB operations, queue logic, search logic, favorites, playlists, playback state.
- [ ] **Widget Tests:** Home, Library, Search, Player, Playlist, Settings. Strictly utilize `WidgetTester`, `pumpAndSettle()`, and `Finder` patterns as defined by the widget testing skill.
- [ ] **Integration Tests:** Critical flows (Launch -> Permissions -> Scan -> Play local -> Open player -> Create playlist -> Search online -> Play online -> Background).
- [ ] **Error Handling Validation:** Ensure no crashes for missing metadata, invalid artwork, deleted files, network failures, empty search, unsupported formats. Meaningful error states ("Something went wrong"). No raw exceptions exposed.

## Phase 15: Release build verification
**Objectives & Features:**
- [ ] **Project Configuration:** Complete `pubspec.yaml`, `analysis_options.yaml`, `AndroidManifest.xml`, Gradle, ProGuard/R8.
- [ ] **Documentation:** `README.md` containing requirements, setup, dependencies, permissions, architecture, how providers work, build instructions, known limitations, legal/licensing.
- [ ] **Build Command:** Code must build using `flutter pub get`, `flutter analyze` (no introduced errors), `flutter test`, `flutter build apk --release`.

### Final Quality Bar Checklist
- [ ] App launches
- [ ] Android permissions work
- [ ] Local music scanning works (via Isolates)
- [ ] Local songs display correctly
- [ ] Local playback works
- [ ] Background playback works
- [ ] Notification controls work
- [ ] Lock-screen controls work
- [ ] Queue works
- [ ] Shuffle works
- [ ] Repeat works
- [ ] Mini-player works
- [ ] Full player works
- [ ] Playlists work
- [ ] Favorites work
- [ ] Recently played works
- [ ] Search works
- [ ] Online music works through supported providers
- [ ] Online playback works where provider permits
- [ ] Provider errors are handled safely via Result type
- [ ] Lyrics work where available
- [ ] Missing lyrics do not crash
- [ ] Equalizer works where Android supports it
- [ ] Unsupported equalizer devices fail gracefully
- [ ] Cache works
- [ ] Downloads only work where permitted
- [ ] Offline mode works
- [ ] Settings persist
- [ ] Theme switching works
- [ ] App survives restart
- [ ] Database survives restart
- [ ] No obvious memory leaks
- [ ] No major UI jank
- [ ] `flutter analyze` passes
- [ ] Tests pass
- [ ] Release APK builds
