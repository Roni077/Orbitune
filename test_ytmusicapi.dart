import 'package:ytmusicapi_dart/ytmusicapi_dart.dart';

void main() async {
  final yt = await YTMusic.create();

  try {
    print('--- getMoodCategories ---');
    final moods = await yt.getMoodCategories();
    print(moods);
  } catch (e) {
    print(e);
  }

  yt.close();
}
