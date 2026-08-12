import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

part 'app_database.g.dart';

@TableIndex(name: 'tracks_title_idx', columns: {#title})
@TableIndex(name: 'tracks_artist_idx', columns: {#artist})
@TableIndex(name: 'tracks_album_idx', columns: {#album})
@DataClassName('TrackEntity')
class Tracks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get album => text()();
  IntColumn get durationMs => integer()();
  TextColumn get source => text()(); // 'local', 'online', 'cached'
  TextColumn get dataUrl => text()();
  TextColumn get artworkUrl => text().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get year => integer().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  IntColumn get skipCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get dateAdded => dateTime().nullable()();
  DateTimeColumn get lastPlayed => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PlaylistEntity')
class Playlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get coverUrl => text().nullable()();
  BoolColumn get isFavoritePlaylist => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'playlist_entries_playlist_id_idx', columns: {#playlistId})
@DataClassName('PlaylistEntryEntity')
class PlaylistEntries extends Table {
  TextColumn get playlistId => text().references(Playlists, #id)();
  TextColumn get trackId => text().references(Tracks, #id)();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, trackId};
}

@DataClassName('PlaybackHistoryEntity')
class PlaybackHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackId => text().references(Tracks, #id)();
  DateTimeColumn get playedAt => dateTime()();
}

@DataClassName('FavoriteAlbumEntity')
class FavoriteAlbums extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get artist => text()();
  TextColumn get artworkUrl => text().nullable()();
  DateTimeColumn get favoritedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FavoriteArtistEntity')
class FavoriteArtists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get favoritedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CachedLyricEntity')
class CachedLyrics extends Table {
  TextColumn get trackId => text().references(Tracks, #id)();
  TextColumn get syncedLyrics => text().nullable()();
  TextColumn get plainLyrics => text().nullable()();

  @override
  Set<Column> get primaryKey => {trackId};
}

@DriftDatabase(tables: [Tracks, Playlists, PlaylistEntries, PlaybackHistory, FavoriteAlbums, FavoriteArtists, CachedLyrics])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          try {
            await m.addColumn(tracks, tracks.lastPlayed);
          } catch (_) {}
        }
        if (from < 3) {
          try {
            await m.createTable(playbackHistory);
            await m.createTable(favoriteAlbums);
            await m.createTable(favoriteArtists);
          } catch (_) {}
        }
        if (from < 4) {
          try {
            await m.createTable(cachedLyrics);
          } catch (_) {}
        }
        if (from < 5) {
          try {
            await m.addColumn(tracks, tracks.skipCount);
          } catch (_) {}
        }
        if (from < 6) {
          try {
            await customStatement('CREATE INDEX IF NOT EXISTS tracks_title_idx ON tracks (title);');
            await customStatement('CREATE INDEX IF NOT EXISTS tracks_artist_idx ON tracks (artist);');
            await customStatement('CREATE INDEX IF NOT EXISTS tracks_album_idx ON tracks (album);');
            await customStatement('CREATE INDEX IF NOT EXISTS playlist_entries_playlist_id_idx ON playlist_entries (playlist_id);');
          } catch (_) {}
        }
      },
    );
  }

  Future<void> cleanUpDatabase() async {
    // Delete history older than 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    await (delete(playbackHistory)..where((h) => h.playedAt.isSmallerThanValue(thirtyDaysAgo))).go();

    // Delete online tracks that are rarely used, not in any playlist, not favorited.
    await customStatement('''
      DELETE FROM tracks 
      WHERE source = 'online' 
        AND playCount = 0 
        AND skipCount = 0
        AND id NOT IN (SELECT track_id FROM playlist_entries)
        AND id NOT IN (SELECT track_id FROM playback_history)
    ''');
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
