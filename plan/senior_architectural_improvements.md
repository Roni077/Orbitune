# Senior Architectural Improvements Plan

## Goal Description
As a senior Flutter engineer, reviewing the initial project plans reveals some missing technical rigor. A music player combining local storage and online streaming with background capabilities is highly complex. If we don't address specific technical hurdles now, the app will suffer from jank, memory leaks, or unmaintainable code. This document outlines critical improvements to our planning before we write a single line of code.

## Key Architectural Decisions

### 1. Introduce Strict Dependency Injection Rules
Currently, Riverpod is mentioned, but we need rules.
- **Rule:** UI widgets *only* listen to Presentation State Notifiers (e.g., `PlayerNotifier`).
- **Rule:** Presentation Notifiers *only* call Domain UseCases (e.g., `PlaySongUseCase`).
- **Rule:** Domain UseCases *only* call Repository Interfaces.
- **Rule:** Data Repositories are the *only* layer allowed to talk to APIs or Isar.

### 2. Model Immutability & Sealed Classes
- Add `freezed` and `freezed_annotation`.
- All Data Transfer Objects (DTOs) and Domain Entities will be immutable.
- UI States will use sealed classes (Dart 3 feature):
```dart
sealed class UIState {}
class UILoading extends UIState {}
class UIData extends UIState { final List<Track> tracks; }
class UIError extends UIState { final Failure error; }
```
This forces the UI to use `switch (state)` and guarantees we handle loading and error states exhaustively.

### 3. Error Handling (Result Type)
- Implement a `Result<Success, Failure>` type (using Dart 3 sealed classes or a package like `fpdart` or `dartz`). 
- The domain and data layers must *never* throw raw Exceptions to the UI. All exceptions are caught in the Data layer and mapped to a domain-specific `Failure`.

### 4. Threading and Isolates (Critical for Performance)
- **Local Scanner:** Parsing ID3 tags for thousands of MP3s on the main thread will cause the UI to freeze (jank). We will execute the `media_scanner_service` logic inside a Dart Isolate (`Isolate.run()`).
- **Image Parsing:** Extracting high-res embedded album art from local FLAC/MP3 files will also be pushed to an Isolate to maintain 60fps scrolling.

### 5. The Audio Synchronization Problem
Mixing local URIs and online URLs in `just_audio` requires a unified audio source.
- We will plan a `CustomAudioSource` factory that evaluates the `TrackSource` enum. 
- If `local`, it feeds `AudioSource.uri(Uri.file(...))`.
- If `online`, it feeds `AudioSource.uri(Uri.parse(https://...))`.
- If `cached`, it feeds the local cache path. 
This hides the file/network complexity from `audio_service`.

### 6. Database Concurrency
- `Isar` is fast but requires careful transaction management. Large batch inserts (like the initial scan of the device) must be chunked (e.g., 500 tracks per transaction) so the database lock doesn't block UI read queries, which could freeze the app.

## Answers to Open Questions
*These need to be aligned with the product vision:*
1. **Background Lifecycle**: When the user swipes the app away from the recent apps list (`onTaskRemoved`), Orbitune will stop playback and destroy the service. This is standard modern Android behavior unless configured as a sticky persistent foreground service.
2. **Initial Scan Strategy**: Scanning local songs will happen in the background. We will not block the user. A small non-intrusive loading indicator will appear in the library tab, allowing them to access the online portion of the app immediately.

## Verification
- Architectural boundaries will be enforced strictly via code reviews or architectural linting (`custom_lint`).
- Isolates will be verified by testing on lower-end Android devices to ensure 60fps scrolling is maintained during a full library scan.
