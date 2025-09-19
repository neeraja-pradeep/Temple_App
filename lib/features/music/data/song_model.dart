class SongItem {
  final int id;
  final String title;
  final String artist;
  final String streamUrl;
  final String uploadedAt;

  SongItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.streamUrl,
    required this.uploadedAt,
  });

  factory SongItem.fromJson(Map<String, dynamic> json) {
    final songData = json['song'] ?? json;
    return SongItem(
      id: songData['id'],
      title: songData['title'],
      artist: songData['artist'],
      streamUrl: songData['stream_url'],
      uploadedAt: songData['uploaded_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "artist": artist,
    "stream_url": streamUrl,
    "uploaded_at": uploadedAt,
  };
}

