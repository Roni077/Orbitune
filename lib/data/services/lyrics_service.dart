import 'dart:io';
import 'package:path/path.dart' as p;

class LyricsLine {
  final Duration time;
  final String text;

  LyricsLine(this.time, this.text);
}

class LyricsService {
  /// Attempts to find lyrics for the given audio file path.
  /// Looks for a .lrc file with the same name in the same directory.
  Future<String?> getLyrics(String audioFilePath) async {
    // Try .lrc file in the same directory
    try {
      final audioFile = File(audioFilePath);
      final dir = audioFile.parent.path;
      final basename = p.basenameWithoutExtension(audioFile.path);
      final lrcFile = File(p.join(dir, '$basename.lrc'));
      
      if (await lrcFile.exists()) {
        return await lrcFile.readAsString();
      }
    } catch (e) {
      // Ignore file read errors
    }

    return null; // No lyrics found
  }

  /// Parses an LRC formatted string into a list of [LyricsLine].
  /// Returns an empty list if parsing fails or if it's plain text.
  List<LyricsLine> parseLrc(String lrcContent) {
    final List<LyricsLine> lines = [];
    final lrcRegex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (var line in lrcContent.split('\n')) {
      final match = lrcRegex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final millisStr = match.group(3)!;
        final milliseconds = millisStr.length == 2 
            ? int.parse(millisStr) * 10 
            : int.parse(millisStr);
            
        final time = Duration(minutes: minutes, seconds: seconds, milliseconds: milliseconds);
        final text = match.group(4)!.trim();
        
        lines.add(LyricsLine(time, text));
      }
    }

    return lines;
  }
}
