import 'package:isar/isar.dart';
import 'audio_model.dart';

part 'playlist_model.g.dart';

@collection
class PlaylistModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String name;

  late DateTime creationDate;

  // Storing simple string URIs for songs so it doesn't break if AudioModels change.
  // We can join these back to AudioModels on demand.
  List<String> songUris = [];
}
