enum OnlineItemType { album, artist, playlist, genre }

class OnlineItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? artworkUrl;
  final OnlineItemType type;

  const OnlineItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.artworkUrl,
    required this.type,
  });
}
