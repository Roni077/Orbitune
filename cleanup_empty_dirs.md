## Goal Description
You noticed that there are several empty directories scattered throughout the `lib/` folder. This happened because during **Phase 1 (Scaffold)**, I generated a comprehensive, scalable MVVM Clean Architecture directory structure. 

However, since we focused on an MVP (Minimum Viable Product) and utilized Riverpod effectively to bridge the Domain and UI layers, we ended up not needing some of those folders (e.g. `domain/usecases`, `features/settings`, or old un-migrated paths like `ui/home`).

This plan proposes cleaning up the unused directory scaffolding so your codebase stays clean, compact, and free of ghost folders!

## User Review Required
> [!IMPORTANT]
> Please review the list of directories below that I am proposing to delete. Since they contain absolutely no files, deleting them will not impact the build or functionality of the app. Let me know if you want to keep any of them for future expansion!

## Proposed Changes

### Directory Cleanup
I will run a recursive script to identify and delete all directories inside `lib/` that do not contain any files. 

The likely candidates for deletion include:
#### [DELETE] `lib/domain/usecases`
#### [DELETE] `lib/ui/features/settings`
#### [DELETE] `lib/ui/home`
#### [DELETE] `lib/utils/extensions`
#### [DELETE] `lib/utils/formatters`
*(And any other dynamically identified empty folders)*

## Verification Plan
1. Ensure the directories are safely removed.
2. Run `flutter analyze` to guarantee no implicit paths or imports were broken.
3. Run `flutter run` or `flutter build apk` (if needed) to ensure the project remains perfectly stable.
