class SongItem {
  final int id;
  final String title;
  final String artist;
  final String streamUrl;
  final String uploadedAt;
  final String? media;
  final String? homeMedia;

  SongItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.streamUrl,
    required this.uploadedAt,
    this.media,
    this.homeMedia,
  });

  factory SongItem.fromJson(Map<String, dynamic> json) {
    final songData = json['song'] ?? json;
    return SongItem(
      id: songData['id'],
      title: songData['title'],
      artist: songData['artist'],
      streamUrl: songData['stream_url'],
      uploadedAt: songData['uploaded_at'],
      media: songData['media'],
      homeMedia: songData['home_media'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "artist": artist,
    "stream_url": streamUrl,
    "uploaded_at": uploadedAt,
    "media": media,
    "home_media": homeMedia,
  };
}
