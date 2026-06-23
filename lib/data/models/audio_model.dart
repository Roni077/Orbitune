import 'package:isar/isar.dart';

part 'audio_model.g.dart';

@collection
class AudioModel {
  Id id = Isar.autoIncrement; // Auto-incrementing Isar ID

  @Index(unique: true, replace: true)
  late String uri; // File path or content URI

  late String title;
  late String artist;
  late String album;
  late String displayName;

  int durationMs = 0;
  int trackNumber = 0;
  int sizeBytes = 0;
  
  String? genre;
  int? year;
  
  @Index()
  late DateTime dateAdded;

  // Local path to cached album art if extracted
  String? albumArtPath;
}
