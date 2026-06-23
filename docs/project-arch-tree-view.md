# Orbitune Project Architecture Tree

This document visualizes the complete folder and file structure for Orbitune based on Feature-based Modular Clean Architecture.

```text
orbitune/
├── android/                 # Native Android code (Kotlin/Gradle)
├── ios/                     # Native iOS code (Swift/Xcode)
├── windows/                 # Native Windows code (C++)
├── docs/
│   ├── todo.md              # Phase-by-phase execution checklist
│   └── project-arch-tree-view.md # This file
├── lib/
│   ├── core/                # App-wide constants, errors, extensions
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   └── app_strings.dart
│   │   ├── errors/
│   │   │   ├── failure.dart
│   │   │   └── exceptions.dart
│   │   └── utils/
│   │       ├── logger.dart
│   │       └── extensions.dart
│   │
│   ├── data/                # Data Transfer Objects (DTOs) and data sources
│   │   ├── datasources/
│   │   │   ├── local_db_source.dart
│   │   │   └── media_scanner_source.dart
│   │   └── mappers/
│   │       └── song_mapper.dart
│   │
│   ├── domain/              # Entities and abstract interfaces
│   │   ├── entities/
│   │   │   ├── song.dart    # Freezed class
│   │   │   ├── album.dart
│   │   │   ├── artist.dart
│   │   │   └── playlist.dart
│   │   └── usecases/
│   │       ├── play_song_usecase.dart
│   │       └── get_library_usecase.dart
│   │
│   ├── features/            # Feature modules (UI + State)
│   │   ├── home/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   └── providers/
│   │   │       └── home_provider.dart
│   │   ├── library/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── library_screen.dart
│   │   │   │   └── widgets/
│   │   │   └── providers/
│   │   │       └── library_provider.dart
│   │   ├── player/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── player_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── mini_player.dart
│   │   │   │       └── seek_bar.dart
│   │   │   └── providers/
│   │   │       └── playback_provider.dart
│   │   ├── playlists/
│   │   ├── settings/
│   │   └── shell/
│   │       └── scaffold_with_nav_bar.dart
│   │
│   ├── shared/              # Logic and components shared across features
│   │   └── providers/
│   │       └── shared_preferences_provider.dart
│   │
│   ├── services/            # External hardware/OS wrappers
│   │   ├── audio/
│   │   │   └── orbitune_audio_handler.dart
│   │   ├── permissions/
│   │   │   └── permission_service.dart
│   │   └── service_locator.dart # GetIt configuration
│   │
│   ├── widgets/             # Reusable UI components
│   │   ├── glass_container.dart
│   │   ├── animated_play_button.dart
│   │   └── album_art_image.dart
│   │
│   ├── routes/              # GoRouter configuration
│   │   └── app_router.dart
│   │
│   ├── themes/              # Material 3 & Dynamic Color configs
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   │
│   ├── models/              # Isar Database Schema Models
│   │   ├── isar_song.dart
│   │   ├── isar_album.dart
│   │   └── isar_playlist.dart
│   │
│   ├── repositories/        # Repository implementations
│   │   ├── media_repository_impl.dart
│   │   └── settings_repository_impl.dart
│   │
│   └── main.dart            # Application Entry Point
│
├── pubspec.yaml             # Dependencies and metadata
├── build.yaml               # Code generation configuration
└── analysis_options.yaml    # Linting rules
```
