# Package Dependencies

The following external packages are required to fulfill Orbitune's technical and architectural requirements. They are chosen for their stability, community support, and alignment with modern Flutter development standards.

## State Management & Architecture
- **`flutter_riverpod`** (`^2.5.0` or higher)
  - **Purpose:** Centralized, compile-safe state management. Used for dependency injection and reacting to changes in `PlaybackState`, Database changes, and UI state.
- **`riverpod_annotation`** & **`riverpod_generator`** (dev)
  - **Purpose:** Code generation for Riverpod to reduce boilerplate and ensure robust provider definitions.

## Immutability & Code Generation
- **`freezed`** & **`freezed_annotation`** (dev/regular)
  - **Purpose:** Generating immutable models (Entities, DTOs) and union/sealed classes for robust UI state management (e.g., `UILoading`, `UIData`, `UIError`). Eliminates handwritten `copyWith` and equality operators.
- **`build_runner`** (dev)
  - **Purpose:** Dart code generation orchestrator (used for Isar, Riverpod, Freezed, and JSON serialization).
- **`json_annotation`** & **`json_serializable`** (dev)
  - **Purpose:** Parsing complex JSON responses from APIs safely.

## Error Handling & Functional Programming
- **`fpdart`** (or Dart 3 Sealed Classes)
  - **Purpose:** Handling errors robustly using the `Either<Failure, Success>` or `Result` pattern. Ensures the Domain layer never throws raw exceptions to the Presentation layer.

## Audio & Media Playback
- **`audio_service`**
  - **Purpose:** Handles background audio lifecycle, lock-screen controls, media notifications, and headset events for Android.
- **`just_audio`**
  - **Purpose:** The core audio engine. Highly reliable for streaming network audio, handling DASH/HLS, gapless playback, and local file playback. Works seamlessly with `audio_service`.

## Local Storage & Database
- **`isar`** & **`isar_flutter_libs`**
  - **Purpose:** Extremely fast NoSQL local database. Ideal for storing complex objects like `Track`, `Playlist`, and `History`. Selected for its speed, full-text search capabilities, and native Flutter object support. Inserts will be chunked to avoid UI thread blocking.
- **`shared_preferences`**
  - **Purpose:** Storing lightweight key-value pairs for user settings (e.g., Theme preference, last opened tab).

## Networking & Online Providers
- **`jiosaavn`** & **`saavn_play`**
  - **Purpose:** Wrappers for the JioSaavn API to fetch Indian/Global trending music, album metadata, and stream links.
- **`ytmusicapi_dart`**
  - **Purpose:** Port of the python `ytmusicapi`. Allows scraping and interacting with YouTube Music for comprehensive global music discovery and streaming.
- **`dio`** or **`http`**
  - **Purpose:** General purpose networking for downloading files or custom API endpoints outside of the provided SDKs.

## Local Files & Permissions
- **`on_audio_query`**
  - **Purpose:** Querying Android's `MediaStore` to retrieve local audio files, albums, artists, and embedded ID3 artwork. Parsing will be delegated to Dart Isolates to maintain 60fps.
- **`permission_handler`**
  - **Purpose:** Requesting runtime permissions from the user (specifically `READ_MEDIA_AUDIO` for Android 13+ and `READ_EXTERNAL_STORAGE` for older versions).
- **`path_provider`**
  - **Purpose:** Accessing device directories (e.g., Application Documents) for storing cached files or the Isar database.

## UI, Theming & Premium UX
- **`go_router`**
  - **Purpose:** Declarative nested routing (`StatefulShellRoute`).
- **`google_fonts`**
  - **Purpose:** Premium typography (e.g., Inter, Outfit, Plus Jakarta Sans) replacing default Roboto.
- **`palette_generator`**
  - **Purpose:** Extracting dominant and accent colors from album artwork to dynamically theme the `NowPlaying` and `Album` screens.
- **`flutter_animate`**
  - **Purpose:** Extremely performant declarative micro-animations (e.g., staggering list items, scale-on-tap for buttons).
- **`shimmer`**
  - **Purpose:** Sleek skeleton loading states for online content, avoiding basic circular spinners.
- **`flutter_blurhash`**
  - **Purpose:** Decoding ultra-compact hashes into beautiful, blurred placeholder images while high-res artwork loads over the network.
- **`marquee`**
  - **Purpose:** Gracefully auto-scrolling song/artist titles that overflow the screen instead of awkwardly clipping them.
- **`dynamic_color`**
  - **Purpose:** Extracting Material You / Monet colors from Android 12+ to match the app theme with the user's OS wallpaper.
- **`cached_network_image`**
  - **Purpose:** Efficiently downloading, caching, and displaying online album artwork. Configured with strict `memCacheWidth` to ensure low RAM usage.

## Utilities & Logging
- **`logger`**
  - **Purpose:** Pretty, configurable console logging to track errors and debug data flows without cluttering production logs.

## Offline Capabilities
- **`flutter_cache_manager`**
  - **Purpose:** Granular control over the caching of online streams and files to support Orbitune's offline-first mandate.
